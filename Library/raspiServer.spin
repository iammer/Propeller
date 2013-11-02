OBJ

  pst: "Parallax Serial Terminal"

DAT
  lineIn byte[256]

PUB Start(rx,tx) : okay
  okay:=pst.startRxTx(rx,tx,%0100,115200)

  pst.Char(3)
  pst.String(str("exit"))
  pst.NewLine
  pst.NewLine
  pst.NewLine

  waitFor("$")

PUB waitFor(ch)

  repeat
