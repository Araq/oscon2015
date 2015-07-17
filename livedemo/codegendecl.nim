
var
  a {.codegenDecl: "$# progmem $#".}: int

proc myinterrupt() {.codegenDecl: "$# __interrupt $#$# __attribute__(weirdo)",
                     exportc: "nim_interrupt".} =
  echo "realistic interrupt handler"
