=================================================================
    Meta programming
=================================================================


Templates
=========

* templates are declarative, macros imperative

.. code-block:: nim
  # from System.nim
  template `!=` (a, b: untyped): untyped =
    not (a == b)

  assert(5 != 6) # rewritten to: assert(not (5 == 6))

* more transformations
  - ``a > b`` is rewritten to ``b < a``.
  - ``a in b`` is rewritten to ``contains(b, a)``.
  - ``a notin b`` is rewritten to ``not (a in b)``.
  - ``a isnot b`` is rewritten to ``not (a is b)``.


Templates
=========

.. code-block:: nim
   :number-lines:

  template html(name, body) =
    proc name(): string =
      result = "<html>"
      body
      result.add("</html>")

  html mainPage:
    echo "colon syntax to pass statements to template"



Templates
=========

Templates already suffice to implement simple DSLs:

.. code-block:: nim
   :number-lines:

  html mainPage:
    head:
      title "The Nim programming language"
    body:
      ul:
        li "efficient"
        li "expressive"
        li "elegant"

  echo mainPage()


Produces::

  <html>
    <head><title>The Nim programming language</title></head>
    <body>
      <ul>
        <li>efficient</li>
        <li>expressive</li>
        <li>elegant</li>
      </ul>
    </body>
  </html>


Templates
=========

.. code-block:: nim
  template html(name, body) =
    proc name(): string =
      result = "<html>"
      body
      result.add("</html>")

  template head(body) =
    result.add("<head>")
    body
    result.add("</head>")

  ...

  template title(x) =
    result.add("<title>$1</title>" % x)

  template li(x) =
    result.add("<li>$1</li>" % x)


Templates
=========

.. code-block:: nim
   :number-lines:

  proc mainPage(): string =
    result = "<html>"
    result.add("<head>")
    result.add("<title>$1</title>" % "The Nim programming language")
    result.add("</head>")
    result.add("<body>")
    result.add("<ul>")
    result.add("<li>$1</li>" % "efficient")
    result.add("<li>$1</li>" % "expressive")
    result.add("<li>$1</li>" % "elegant")
    result.add("</ul>")
    result.add("</body>")
    result.add("</html>")


Macros
======

* imperative AST to AST transformations
* Turing complete
* ``macros`` module provides an API for dealing with Nim ASTs



Code coverage
=============

.. code-block:: nim
   :number-lines:

  proc toTest(x, y: int) =
    try:
      case x
      of 8:
        if y > 9: echo "8.1"
        else: echo "8.2"
      of 9: echo "9"
      else: echo "else"
      echo "no exception"
    except IoError:
      echo "IoError"

  toTest(8, 10)
  toTest(10, 10)


Code coverage
=============

.. code-block:: nim
   :number-lines:

  proc toTest(x, y: int) =
    try:
      case x
      of 8:
        if y > 9: echo "8.1"
        else: ***echo "8.2"***
      of 9: ***echo "9"***
      else: echo "else"
      echo "no exception"
    except IoError:
      ***echo "IoError"***

  toTest(8, 10)
  toTest(10, 10)



Code coverage
=============

.. code-block:: nim
   :number-lines:
  # This is the code our macro will produce!

  var
    track = [("line 11", false), ("line 15", false), ...]

  proc toTest(x, y: int) =
    try:
      case x
      of 8:
        if y > 9:
          track[0][1] = true
          echo "8.1"
        else:
          track[1][1] = true
          echo "8.2"
      of 9:
        track[2][1] = true
        echo "9"
      else:
        track[3][1] = true
        echo "foo"
      echo "no exception"
    except IoError:
      track[4][1] = true
      echo "IoError"


Code coverage
=============

.. code-block:: nim
   :number-lines:

  toTest(8, 10)
  toTest(1, 2)

  proc listCoverage(s: openArray[(string, bool)]) =
    for x in s:
      if not x[1]: echo "NOT COVERED ", x[0]

  listCoverage(track)


Code coverage
=============

.. code-block:: nim
   :number-lines:

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


Code coverage
=============

::
  ...
        TryStmt
          StmtList
            CaseStmt
              Ident !"x"
              OfBranch
                IntLit 8
                StmtList
                  IfStmt
                    ElifBranch
                      Infix
                        Ident !">"
                        Ident !"y"
                        IntLit 9
                      StmtList [...]
                    Else
                      StmtList [...]
              OfBranch
                IntLit 9
                StmtList
                  Command
                    Ident !"echo"
                    StrLit 9
              Else
                StmtList
                  Command
                    Ident !"echo"
                    StrLit foo
            Command [...]
          ExceptBranch
            [...]



Code coverage
=============

.. code-block:: nim
   :number-lines:

  ## Code coverage macro

  import macros

  proc transform(n, track, list: NimNode): NimNode {.compileTime.} =
    ...

  macro cov(body: untyped): untyped =
    var list = newNimNode(nnkBracket)
    let track = genSym(nskVar, "track")
    result = transform(body, track, list)
    result = newStmtList(newVarStmt(track, list), result,
                     newCall(bindSym"listCoverage", track))
    echo result.toStrLit


  cov:
    proc toTest(x, y: int) =
      ...

    toTest(8, 10)
    toTest(10, 10)


Macros
======

.. code-block:: nim
   :number-lines:

  proc transform(n, track, list: NimNode): NimNode {.compileTime.} =
    # recurse:
    result = copyNimNode(n)
    for c in n.children:
      result.add c.transform(track, list)

    if n.kind in {nnkElifBranch, nnkOfBranch, nnkExceptBranch, nnkElse}:
      let lineinfo = result[^1].lineinfo

      template trackStmt(track, i) =
        track[i][1] = true
      result[^1] = newStmtList(getAst trackStmt(track, list.len), result[^1])

      template tup(lineinfo) =
        (lineinfo, false)
      list.add(getAst tup(lineinfo))


Macros
======

Result::
  8.1
  no exception
  else
  no exception
  NOT COVERED coverage.nim(42,14)
  NOT COVERED coverage.nim(43,12)
  NOT COVERED coverage.nim(47,6)


Macros
======

.. code-block:: nim
   :number-lines:

  proc toTest(x, y: int) =
    try:
      case x
      of 8:
        if y > 9: echo "8.1"
        else: ***echo "8.2"***
      of 9: ***echo "9"***
      else: echo "else"
      echo "no exception"
    except IoError:
      ***echo "IoError"***

  toTest(8, 10)
  toTest(10, 10)


