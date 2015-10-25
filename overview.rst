============================================================
           An Overview
============================================================


.. raw:: html
  <br />
  <br />
  <br />
  <br />
  <br />
  <br />
  <br />
  <br />
  <center><big>Slides</big></center>
  <br />
  <center><big><big>git clone https://github.com/Araq/oscon2015</big></big></center>
  <br />
  <br />
  <br />
  <center><big>Download</big></center>
  <br />
  <center><big><big><a href="http://nim-lang.org/download.html">http://nim-lang.org/download.html</a></big></big></center>


What is Nim?
============

- new **systems** programming language
- compiles to C
- garbage collection + manual memory management
- thread local garbage collection
- design goals: efficient, expressive, elegant

..
  * Nim compiles to C; C++ and Objective-C are also supported
  * there is an experimental JavaScript backend
  * it provides a soft realtime GC: you can tell it how long it is allowed to run
  * the Nim compiler and **all** of the standard library (including the GC)
    are written in Nim
  * whole program dead code elimination: stdlib carefully crafted to make use
    of it; for instance parsers do not use (runtime) regular expressions ->
    re engine not part of the executable
  * our infrastructure (IDE, build tools, package manager) is
    also completely written in Nim
  * infix/indentation based syntax


Goals
=====

..
  I wanted a programming language that is

* as fast as C
* as expressive as Python
* as extensible as Lisp

..
  and of course learning from the mistakes of the past: So take the type system
  from Ada, not from C++. At this moment in time, Nim achieves all of my
  original goals.

  However, it turns out that after writing a compiler from scratch you learn
  one thing or the other,
   achieving these goals and
  lreaning more about PL design, I have come across features of other
  programming languages which have inspired to continue innovating and as such

..
  Talk about what the plans for Nim were




Uses of Nim
===========

- web development
- games
- compilers
- operating system development
- scientific computing
- scripting
- command line applications
- UI applications
- And lots more!



Hello World
===========

.. code-block:: nim
  echo "hello world!"


Hello World
===========

.. code-block:: nim
  echo "hello world!"

::
  nim c -r hello.nim



More Code!
==========

.. code-block:: nim
   :number-lines:

  proc decimalToRoman*(number: range[1..3_999]): string =
    ## Converts a number to a Roman numeral.
    const romanComposites = {
      "M": 1000, "CM": 900,
      "D": 500, "CD": 400, "C": 100,
      "XC": 90, "L": 50, "XL": 40, "X": 10, "IX": 9,
      "V": 5, "IV": 4, "I": 1}
    result = ""
    var decVal = number.int
    for key, val in items(romanComposites):
      while decVal >= val:
        decVal -= val
        result.add(key)

  echo decimalToRoman(1009) # MIX


- ``{"M": 1000, "CM": 900}`` sugar for ``[("M", 1000), ("CM", 900)]``
- ``result`` implicitly available


Function application
====================

Function application is ``f()``, ``f(a)``, ``f(a, b)``.


Function application
====================

Function application is ``f()``, ``f(a)``, ``f(a, b)``.

And here is the sugar:

===========    ==================   ===============================
Sugar          Meaning              Example
===========    ==================   ===============================
``f a``        ``f(a)``             ``spawn log("some message")``
``a.f()``      ``f(a)``             ``db.fetchRow()``
``a.f``        ``f(a)``             ``mystring.len``
``f a, b``     ``f(a, b)``          ``echo "hello ", "world"``
``a.f(b)``     ``f(a, b)``          ``myarray.map(f)``
``a.f b``      ``f(a, b)``          ``db.fetchRow 1``
``f"\n"``      ``f(r"\n")``         ``re"\b[a-z*]\b"``
===========    ==================   ===============================


Function application
====================

Function application is ``f()``, ``f(a)``, ``f(a, b)``.

And here is the sugar:

===========    ==================   ===============================
Sugar          Meaning              Example
===========    ==================   ===============================
``f a``        ``f(a)``             ``spawn log("some message")``
``a.f()``      ``f(a)``             ``db.fetchRow()``
``a.f``        ``f(a)``             ``mystring.len``
``f a, b``     ``f(a, b)``          ``echo "hello ", "world"``
``a.f(b)``     ``f(a, b)``          ``myarray.map(f)``
``a.f b``      ``f(a, b)``          ``db.fetchRow 1``
``f"\n"``      ``f(r"\n")``         ``re"\b[a-z*]\b"``
===========    ==================   ===============================


**BUT**: ``f`` does not mean ``f()``; ``myarray.map(f)`` passes ``f`` to ``map``


Operators
=========

* operators are simply sugar for functions
* operator in backticks is treated like an identifier

  ::
    `@`(x, y)
    x.`@`(y)
    `@`(x)
    x.`@`()
    x.`@`


Operators
=========

* Of course, most of the time binary operators are simply invoked as ``x @ y``
  and unary operators as ``@x``.
* No explicit distinction between binary and unary operators:

.. code-block:: Nim
   :number-lines:

  proc `++`(x: var int; y: int = 1; z: int = 0) =
    x = x + y + z

  var g = 70
  ++g
  g ++ 7
  g.`++`(10, 20)
  echo g  # writes 108

* parameters are readonly unless declared as ``var``
* ``var`` means "pass by reference" (implemented with a hidden pointer)


Control flow
============


- The usual control flow statements are available:
  * if
  * case
  * when
  * while
  * for
  * try
  * defer
  * return
  * yield


Statements vs expressions
=========================

Statements require indentation:

.. code-block:: nim
  # no indentation needed for single assignment statement:
  if x: x = false

  # indentation needed for nested if statement:
  if x:
    if y:
      y = false
  else:
    y = true

  # indentation needed, because two statements follow the condition:
  if x:
    x = false
    y = false


Statements vs expressions
=========================

Expressions do not:

.. code-block:: nim

  if thisIsaLongCondition() and
      thisIsAnotherLongCondition(1,
         2, 3, 4):
    x = true

- Rule of thumb: optional indentation after operators, ``(`` and ``,``
- ``if``, ``case`` etc also available as expressions



Type system
===========

- strict and statically typed
- type system weakened for the meta-programming
- value based datatypes (like in C++)
- subtyping via single inheritance (``object of RootObj``)
- subtyping via ``range``: ``type Natural = range[0..high(int)]``
- generics (``HashSet[string]``)
- "concepts": constraints for generic types
- no interfaces, use (tuple of) closures instead
- no Hindley-Milner type inference, Nim embraces overloading
- limited amount of flow typing


Flow typing
===========

.. code-block:: nim
  proc f(p: ref int not nil)

  var x: ref int
  if x != nil:
    p(x)


Effect system
=============

- model effects as tuples ``(T, E)`` rather than ``E[T]``
- every effect is inferred


Effect system
=============

- tracks side effects
- tracks exceptions
- tracks "tags": ReadIOEffect, WriteIoEffect, TimeEffect,
  ReadDirEffect, **ExecIOEffect**
- tracks locking levels; deadlock prevention at compile-time
- tracks "GC safety"



Effect system
=============

.. code-block:: nim
   :number-lines:

  proc foo() {.noSideEffect.} =
    echo "is IO a side effect?"


Builtin types
=============

enums & sets

.. code-block:: nim
   :number-lines:

  type
    SandboxFlag* = enum        ## what the interpreter should allow
      allowCast,               ## allow unsafe language feature: 'cast'
      allowFFI,                ## allow the FFI
      allowInfiniteLoops       ## allow endless loops
    SandboxFlags* = set[SandboxFlag]

  proc runNimCode(code: string; flags: SandboxFlags = {allowCast, allowFFI}) =
    ...


Builtin types
=============

.. code-block:: C
   :number-lines:

  #define allowCast (1 << 0)
  #define allowFFI (1 << 1)
  #define allowInfiniteLoops (1 << 1)

  void runNimCode(char* code, unsigned int flags = allowCast|allowFFI);

  runNimCode("4+5", 700);


Routines
========

- ``proc``
- ``iterator``
- ``template``
- ``macro``
- ``method``
- ``converter``
- (``func``)


Templates
=========

.. code-block::nim
   :number-lines:

  template `??`(a, b: untyped): untyped =
    let x = a
    (if x.isNil: b else: x)

  var x: string
  echo x ?? "woohoo"


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


Macros
======

.. code-block::nim
   :number-lines:

  proc write(f: File; a: int) =
    echo a

  proc write(f: File; a: bool) =
    echo a

  proc write(f: File; a: float) =
    echo a

  proc writeNewline(f: File) =
    echo "\n"

  macro writeln(f: File; args: varargs[typed]) =
    result = newStmtList()
    for a in args:
      result.add newCall(bindSym"write", f, a)
    result.add newCall(bindSym"writeNewline", f)


Macros
======

.. code-block::nim
   :number-lines:

  macro curry(f: typed; args: varargs[untyped]): untyped =
    let ty = getType(f)
    assert($ty[0] == "proc", "first param is not a function")
    let n_remaining = ty.len - 2 - args.len
    assert n_remaining > 0, "cannot curry all the parameters"
    #echo treerepr ty

    var callExpr = newCall(f)
    args.copyChildrenTo callExpr

    var params: seq[NimNode] = @[]
    # return type
    params.add ty[1].type_to_nim

    for i in 0 .. <n_remaining:
      let param = ident("arg"& $i)
      params.add newIdentDefs(param, ty[i+2+args.len].type_to_nim2)
      callExpr.add param

    result = newProc(procType = nnkLambda, params = params, body = callExpr)


Parallelism
===========

.. code-block::nim
   :number-lines:

  import tables, strutils

  proc countWords(filename: string): CountTableRef[string] =
    ## Counts all the words in the file.
    result = newCountTable[string]()
    for word in readFile(filename).split:
      result.inc word


Parallelism
===========

.. code-block::nim
   :number-lines:

  #
  #
  const
    files = ["data1.txt", "data2.txt", "data3.txt", "data4.txt"]

  proc main() =
    var tab = newCountTable[string]()
    for f in files:
      let tab2 = countWords(f)
      tab.merge(tab2)
    tab.sort()
    echo tab.largest

  main()


Parallelism
===========

.. code-block::nim
   :number-lines:

  import threadpool

  const
    files = ["data1.txt", "data2.txt", "data3.txt", "data4.txt"]

  proc main() =
    var tab = newCountTable[string]()
    var results: array[files.len, ***FlowVar[CountTableRef[string]]***]
    for i, f in files:
      results[i] = ***spawn*** countWords(f)
    for i in 0..high(results):
      tab.merge(*** ^results[i] ***)
    tab.sort()
    echo tab.largest

  main()


Parallelism
===========

.. code-block::nim
   :number-lines:

  import strutils, math, threadpool

  proc term(k: float): float = 4 * math.pow(-1, k) / (2*k + 1)

  proc computePi(n: int): float =
    var ch = newSeq[FlowVar[float]](n+1)
    for k in 0..n:
      ch[k] = spawn term(float(k))
    for k in 0..n:
      result += ^ch[k]



Please contribute
=================

============       ================================================
Website            http://nim-lang.org
Mailing list       http://www.freelists.org/list/nim-dev
Forum              http://forum.nim-lang.org
Github             https://github.com/Araq/Nim
IRC                irc.freenode.net/nim
============       ================================================
