CON

  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

  ce=8
  csn=9
  clk=10
  mosi=11
  miso=12
  irq=13

  CMD_R_REGISTER=%0000_0000
  CMD_W_REGISTER=%0010_0000
  CMD_R_RX_PAYLOAD=%0110_0001
  CMD_W_TX_PAYLOAD=%1010_0000
  CMD_FLUSH_TX=%1110_0001
  CMD_FLUSH_RX=%1110_0010
  CMD_REUSE_TX_PL=%1110_0011
  CMD_R_RX_PL_WID=%0110_0000
  CMD_W_ACK_PAYLOAD=%1010_1000
  CMD_W_TX_PAYLOAD_NOACK=%1011_0000
  CMD_NOP=%1111_1111

  REG_CONFIG=$00
  REG_EN_AA=$01
  REG_EN_RXADDR=$02
  REG_SETUP_AW=$03
  REG_SETUP_RETR=$04
  REG_RF_CH=$05
  REG_RF_SETUP=$06
  REG_STATUS=$07
  REG_OBSERVE=$08
  REG_RPD=$09
  REG_RX_ADDR_P0=$0A
  REG_RX_ADDR_P1=$0B
  REG_RX_ADDR_P2=$0C
  REG_RX_ADDR_P3=$0D
  REG_RX_ADDR_P4=$0E
  REG_RX_ADDR_P5=$0F
  REG_TX_ADDR=$10
  REG_RX_PW_P0=$11
  REG_RX_PW_P1=$12
  REG_RX_PW_P2=$13
  REG_RX_PW_P3=$14
  REG_RX_PW_P4=$15
  REG_RX_PW_P5=$16
  REG_FIFO_STATUS=$17
  REG_DYNPD=$1C
  REG_FEATURE=$1D


VAR

  byte spiBuffer[32]
  byte lastStatus

OBJ

  pst: "Parallax Serial Terminal"

PUB rfTest | i

  pst.start(115200)

  dira[23..16]~~

  outa[ce..mosi]~
  outa[csn]~~
  dira[ce]~~
  dira[csn]~~
  dira[clk]~~
  dira[mosi]~~
  dira[miso]~
  dira[irq]~

  pst.str(string("rfTest"))
  pst.NewLine

  setTxAddr(@@rxaddr)
  setRxAddr(@@txaddr)

  powerUp(true)
  waitcnt(cnt+clkfreq>>7)
  outa[ce]~~

  repeat while true
    i:=receive
    repeat while i>0
      i--
      pst.hex(spiBuffer[i],2)
    pst.NewLine

PUB receive | width
  clearInterrupts(%111)
  outa[23]~~
  waitpeq(0,1<<irq,0)
  outa[23]~
  clearInterrupts(%111)
  width:=getPayloadWidth

  spiComm(CMD_R_RX_PAYLOAD,FALSE,@spiBuffer,width)

  return width

PUB getPayloadWidth : width
  spiComm(CMD_R_RX_PL_WID,FALSE,@width,1)

PUB transmit(data,dataSize)
  clearInterrupts(%111)
  waitpeq(1<<irq,1<<irq,0)
  spiComm(CMD_W_TX_PAYLOAD,TRUE,data,dataSize)
  outa[ce]~~
  waitcnt(cnt+clkfreq>>16)
  outa[ce]~
  waitpeq(0,1<<irq,0)
  refreshStatus
  if lastStatus>>4 & 1
    clearInterrupts(%111)
    return FALSE
  elseif lastStatus>>5 & 1
    clearInterrupts(%111)
    return TRUE

PUB setTXAddr(addr)
  spiRegister(REG_RX_ADDR_P0,TRUE,addr,5)
  spiRegister(REG_TX_ADDR,TRUE,addr,5)

PUB setRXAddr(addr)
  spiRegister(REG_RX_ADDR_P1,TRUE,addr,5)

PUB powerUp(receiveMode)
  maskWriteRegister(REG_CONFIG,%10 | (receiveMode & 1),%11)

PUB powerDown
  maskWriteRegister(REG_CONFIG,0,%10)

PUB clearInterrupts(mask)
  mask<<=4
  spiRegister(REG_STATUS,TRUE,mask,1)

PUB refreshStatus
  return spiComm(CMD_NOP,FALSE,0,0)

PRI maskWriteRegister(register, value, mask) | oldVal
  spiRegister(register,FALSE,@oldVal,1)
  oldVal&=!mask
  value&=mask
  value|=oldVal
  spiRegister(register,TRUE,@value,1)

  return oldVal

PRI spiRegister(register, write, dataLoc, dataLen)
  if write
    register|=CMD_W_REGISTER
  else
    register|=CMD_R_REGISTER

  return spiComm(register, write, dataLoc,dataLen)

PRI spiComm(command,writeMode,dataLoc,dataLen)

  outa[clk]~
  outa[csn]~

  lastStatus:=spiInOutByte(command)

  repeat dataLen
    if writeMode
      spiInOutByte(byte[dataLoc])
    else
      byte[dataLoc]:=spiInOutByte(0)
    dataLoc++

  outa[csn]~~

  'outa[23..16]:=lastStatus
  return lastStatus

PRI spiInOutByte(outByte) : inByte
  inByte:=0
  outByte->=7
  outa[mosi]:=outByte

  repeat 8
    outByte<-=1
    outa[clk]~~
    inByte<<=1
    inByte|=ina[miso]
    outa[mosi]:=outByte
    outa[clk]~

DAT
txAddr byte 01,01,01,01,01
rxAddr byte 02,02,02,02,02


