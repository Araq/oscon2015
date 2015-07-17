=============
Effect system
=============


NoSideEffect
============

.. code-block:: nim
   :number-lines:

  cov:
    proc toTest(x, y: int): int {.noSideEffect.} =
      case x
      of 8:
        if y > 9: 8+1
        else: 8+2
      of 9: 9
      else: 100

  # Error: 'toTest' can have side-effects



NoSideEffect
============

.. code-block:: nim
   :number-lines:

  var
    track = [("line 9", false), ("line 13", false), ...]

  proc toTest(x, y: int): int {.noSideEffect.} =
    case x
    of 8:
      if y > 9:
        track[0][1] = true
    ...



NoSideEffect
============

.. code-block:: nim
   :number-lines:

  var
    track = [("line 9", false), ("line 13", false), ...]

  proc setter(x: int) =
    track[x][1] = true

  type HideEffects = proc (x: int) {.noSideEffect, raises: [], tags: [].}

  proc toTest(x, y: int): int =
    case x
    of 8:
      if y > 9:
        cast[HideEffects](setter)(0)
    ...


Effect System
=============

- tracks side effects
- tracks exceptions
- tracks "tags": ReadIOEffect, WriteIoEffect, TimeEffect,
  ReadDirEffect, **ExecIOEffect**
- tracks locking levels; deadlock prevention at compile-time

..
  Think of ``(T, E)`` as opposed to ``E[T]``.


Exceptions
==========

.. code-block:: nim
   :number-lines:

  import strutils

  proc readFromFile() {.raises: [].} =
    # read the first two lines of a text file that should contain numbers
    # and tries to add them
    var
      f: File
    if open(f, "numbers.txt"):
      try:
        var a = readLine(f)
        var b = readLine(f)
        echo("sum: " & $(parseInt(a) + parseInt(b)))
      except OverflowError:
        echo("overflow!")
      except ValueError:
        echo("could not convert string to integer")
      except IOError:
        echo("IO error!")
      except:
        echo("Unknown exception!")
      finally:
        close(f)

..
  - describe inference algorithm

  proc noRaise(x: proc()) {.raises: [].} =
    # unknown call that might raise anything, but valid:
    x()

  proc doRaise() {.raises: [IOError].} =
    raise newException(IOError, "IO")

  proc use() {.raises: [].} =
    # doesn't compile! Can raise IOError!
    noRaise(doRaise)


Tags
====

.. code-block:: nim
   :number-lines:
  type
    TagA = object of RootEffect
    TagB = object of RootEffect

  proc a() {.tags: [TagA].} = discard
  proc b() {.tags: [TagB].} = discard

  proc x(input: int) {.tags: [ ? ].} =
    if input < 0: a()
    else: b()

..
  Just demonstrate 'doc2' here


Tags
====

.. code-block:: nim
   :number-lines:
  type
    TagA = object of RootEffect
    TagB = object of RootEffect

  proc a() {.tags: [TagA].} = discard
  proc b() {.tags: [TagB].} = discard

  proc x(input: int) {.tags: [TagA, TagB].} =
    if input < 0: a()
    else: b()


Tags
====

.. code-block:: nim
   :number-lines:

  proc execProcesses(commands: openArray[string],
                     beforeRunEvent: proc (command: string) = nil): int
    {.tags: [ExecIOEffect].}
    ## executes the commands in parallel. The highest return value of
    ## all processes is returned. Runs `beforeRunEvent` before running each
    ## command.

  proc echoCommand(command: string) {.tags: [WriteIOEffect].} =
    echo command

  proc compose*() =
    execProcesses(["gcc -o foo foo.c",
                   "gcc -o bar bar.c",
                   "gcc -o baz baz.c"],
                   echoCommand)



GC safety
=========

- a ``spawn``'ed proc must be ``gcsafe``
- ``gcsafe``: Does not access global variables containing GC'ed memory
- ``noSideEffect``: Does not access global variables
- ``noSideEffect`` implies ``gcsafe``


GC safety
=========

.. code-block:: nim
   :number-lines:

  import tables, strutils, threadpool

  const
    files = ["data1.txt", "data2.txt", "data3.txt", "data4.txt"]

  var tab = newCountTable[string]()

  proc countWords(filename: string) =
    ## Counts all the words in the file.
    for word in readFile(filename).split:
      tab.inc word

  for f in files:
    spawn countWords(f)
  sync()
  tab.sort()
  echo tab.largest


GC safety
=========

.. code-block:: nim
   :number-lines:

  import threadpool, tables, strutils

  {.pragma isolated, threadvar.}

  var tab {.isolated.}: CountTable[string]

  proc rawPut(key: string) =
    inc(tab, key)

  proc put(key: string) =
    pinnedSpawn 0, rawPut(key)

  proc rawGet(): string =
    tab.sort()
    result = tab.largest()[0]

  proc getMax(): string =
    let flow = pinnedSpawn(0, rawGet())
    result = ^flow

  proc main =
    pinnedSpawn 0, (proc () = tab = initCountTable[string]())
    for x in split(readFile("readme.txt")):
      put x
    echo getMax()

  main()



Guards and locks
================

- common low level concurrency mechanisms like locks, atomic instructions or
  condition variables are available
- guards fight data races
- locking levels fight deadlocks


Data race
=========

A data race occurs when:

- two or more threads access the same memory location concurrently
- at least one of the accesses is for writing
- the threads are not using any exclusive locks to control their accesses


Guards fight data races
=======================

- Object fields and global variables can be annotated via a ``guard`` pragma
- Access then has to be within a ``locks`` section:

.. code-block:: nim
   :number-lines:

  var glock: Lock
  var gdata {.guard: glock.}: int

  proc invalid =
    # invalid: unguarded access:
    echo gdata

  proc valid =
    # valid access:
    {.locks: [glock].}:
      echo gdata


Guards fight data races
=======================

.. code-block:: nim
   :number-lines:

  template lock(a: Lock; body: untyped) =
    pthread_mutex_lock(a)
    {.locks: [a].}:
      try:
        body
      finally:
        pthread_mutex_unlock(a)


Guards fight data races
=======================

.. code-block:: nim
   :number-lines:

  var dummyLock {.compileTime.}: int
  var atomicCounter {.guard: dummyLock.}: int

  template atomicRead(x): expr =
    {.locks: [dummyLock].}:
      memoryReadBarrier()
      x

  echo atomicRead(atomicCounter)


Deadlocks
=========

A deadlock occurs when:

- thread A acquires lock L1
- thread B acquires lock L2
- thread A tries to acquire lock L2
- thread B tries to acquire lock L1

Solution?


Deadlocks
=========

A deadlock occurs when:

- thread A acquires lock L1
- thread B acquires lock L2
- thread A tries to acquire lock L2
- thread B tries to acquire lock L1

Solution?

- enforce L1 is always acquired before L2



Locking levels fight deadlocks
==============================

.. code-block:: nim
   :number-lines:

  var a, b: Lock[2]
  var x: Lock[1]
  # invalid locking order: Lock[1] cannot be acquired before Lock[2]:
  {.locks: [x].}:
    {.locks: [a].}:
      ...
  # valid locking order: Lock[2] acquired before Lock[1]:
  {.locks: [a].}:
    {.locks: [x].}:
      ...

  # invalid locking order: Lock[2] acquired before Lock[2]:
  {.locks: [a].}:
    {.locks: [b].}:
      ...

  # valid locking order, locks of the same level acquired at the same time:
  {.locks: [a, b].}:
    ...



Locking levels fight deadlocks
==============================

.. code-block:: nim
   :number-lines:

  template multilock(a, b: ptr Lock; body: stmt) =
    if cast[ByteAddress](a) < cast[ByteAddress](b):
      pthread_mutex_lock(a)
      pthread_mutex_lock(b)
    else:
      pthread_mutex_lock(b)
      pthread_mutex_lock(a)
    {.locks: [a, b].}:
      try:
        body
      finally:
        pthread_mutex_unlock(a)
        pthread_mutex_unlock(b)


Locking levels fight deadlocks
==============================

.. code-block:: nim
   :number-lines:

  proc p() {.locks: 3.} = discard

  var a: Lock[4]
  {.locks: [a].}:
    # p's locklevel (3) is strictly less than a's (4) so the call is allowed:
    p()
