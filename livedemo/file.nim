const
  constantA* = 1
  constantB* = 2

type
  Foo* {.importcpp: "Name::Foo", header: "file.h".}[T] = object
    value* {.importc: "value".}: T = NimConstant + 78 shr 9 


proc getValue*[T](this: var Foo[T]): T {.importcpp: "GetValue", header: "file.h".}
proc setValue*[T](this: var Foo[T]; x: cint): var T {.importcpp: "SetValue",
    header: "file.h".}
proc constructFoo*[T](x: T): Foo[T] {.constructor, importcpp: "Name::Foo(@)",
                                  header: "file.h".}
proc destroyFoo*[T](this: var Foo[T]) {.importcpp: "#.~Foo()", header: "file.h".}
proc `==`*[T](this: Foo[T]; other: Foo[T]): bool {.noSideEffect, importcpp: "(# == #)",
    header: "file.h".}