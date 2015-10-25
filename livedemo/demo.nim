
var
  a {.codegenDecl: "$# progmem $#".}: int

proc unused() =
  discard


proc myinterrupt() {.codegenDecl: "$3 __interrupt $1 $2", exportc.} =
  echo "realistic interrupt handler"
