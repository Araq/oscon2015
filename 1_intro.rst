============================================================
           The ultimate introduction
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
  <center><big><big>Slides</big></big></center>
  <br />
  <center><big><big><big><big>git clone https://github.com/Araq/oscon2015</big></big></big></big></center>
  <br />
  <br />
  <br />
  <center><big><big>Download</big></big></center>
  <br />
  <center><big><big><big><big><a href="http://nim-lang.org/download.html">http://nim-lang.org/download.html</a></big></big></big></big></center>



Installation
============

::
  git clone -b devel git://github.com/nim-lang/Nim.git
  cd Nim
  git clone -b devel --depth 1 git://github.com/nim-lang/csources
  cd csources && sh build.sh
  cd ..
  bin/nim c koch
  ./koch boot -d:release


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


Philosophy
==========

* power
* efficiency
* fun

..
  Talk about what the plans for Nim were



Why Nim?
========

- Major influences: Modula 3, Delphi, Ada, C++, Python, Lisp, Oberon.

- Development started in 2006
- First successful bootstrapping in 2008
  - compiler written in Delphi
  - converted to Nim via "pas2nim"


Uses of Nim
===========

- games
- compilers
- operating system development
- scientific computing
- scripting



URLs
====

============       ================================================
Website            http://nim-lang.org
Mailing list       http://www.freelists.org/list/nim-dev
Forum              http://forum.nim-lang.org
Github             https://github.com/Araq/Nim
IRC                irc.freenode.net/nim
============       ================================================



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


- ``{"M": 1000, "CM": 900}`` sugar for ``[("M": 1000), ("CM": 900)]``
- ``result`` implicitly available


Nimble
======

- Live demo.


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


If vs when
==========

.. code-block:: nim
   :number-lines:

  when defined(posix):
    proc getCreationTime(file: string): Time =
      var res: Stat
      if stat(file, res) < 0'i32:
        let error = osLastError()
        raiseOSError(error)
      return res.st_ctime



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



Builtin types
=============

- ``int``  -- platform dependent (16) 32 or 64 bit signed number
  * overflows produce an exception in debug mode; wrap around in release mode

- ``float`` -- 64 bit floating point number
  * float64 an alias for float
  * float32 32 bit floating point number

- ``int8`` / ``int16`` / ``int32`` / ``int64``
  * integer types with a platform independent size


Builtin types
=============

- ``uint`` / ``uint8`` / ``uint16`` / ``uint32`` / ``uint64``
  * like in C, always wrap around; modulo arithmetic
  * heavily discouraged:  ``for in 0 .. x.len - 3``
    should iterate 0 times when ``x.len == 0``, not 4294967293 times!
  * instead: use ``Natural``

- ``range[T]``
  * subrange type; quite heavily used in Nim
    (``type Natural = range[0..high(int)]``)

- ``bool``


Builtin types
=============

- ``array[FixedSize, T]``
  * fixed size in Nim
  * value based datatypes
  * layout is compatible to C
  * create via ``[1, 2, 3]`` construction

- ``seq[T]``
  * dynamically resizable at runtime
  * grow with ``add``, resize with ``setLen``
  * create via ``@`` or ``newSeq``: ``@[1, 2, 3]``
  * allocated on the heap and GC'ed

- ``openArray[T]``
  * allows to pass ``seq`` or ``array`` to a routine
  * internally a (pointer, length) pair


Builtin types
=============

- ``proc (a, b: string) {.closure.}``
  * functions are first class in Nim
  * "calling convention" affects type compatibility
  * ``closure`` is a special calling convention (closures are GC'ed)

- ``char`` / ``string`` / ``cstring``
  * ``char`` is simply an octet, ``string`` is almost a ``seq[char]``.
  * ``string`` is (usually) allocated on the heap and GC'ed


Builtin types
=============

``tuple``

* value based datatypes
* structural typing
* optional field names
* construct with ``()``

.. code-block:: Nim
   :number-lines:

  proc `+-`(x, y: int): (int, int) = (x - y, x + y)
  # alternatively
  proc `+-`(x, y: int): tuple[lowerBound, upperBound: int] = (x - y, x + y)

  let tup = 100 +- 10
  echo tup[0], " ", tup.upperBound

  # tuple unpacking
  let (lower, _) = 100 +- 10


Builtin types
=============

``object``

* nominal typing
* value based datatypes

.. code-block:: nim
   :number-lines:

  type
    Rect = object
      x, y, w, h: int

  # construction:
  let r = Rect(x: 12, y: 22, w: 40, h: 80)

  # field access:
  echo r.x, " ", r.y


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


Builtin types
=============

``ref`` and ``ptr``

* pointers; ``ref`` is a "traced" pointer, ``ptr`` is an "untraced" pointer
* ``string``, ``seq``, ``ref`` and ``closure`` are GC'ed, nothing else
* ``ref object`` an idiom to get reference semantics out of objects


Regular expressions
===================

.. code-block:: nim
   :number-lines:

  # Model a regular expression
  type
    RegexKind = enum          ## the regex AST's kind
      reChar,                 ## character node  "c"
      reCClass,               ## character class node   "[a-z]"
      reStar,                 ## star node   "r*"
      rePlus,                 ## plus node   "r+"
      reOpt,                  ## option node  "r?"
      reCat,                  ## concatenation node "ab"
      reAlt,                  ## alternatives node "a|b"
      reWordBoundary          ## "\b"

    RegExpr = ref object
      case kind: RegexKind
      of reWordBoundary: discard
      of reChar:
        c: char
      of reCClass:
        cc: set[char]
      of reStar, rePlus, reOpt:
        child0: RegExpr
      of reCat, reAlt:
        child1, child2: RegExpr


Equality
========

.. code-block:: nim
   :number-lines:

  proc `==`(a, b: RegExpr): bool =
    if a.kind == b.kind:
      case a.kind
      of reWordBoundary: result = true
      of reChar: result = a.c == b.c
      of reCClass: result = a.cc == b.cc
      of reStar, rePlus, reOpt: result = `==`(a.child0, b.child0)
      of reCat, reAlt: result = `==`(a.child1, b.child1) and
                                `==`(a.child2, b.child2)


Accessors
=========

.. code-block:: nim
   :number-lines:

  type
    HashTable[K, V] = object
      data: seq[(K, V)]

  proc hash[K](k: K): int = 0

  proc `[]`*[K, V](x: HashTable[K, V]; k: K): V =
    result = x.data[hash(k)][1]

  proc `[]=`*[K, V](x: var HashTable[K, V]; k: K, v: V) =
    x.data[hash(k)][1] = v


  proc initHashTable[K, V](): HashTable[K, V] =
    result.data = @[]

  var tab = initHashTable[string, string]()
  tab["key"] = "abc"  # calls '[]=' accessor

  echo tab["key"]     # calls '[]' accessor


Accessors
=========

.. code-block:: nim
   :number-lines:

  type
    HashTable[K, V] = object
      data: seq[(K, V)]

  proc hash[K](k: K): int = 0

  proc `[]`*[K, V](x: HashTable[K, V]; k: K): V =
    result = x.data[hash(k)][1]

  proc `[]=`*[K, V](x: var HashTable[K, V]; k: K, v: V) =
    x.data[hash(k)][1] = v


  proc initHashTable[K, V](): HashTable[K, V] =
    result.data = @[]

  var tab = initHashTable[string, string]()
  tab["key"] = "abc"  # calls '[]=' accessor

  echo tab["key"]     # calls '[]' accessor

  # ouch:
  tab["key"].add "xyz"


Accessors
=========

.. code-block:: nim
   :number-lines:


  proc `[]`*[Key, Value](x: var HashTable[Key, Value]; k: Key): var Value =
    result = x.data[hash(key)]


  var
    tab = initHashTable[string, string]()

  # compiles :-)
  tab["key"].add "xyz"


* ``var`` "pass by reference" for parameters
* can also by used for return values


Distinct
========

.. code-block:: nim
   :number-lines:

  # Taken from system.nim
  const taintMode = compileOption("taintmode")

  when taintMode:
    type TaintedString* = distinct string
    proc len*(s: TaintedString): int {.borrow.}
  else:
    type TaintedString* = string

  proc readLine*(f: File): TaintedString {.tags: [ReadIOEffect], benign.}


Distinct
========

.. code-block:: nim
   :number-lines:
  # taintmode_ex

  echo readLine(stdin)

::
  nim c -r --taintMode:on taintmode_ex



Distinct
========

.. code-block:: nim
   :number-lines:
  # taintmode_ex

  echo readLine(stdin).string

::
  nim c -r --taintMode:on taintmode_ex



Distinct
========

.. code-block:: nim
   :number-lines:
  # taintmode_ex

  proc `$`(x: TaintedString): string {.borrow.} # but: defeats the purpose

  echo readLine(stdin)

::
  nim c -r --taintMode:on taintmode_ex


Module system
=============

.. code-block::nim
   :number-lines:

  # Module A
  var
    global*: string = "A.global"

  proc p*(x: string) = echo "exported ", x


.. code-block::nim
   :number-lines:

  # Module B
  import A

  echo p(global)


Module system
=============

.. code-block::nim
   :number-lines:

  # Module A
  var
    global*: string = "A.global"

  proc p*(x: string) = echo "exported ", x


.. code-block::nim
   :number-lines:

  # Module B
  from A import p

  echo p(A.global)


Module system
=============

.. code-block::nim
   :number-lines:

  # Module A
  var
    global*: string = "A.global"

  proc p*(x: string) = echo "exported ", x


.. code-block::nim
   :number-lines:

  # Module B
  import A except global

  echo p(A.global)



Routines
========

- ``proc``
- ``iterator``
- ``template``
- ``macro``
- ``method``
- ``converter``
- (``func``)


Iterators
=========

.. code-block:: nim
   :number-lines:

  iterator `..<`(a, b: int): int =
    var i = a
    while i < b:
      yield i
      i += 1

  for i in 0..<10:
    echo i+1, "-th iteration"


Iterators
=========

.. code-block:: nim
   :number-lines:

  for x in [1, 2, 3]:
    echo x



Iterators
=========

.. code-block:: nim
   :number-lines:

  for x in [1, 2, 3]:
    echo x


Rewritten to:


.. code-block:: nim
   :number-lines:

  for x in items([1, 2, 3]):
    echo x

..
  for i, x in foobar   is rewritten to use the pairs iterator


Iterators
=========

.. code-block:: nim
   :number-lines:

  iterator items*[IX, T](a: array[IX, T]): T {.inline.} =
    var i = low(IX)
    while i <= high(IX):
      yield a[i]
      i += 1


Iterators
=========

.. code-block:: nim
   :number-lines:

  for x in [1, 2, 3]:
    x = 0      # doesn't compile



Iterators
=========

.. code-block:: nim
   :number-lines:

  var a = [1, 2, 3]
  for x in a:
    x = 0     # doesn't compile


Iterators
=========

.. code-block:: nim
   :number-lines:

  iterator mitems*[IX, T](a: var array[IX, T]): var T {.inline.} =
    var i = low(IX)
    if i <= high(IX):
      while true:
        yield a[i]
        if i >= high(IX): break
        i += 1

  var a = [1, 2, 3]
  for x in mitems(a):
    x = 0     # compiles


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
