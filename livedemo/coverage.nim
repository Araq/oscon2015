
## Code coverage macro

import macros

proc transform(n, guard, list: NimNode): NimNode {.compileTime.} =
  # recurse:
  result = copyNimNode(n)
  for c in n.children:
    result.add c.transform(guard, list)

  if n.kind in {nnkElifBranch, nnkOfBranch, nnkExceptBranch, nnkElifExpr,
                nnkElseExpr, nnkElse, nnkForStmt, nnkWhileStmt}:
    let lineinfo = result[^1].lineinfo

    template track(guard, i) =
      guard[i][1] = true
    result[^1] = newStmtList(getAst track(guard, list.len), result[^1])

    template tup(lineinfo) =
      (lineinfo, false)
    list.add(getAst tup(lineinfo))

proc listCoverage(s: openArray[(string, bool)]) =
  for x in s:
    if not x[1]: echo "NOT EXECUTED ", x[0]

macro cov(p: untyped): untyped =
  var list = newNimNode(nnkBracket)
  let guard = genSym(nskVar, "guard")
  result = transform(p, guard, list)
  result = newStmtList(newVarStmt(guard, list), result,
                   newCall(bindSym"listCoverage", guard))


cov:
  proc toTest(x, y: int) =
    try:
      case x
      of 8:
        if y > 9: echo "8.1"
        else: echo "8.2"
      of 9: echo "9"
      else: echo "else"
      echo "no IoError"
    except IoError:
      echo "IoError"
  toTest(8, 10)
  toTest(10, 10)


when false:
  cov:
    proc toTest(x: int): int =
      if x > 0: result = 88
      else: result = 99

    proc toTestE(x: int): int =
      (if x > 0: 88 else: 99)

    proc toTestTry(x: int) =
      try:
        case x
        of 8: echo "8"
        of 9: echo "9"
        else: echo "foo"
        echo "Try it"
      except IoError:
        echo "IoError"

    echo toTest 89
    echo toTest(-89)

    echo toTestE 89
    toTestTry(8)
  #  echo toTestE(-89)
