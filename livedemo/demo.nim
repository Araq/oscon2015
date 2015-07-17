
import macros

macro cov(n: untyped): untyped =
  result = n
  echo treeRepr n

cov:
  proc toTest(x, y: int) =
    try:
      case x
      of 8:
        if y > 9: echo "8.1"
        else: echo "8.2"
      of 9: echo "9"
      else: echo "foo"
      echo "no exception"
    except IoError:
      echo "IoError"

  toTest(8, 10)
  toTest(10, 10)
