======================
Interfacing with C/C++
======================


Interfacing with C
==================

2 options

- via ``dynlib``
- via ``header``


Dynlib import
=============

.. code-block:: Nim
   :number-lines:
  type
    GtkWidget = object
      data: cint
      binary: cfloat
      compatible: char

  proc gtk_image_new(): ptr GtkWidget
    {.cdecl, dynlib: "libgtk-x11-2.0.so", importc.}



Header import
=============

.. code-block::
   :number-lines:

  type
    GtkWidget {.importc: "GtkWidget_t", header: "<gtk.h>".} = object
      data {.importc: "Data".}: cint
      binary {.importc: "Binary".}: cfloat
      compatible: char

  proc gtk_image_new(): ptr GtkWidget
    {.cdecl, header: "<gtk.h>", importc.}

  {.passC: staticExec("pkg-config --cflags gtk").}
  {.passL: staticExec("pkg-config --libs gtk").}



Header import
=============

.. code-block::
   :number-lines:

  proc printf(formatstr: cstring)
    {.header: "<stdio.h>", importc: "printf", varargs.}

  printf("%s%s", "Nim strings ", "converted to cstring for you")


Data exchange with C
====================

=================   ==========================================================
C type              Nim type
=================   ==========================================================
``int``             ``cint``
``unsigned long``   ``culong``
``float``           ``cfloat``
``int x[4]``        ``array[4, cint]``
``int*``            ``ptr int``
``char*``           ``cstring``
``char**``          ``cstringArray = ptr array [0..ArrayDummySize, cstring]``
=================   ==========================================================


Data exchange with C
====================

.. code-block:: C
   :number-lines:

  int sum(int* x, size_t len) {
    int result = 0;
    for (size_t i = 0; i < len; i++)
      result += x[i];
    return result;
  }


Data exchange with C
====================

.. code-block:: C
   :number-lines:

  int sum(int* x, size_t len) {
    int result = 0;
    for (size_t i = 0; i < len; i++)
      result += x[i];
    return result;
  }

.. code-block:: Nim
   :number-lines:

  proc sum(x: ptr cint; len: int): cint
    {.importc: "sum", cdecl, header: "foo.h".}

  proc callSum =
    var x = @[1.cint, 2, 3, 4]
    echo sum(addr x[0], x.len)

    var y = [1.cint, 2, 3, 4]
    echo sum(addr y[0], y.len)



CodegenDecl pragma
==================


.. code-block:: nim
   :number-lines:

  var
    a {.codegenDecl: "$# progmem $#".}: int

  proc myinterrupt() {.codegenDecl: "__interrupt $# $#$#".} =
    echo "realistic interrupt handler"





Wrapping C++
============

.. code-block:: C++
   :number-lines:

  class Foo {
  public:
    int value;
    int GetValue() { return value; }
    int& SetValue(int x) { field = x; return &field; }
  };

.. code-block:: Nim
   :number-lines:

  type
    Foo* {.importcpp: "Foo", header: "file.h".} = object
      value*: cint

  proc getValue*(this: var Foo): cint
    {.importcpp: "GetValue", header: "file.h".}
  proc setValue*(this: var Foo; x: cint): var cint
    {.importcpp: "SetValue", header: "file.h".}


Wrapping C++
============

.. code-block:: C++
   :number-lines:

  class Foo {
  public:
    int value;
    int GetValue() { return value; }
    int& SetValue(int x) { field = x; return &field; }
  };

.. code-block:: Nim
   :number-lines:

  type
    Foo* {.importcpp: "Foo", header: "file.h".} = object
      value*: cint

  proc getValue*(this: var Foo): cint
    {.importcpp: "#.GetValue(@)", header: "file.h".}
  proc setValue*(this: var Foo; x: cint): var cint
    {.importcpp: "#.SetValue(@)", header: "file.h".}



Constructors
============

.. code-block:: C++
   :number-lines:

  class Foo {
  public:
    int value;
    int GetValue() { return value; }
    int& SetValue(int x) { field = x; return &field; }

    Foo(int x): field(x) {}
  };

.. code-block:: Nim
   :number-lines:

  type
    Foo* {.importcpp: "Foo", header: "file.h".} = object
      value*: cint

  proc getValue*(this: var Foo): cint
    {.importcpp: "#.GetValue(@)", header: "file.h".}
  proc setValue*(this: var Foo; x: cint): var cint
    {.importcpp: "#.SetValue(@)", header: "file.h".}

  proc constructFoo*(x: cint): Foo
    {.importcpp: "Foo(@)", header: "file.h".}


Constructors
============

.. code-block:: C++
   :number-lines:

  Foo foo = Foo(1, 2, 3);

  auto foo = Foo(1, 2, 3);


Constructors
============

.. code-block:: C++
   :number-lines:

  Foo foo = Foo(1, 2, 3);
  // Calls copy constructor!
  auto foo = Foo(1, 2, 3);


Constructors
============

.. code-block:: C++
   :number-lines:

  Foo foo = Foo(1, 2, 3);
  // Calls copy constructor!
  auto foo = Foo(1, 2, 3);

  Foo foo(1, 2, 3);


Constructors
============

.. code-block:: Nim
   :number-lines:

  proc constructFoo*(x: cint): Foo
    {.importcpp: "Foo(@)", header: "file.h", constructor.}


.. code-block:: nim
   :number-lines:

  proc newFoo(a, b: cint): ptr Foo {.importcpp: "new Foo(@)".}

  let x = newFoo(3, 4)


  proc cnew*[T](x: T): ptr T {.importcpp: "(new '*0#@)", nodecl.}



Generics
========

For example:

.. code-block:: nim
   :number-lines:

  type Input {.importcpp: "System::Input".} = object
  proc getSubsystem*[T](): ptr T
    {.importcpp: "SystemManager::getSubsystem<'*0>()", nodecl.}

  let x: ptr Input = getSubsystem[Input]()

Produces:

.. code-block:: C
   :number-lines:

  x = SystemManager::getSubsystem<System::Input>()



Emit pragma
===========

.. code-block:: Nim
   :number-lines:

  {.emit: """
  static int cvariable = 420;
  """.}

  {.push stackTrace:off.}
  proc embedsC() =
    var nimVar = 89
    # use backticks to access Nim symbols within an emit section:
    {.emit: """fprintf(stdout, "%d\n", cvariable + (int)`nimVar`);""".}
  {.pop.}

  embedsC()


..
  A tour through the standard library
  -----------------------------------

  - system module: basic arithmetic and IO
  - strutils module; Unicode module
  - OS and osproc modules
  - sequtils and algorithm
  - tables and sets
  - linked lists, queues

  - watchpoints
  - tracing
  - lexer generation
  - ORM


Questions?
==========
