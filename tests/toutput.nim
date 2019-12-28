# Copyright © 2019-20 Mark Summerfield. All rights reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may only use this file in compliance with the License. The license
# is available from http://www.apache.org/licenses/LICENSE-2.0

import hashes
import strutils
import unittest

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

let exampleA = ("Tulips are yellow,\nViolets are blue,\nAgar is sweet,\n" &
                "As are you.").split('\n')
let exampleB = ("Roses are red,\nViolets are blue,\nSugar is sweet,\n" &
                "And so are you.").split('\n')

suite "output tests":

  test "outputSimpleStr":
    let diff = newDiff(original, newdoc)
    let textOutput = diff.outputSimpleStr()

    check textOutput == """> This is an important
> notice! It should
> therefore be located at
> the beginning of this
> document!
> 
  This part of the
  document has stayed the
  same from version to
  version.  It shouldn't
  be shown if it doesn't
  change.  Otherwise, that
  would not be helping to
  compress the size of the
  changes.
  
< This paragraph contains
< text that is outdated.
< It will be deleted in the
< near future.
< 
  It is important to spell
< check this dokument. On
> check this document. On
  the other hand, a
  misspelled word isn't
  the end of the world.
  Nothing in the rest of
  this paragraph needs to
  be changed. Things can
  be added after it.
  
> This paragraph contains
> important new additions
> to this document.
> 
"""

    let htmlOutput = diff.outputSimpleStr(markup=CommonHTMLMarkup)

    check htmlOutput == """<span class="diff-insert">&gt;&nbsp;This is an important</span><br/>
<span class="diff-insert">&gt;&nbsp;notice! It should</span><br/>
<span class="diff-insert">&gt;&nbsp;therefore be located at</span><br/>
<span class="diff-insert">&gt;&nbsp;the beginning of this</span><br/>
<span class="diff-insert">&gt;&nbsp;document!</span><br/>
<span class="diff-insert">&gt;&nbsp;</span><br/>
<span class="diff-equal">&nbsp;&nbsp;This part of the</span><br/>
<span class="diff-equal">&nbsp;&nbsp;document has stayed the</span><br/>
<span class="diff-equal">&nbsp;&nbsp;same from version to</span><br/>
<span class="diff-equal">&nbsp;&nbsp;version.  It shouldn't</span><br/>
<span class="diff-equal">&nbsp;&nbsp;be shown if it doesn't</span><br/>
<span class="diff-equal">&nbsp;&nbsp;change.  Otherwise, that</span><br/>
<span class="diff-equal">&nbsp;&nbsp;would not be helping to</span><br/>
<span class="diff-equal">&nbsp;&nbsp;compress the size of the</span><br/>
<span class="diff-equal">&nbsp;&nbsp;changes.</span><br/>
<span class="diff-equal">&nbsp;&nbsp;</span><br/>
<span class="diff-delete">&lt;&nbsp;This paragraph contains</span><br/>
<span class="diff-delete">&lt;&nbsp;text that is outdated.</span><br/>
<span class="diff-delete">&lt;&nbsp;It will be deleted in the</span><br/>
<span class="diff-delete">&lt;&nbsp;near future.</span><br/>
<span class="diff-delete">&lt;&nbsp;</span><br/>
<span class="diff-equal">&nbsp;&nbsp;It is important to spell</span><br/>
<span class="diff-delete">&lt;&nbsp;check this dokument. On</span><br/>
<span class="diff-insert">&gt;&nbsp;check this document. On</span><br/>
<span class="diff-equal">&nbsp;&nbsp;the other hand, a</span><br/>
<span class="diff-equal">&nbsp;&nbsp;misspelled word isn't</span><br/>
<span class="diff-equal">&nbsp;&nbsp;the end of the world.</span><br/>
<span class="diff-equal">&nbsp;&nbsp;Nothing in the rest of</span><br/>
<span class="diff-equal">&nbsp;&nbsp;this paragraph needs to</span><br/>
<span class="diff-equal">&nbsp;&nbsp;be changed. Things can</span><br/>
<span class="diff-equal">&nbsp;&nbsp;be added after it.</span><br/>
<span class="diff-equal">&nbsp;&nbsp;</span><br/>
<span class="diff-insert">&gt;&nbsp;This paragraph contains</span><br/>
<span class="diff-insert">&gt;&nbsp;important new additions</span><br/>
<span class="diff-insert">&gt;&nbsp;to this document.</span><br/>
<span class="diff-insert">&gt;&nbsp;</span><br/>
"""

  test "outputUnixDiffStr":
    let diff = newDiff(original, newdoc)
    let diffOutput = diff.outputUnixDiffStr()

    check diffOutput == """0a1,6
> This is an important
> notice! It should
> therefore be located at
> the beginning of this
> document!
> 
11,15d16
< This paragraph contains
< text that is outdated.
< It will be deleted in the
< near future.
< 
17c18
< check this dokument. On
---
> check this document. On
25a27,30
> This paragraph contains
> important new additions
> to this document.
> 
"""

  test "outputMinimasStr":
    let diff = newDiff(original, newdoc)
    let diffOutput = diff.outputMinimaStr()

    check diffOutput == """0,0
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

    let exampleDiff = newDiff(exampleA, exampleB)
    let exampleOutput = exampleDiff.outputMinimaStr()

    check exampleOutput == """0,0
<Tulips are yellow,
>Roses are red,
2,2
<Agar is sweet,
<As are you.
>Sugar is sweet,
>And so are you.
"""
