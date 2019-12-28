# Copyright © 2019-20 Mark Summerfield. All rights reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may only use this file in compliance with the License. The license
# is available from http://www.apache.org/licenses/LICENSE-2.0

import hashes
import strutils
import unittest
import oids
import hashes

import diff
import diffoutput


var original = """This part of the
document has stayed the
same from version to
version.  It shouldn't
be shown if it doesn't
change.  Otherwise, that
would not be helping to
compress the size of the
changes.

This paragraph contains
text that is outdated.
It will be deleted in the
near future.

It is important to spell
check this dokument. On
the other hand, a
misspelled word isn't
the end of the world.
Nothing in the rest of
this paragraph needs to
be changed. Things can
be added after it.
""".split("\n")

var newdoc = """This is an important
notice! It should
therefore be located at
the beginning of this
document!

This part of the
document has stayed the
same from version to
version.  It shouldn't
be shown if it doesn't
change.  Otherwise, that
would not be helping to
compress the size of the
changes.

It is important to spell
check this document. On
the other hand, a
misspelled word isn't
the end of the world.
Nothing in the rest of
this paragraph needs to
be changed. Things can
be added after it.

This paragraph contains
important new additions
to this document.
""".split("\n")

var origWrappingA = """a
b
c
d
e
f
g
h""".split("\n")

var newWrappingA = """d
e""".split("\n")

var origWrappingB = """d
e""".split("\n")

var newWrappingB = """a
b
c
d
e
f
g
h""".split("\n")


type
  TestObject = object
    number: int
    id: Oid


let origTestObjects = @[
  TestObject(number: 4, id: parseOid("0123456789abcdef012345678")),
  TestObject(number: 3, id: parseOid("0123456789abcdef01234567b")),
  TestObject(number: 1, id: parseOid("0123456789abcdef01234567a"))
]

let newTestObjects = @[
  TestObject(number: 4, id: parseOid("0123456789abcdef012345678")),
  TestObject(number: 2, id: parseOid("0123456789abcdef012345679")),
  TestObject(number: 1, id: parseOid("0123456789abcdef01234567a")),
  TestObject(number: 0, id: parseOid("0123456789abcdef01234567b"))
]


proc `$`(obj: TestObject): string =
  result = "TO:$1,$2".format(obj.number, $obj.id)


proc hash(obj: TestObject): Hash =
  var h: Hash = 0
  h = h !& hash(obj.number)
  h = h !& hash(obj.id)
  result = !$h


proc parseTestObject(source: string): TestObject =
  result = TestObject()
  let parts = source.split(",")
  let nparts = parts[0].split(":")
  result.number = parseInt(nparts[1])
  result.id = parseOid(parts[1])


proc parsestr(source: string): string =
  result = source


suite "minima string tests":

  test "generate minima string":
    let diff = newDiff(original, newdoc)
    let minima = diff.outputMinimaStr()

    check minima == """0,0
>This is an important
>notice! It should
>therefore be located at
>the beginning of this
>document!
>
10,16
<This paragraph contains
<text that is outdated.
<It will be deleted in the
<near future.
<
16,17
<check this dokument. On
>check this document. On
25,26
>This paragraph contains
>important new additions
>to this document.
>
"""

    let to_diff = newDiff(origTestObjects, newTestObjects)
    let to_minima = to_diff.outputMinimaStr()

    check to_minima == """1,1
<TO:3,0123456789abcdef01234567
>TO:2,0123456789abcdef01234567
3,3
>TO:0,0123456789abcdef01234567
"""

  test "recover new sequence":

    let diff = newDiff(original, newdoc)
    let minima = diff.outputMinimaStr()
    let recoveredNewDoc = recoverNewFromMinima(original, minima, parse=parsestr)

    check newdoc == recoveredNewDoc

    let wa_diff = newDiff(origWrappingA, newWrappingA)
    let wa_minima = wa_diff.outputMinimaStr()
    let wa_recovered = recoverNewFromMinima(origWrappingA, wa_minima, parse=parsestr)

    check newWrappingA == wa_recovered

    let wb_diff = newDiff(origWrappingB, newWrappingB)
    let wb_minima = wb_diff.outputMinimaStr()
    let wb_recovered = recoverNewFromMinima(origWrappingB, wb_minima, parse=parsestr)

    check newWrappingB == wb_recovered

    let to_diff = newDiff(origTestObjects, newTestObjects)
    let to_minima = to_diff.outputMinimaStr()
    let to_recovered = recoverNewFromMinima(origTestObjects, to_minima, parse=parseTestObject)

    check newTestObjects == to_recovered

  test "recover original sequence":

    let diff = newDiff(original, newdoc)
    let minima = diff.outputMinimaStr()
    let recoveredOrigDoc = recoverOriginalFromMinima(newdoc, minima, parse=parsestr)

    check original == recoveredOrigDoc

    let wa_diff = newDiff(origWrappingA, newWrappingA)
    let wa_minima = wa_diff.outputMinimaStr()
    let wa_recovered = recoverOriginalFromMinima(newWrappingA, wa_minima, parse=parsestr)

    check origWrappingA == wa_recovered

    let wb_diff = newDiff(origWrappingB, newWrappingB)
    let wb_minima = wb_diff.outputMinimaStr()
    let wb_recovered = recoverOriginalFromMinima(newWrappingB, wb_minima, parse=parsestr)

    check origWrappingB == wb_recovered

    let to_diff = newDiff(origTestObjects, newTestObjects)
    let to_minima = to_diff.outputMinimaStr()
    let to_recovered = recoverOriginalFromMinima(newTestObjects, to_minima, parse=parseTestObject)

    check origTestObjects == to_recovered

  test "test errors":

    let wa_diff = newDiff(origWrappingA, newWrappingA)
    let wa_minima = wa_diff.outputMinimaStr()
    let wb_diff = newDiff(origWrappingB, newWrappingB)
    let wb_minima = wb_diff.outputMinimaStr()

    expect IndexError:
      let wa_recovered_new = recoverNewFromMinima(newWrappingA, wa_minima, parse=parsestr)

    expect IndexError:
      let wb_recovered_orig = recoverOriginalFromMinima(origWrappingB, wb_minima, parse=parsestr)
