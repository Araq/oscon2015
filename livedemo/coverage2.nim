
import macros

type HideEffects = proc (x: int) {.raises: [], noSideEffect, tags: [].}

proc wrap(n: NimNode; setter, i: NimNode): NimNode {.compileTime.} =
  # XXX better insert as last statement, but move before 'break', 'return' etc.
  template callSetterProc(setter, i) =
    cast[HideEffects](setter)(i)
  result = newTree(nnkStmtList, getAst callSetterProc(setter, i), n)

proc transform(n, setter, data: NimNode): NimNode {.compileTime.} =
  # recurse:
  result = copyNimNode(n)
  for c in n.children:
    result.add c.transform(setter, data)
  if n.kind in {nnkElifBranch, nnkOfBranch, nnkExceptBranch, nnkElifExpr,
                nnkElseExpr, nnkElse, nnkForStmt, nnkWhileStmt}:
    let index = newLit(data.len)
    data.add(newTree(nnkPar, newLit(result[^1].lineinfo), bindSym"false"))
    result[^1] = result[^1].wrap(setter, index)

proc listCoverage(s: openArray[(string, bool)]) =
  for x in s:
    if not x[1]: echo "NOT EXECUTED ", x[0]

macro cov(p: untyped): untyped =
  var data = newNimNode(nnkBracket)
  let guard = genSym(nskVar, "guard")
  let setter = genSym(nskProc, "guardSetter")
  template setterProc(name, guard) =
    proc name(x: int) =
      guard[x][1] = true

  result = transform(p, setter, data)
  result = newTree(nnkStmtList, newVarStmt(guard, data),
                   getAst setterProc(setter, guard),
                   result,
                   newCall(bindSym"listCoverage", guard))

cov:
  proc toTest(x: int): int {.noSideEffect.} =
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
