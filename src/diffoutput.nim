# Copyright © 2019-20 John Dupuy. All rights reserved.
# Licensed under the MIT License (the "License");

{.experimental: "codeReordering".}

## This library provides a collection of supporting output methods for the
## `diff <https://nimble.directory/pkg/diff>`_ library.
##
## In addition to the ``diff`` library requirement that the sequences of ``T`` have
## procedures supporting ``==`` and ``hash()``, this library also requires that
## the sequences support stringification with ``$``. For the recovery procedures,
## a parsing procedure is needed for converting the ``$`` string back into ``T``.

import sets
import sugar
import tables
import strutils
import diff

type
  Markup* = object
    ## This object type is used to describe how spans should be decorated
    ## with strings
    ##
    ## Two constants are available as examples: ``SimpleTextMarkup`` and
    ## ``CommonHTMLMarkup``
    spanStart*: string
    spanEnd*: string
    tagEqualSymbol*: string
    tagEqualStart*: string
    tagEqualEnd*: string
    tagInsertSymbol*: string
    tagInsertStart*: string
    tagInsertEnd*: string
    tagDeleteSymbol*: string
    tagDeleteStart*: string
    tagDeleteEnd*: string
    tagReplaceSymbol*: string
    tagReplaceStart*: string
    tagReplaceEnd*: string
    contentStart*: string
    contentEnd*: string


const 
  SimpleTextMarkup* = Markup(
                              spanStart: "",
                              spanEnd: "\n",
                              tagEqualSymbol: " ",
                              tagEqualStart: "",
                              tagEqualEnd: "",
                              tagInsertSymbol: ">",
                              tagInsertStart: "",
                              tagInsertEnd: "",
                              tagDeleteSymbol: "<",
                              tagDeleteStart: "",
                              tagDeleteEnd: "",
                              tagReplaceSymbol: "$",
                              tagReplaceStart: "",
                              tagReplaceEnd: "",
                              contentStart: " ",
                              contentEnd: ""
                            )
  CommonHTMLMarkup* = Markup(
                              spanStart: "",
                              spanEnd: "<br/>\n",
                              tagEqualSymbol: "&nbsp;",
                              tagEqualStart: "<span class=\"diff-equal\">",
                              tagEqualEnd: "</span>",
                              tagInsertSymbol: "&gt;",
                              tagInsertStart: "<span class=\"diff-insert\">",
                              tagInsertEnd: "</span>",
                              tagDeleteSymbol: "&lt;",
                              tagDeleteStart: "<span class=\"diff-delete\">",
                              tagDeleteEnd: "</span>",
                              tagReplaceSymbol: "",
                              tagReplaceStart: "",
                              tagReplaceEnd: "",
                              contentStart: "&nbsp;",
                              contentEnd: ""
                            )


proc outputSimpleStr*[T](d: Diff[T], markup=SimpleTextMarkup): string =
  ## Stringifies the diff as a series of lines prefixed with
  ## either a space, less-than, or greater-than symbol (or any other
  ## symbols chosen) followed by the string equivalant of the content.
  ##
  ## For ``tagReplace``, an equivalent delete is followed by an insert.
  ##
  ## This function only works if type [T] has a ``$`` stringify function.
  ##
  ## .. code:: text
  ##
  ##     > new line one
  ##       same a
  ##       same b
  ##     < removed line 1
  ##     < removed line 2
  ##     > line added at the end
  ##
  ## ``markup``: The tuple of strings used to "decorate" the series of lines. There
  ## is a constant called CommonHTMLMarkup available for use with web pages.
  ##
  ## The general order the elements are:
  ##
  ## * ``spanStart``
  ## * ``tag{Equal,Insert,Delete}Start``
  ## * ``tag{Equal,Insert,Delete}Symbol``
  ## * ``contentStart``
  ## * *content of span*
  ## * ``contentEnd``
  ## * ``tag{Equal,Insert,Delete}End``
  ## * ``spanEnd``
  result = ""
  for span in d.spans:
    case span.tag:
    of tagEqual:
      for entry in d.a[span.aStart ..< span.aEnd]:
        result &= markup.spanStart
        result &= markup.tagEqualStart & markup.tagEqualSymbol
        result &= markup.contentStart & $entry & markup.contentEnd
        result &= markup.tagEqualEnd
        result &= markup.spanEnd
    of tagInsert:
      for entry in d.b[span.bStart ..< span.bEnd]:
        result &= markup.spanStart
        result &= markup.tagInsertStart & markup.tagInsertSymbol
        result &= markup.contentStart & $entry & markup.contentEnd
        result &= markup.tagInsertEnd
        result &= markup.spanEnd
    of tagDelete:
      for entry in d.a[span.aStart ..< span.aEnd]:
        result &= markup.spanStart
        result &= markup.tagDeleteStart & markup.tagDeleteSymbol
        result &= markup.contentStart & $entry & markup.contentEnd
        result &= markup.tagDeleteEnd
        result &= markup.spanEnd
    of tagReplace:
      for entry in d.a[span.aStart ..< span.aEnd]:
        result &= markup.spanStart
        result &= markup.tagDeleteStart & markup.tagDeleteSymbol
        result &= markup.contentStart & $entry & markup.contentEnd
        result &= markup.tagDeleteEnd
        result &= markup.spanEnd
      for entry in d.b[span.bStart ..< span.bEnd]:
        result &= markup.spanStart
        result &= markup.tagInsertStart & markup.tagInsertSymbol
        result &= markup.contentStart & $entry & markup.contentEnd
        result &= markup.tagInsertEnd
        result &= markup.spanEnd


proc outputUnixDiffStr*[T](d: Diff[T]): string =
  ## generates a string document that is identical to the output generated
  ## by the unix ``diff`` command. At least in format; subtle algorithmic
  ## quirks may show different ways to express the same differences.
  ##
  ## reference:
  ##
  ## * man page: http://man7.org/linux/man-pages/man1/diff.1.html
  ## * https://www.computerhope.com/unix/udiff.htm
  # note:
  #   diff entries start at 1 not 0
  proc ex(s, e: int): string =
    # if s and e are the same, print one number, otherwise two seperated by comma
    if s == e:
      result = $s
    else:
      result = "$1,$2".format(s, e)
  #
  result = ""
  var lastValue = ""
  for span in d.spans:
    case span.tag:
    of tagEqual:
      for entry in d.b[span.bStart ..< span.bEnd]:
        lastValue = $entry
    of tagInsert:
      let line = span.aStart + 1 - 1  # need line _before_ insertion
      let firstline = span.bStart + 1
      let lastline = span.bEnd        # last line, not line-after; so don't offset
      result &= "$1a$2\n".format(line, ex(firstline, lastline))
      for entry in d.b[span.bStart ..< span.bEnd]:
        result &= "> $1\n".format($entry)
        lastValue = $entry
    of tagDelete:
      let firstline = span.aStart + 1
      let lastline = span.aEnd + 1 - 1
      let lineup = span.bStart
      result &= "$1d$2\n".format(ex(firstline, lastline), lineup)
      for entry in d.a[span.aStart ..< span.aEnd]:
        result &= "< $1\n".format($entry)
    of tagReplace:
      let aStart = span.aStart + 1
      let aStop = span.aEnd
      let bStart = span.bStart + 1
      let bStop = span.bEnd
      result &= "$1c$2\n".format(ex(aStart, aStop), ex(bStart, bStop))
      for entry in d.a[span.aStart ..< span.aEnd]:
        result &= "< $1\n".format($entry)
      result &= "---\n"
      for entry in d.b[span.bStart ..< span.bEnd]:
        result &= "> $1\n".format($entry)
        lastValue = $entry
  if len(lastValue) > 0:
    result &= "\\ No newline at end of file\n"


proc outputMinimaStr*[T](d: Diff[T]): string =
  ## Generate a very small string easily parsed for later regeneration
  ## of the original or the updated document.
  ##
  ## Each sequence of action begins with a line number and then is followed
  ## by lines prefixed with either ``<`` or ``>`` for insertion or deletion
  ## repectively. Following that the ``$`` serialization is output followed by
  ## a carriage return (``\n``).
  ##
  ## For this function to work properly, the type T must have a ``$`` serialization
  ## that DOES NOT include a carriage return.
  ##
  ## .. code:: nim
  ##
  ##    let a = ("Tulips are yellow,\nViolets are blue,\nAgar is sweet,\n" &
  ##             "As are you.").split('\n')
  ##    let b = ("Roses are red,\nViolets are blue,\nSugar is sweet,\n" &
  ##             "And so are you.").split('\n')
  ##    let d = newDiff(a, b)
  ##    let s = outputMinimasStr(d)
  ##    echo s
  ##
  ## which creates the following output:
  ##
  ## .. code:: text
  ##
  ##     0,0
  ##     <Tulips are yellow,
  ##     >Roses are red,
  ##     2,2
  ##     <Agar is sweet,
  ##     <As are you.
  ##     >Sugar is sweet,
  ##     >And so are you.
  ##
  result = ""
  for span in d.spans:
    case span.tag:
    of tagEqual:
      discard
    of tagInsert:
      result &= "$1,$2\n".format(span.aStart, span.bStart)
      for entry in d.b[span.bStart ..< span.bEnd]:
        result &= ">$1\n".format($entry)
    of tagDelete:
      result &= "$1,$2\n".format(span.aStart, span.bStart)
      for entry in d.a[span.aStart ..< span.aEnd]:
        result &= "<$1\n".format($entry)
    of tagReplace:
      result &= "$1,$2\n".format(span.aStart, span.bStart)
      for entry in d.a[span.aStart ..< span.aEnd]:
        result &= "<$1\n".format($entry)
      for entry in d.b[span.bStart ..< span.bEnd]:
        result &= ">$1\n".format($entry)


proc recoverNewFromMinima*[T](a: seq[T], minima: string, parse: (string) -> T): seq[T] =
  ## Using the original sequence and a "minima" diff string, generate
  ## the new sequence described by the minima string.
  ##
  ## For this function to work properly, the seq type T must have a ``parse``
  ## serialization procedure.
  ##
  ## Example of use:
  ##
  ## .. code:: nim
  ##
  ##    proc parseStr(source: string): string =
  ##      result = source
  ##    
  ##    let a = ("Tulips are yellow,\nViolets are blue,\nAgar is sweet,\n" &
  ##             "As are you.").split('\n')
  ##    let b = ("Roses are red,\nViolets are blue,\nSugar is sweet,\n" &
  ##             "And so are you.").split('\n')
  ##    let d = newDiff(a, b)
  ##    let s = outputMinimasStr(d)
  ##
  ##    recoveredB = recoverNewFromMinima(a, s, parse=parseStr)
  ##
  ##    assert b[0] == recoveredB[0]
  ##    assert b[1] == recoveredB[1]
  ##    assert b[2] == recoveredB[2]
  ##    assert b[3] == recoveredB[3]
  ##
  result = @[]
  var lineA = 0
  var lineB = 0
  let mseq = minima.split("\n")
  for mop in mseq:
    if mop.startsWith(">"):
      if mop.len > 1:
        result.add parse(mop[1 .. mop.high])
      else:
        result.add parse("")
    elif mop.startsWith("<"):
      lineA += 1
    elif mop == "":  # empty lines should not happen, but just skip them if seen
      discard
    else:
      # anything other than < or > is a new line indicator
      let lines = mop.split(",")
      let nextA = parseInt(lines[0])
      let nextB = parseInt(lines[1])
      # jump ahead to the new location
      for i in lineA ..< nextA:
        result.add a[i]
      lineA = nextA
      lineB = nextB
  # append any remains from original not deleted by diff
  if lineA < a.len:
    for entry in a[lineA .. a.high]:
      result.add entry


proc recoverOriginalFromMinima*[T](b: seq[T], minima: string, parse: (string) -> T): seq[T] =
  ## Using the original sequence and a "minima" diff string, generate
  ## the new sequence described by the minima string.
  ##
  ## For this function to work properly, the seq type T must have a ``parse``
  ## serialization procedure.
  ##
  ## Example of use:
  ##
  ## .. code:: nim
  ##
  ##    proc parseStr(source: string): string =
  ##      result = source
  ##    
  ##    let a = ("Tulips are yellow,\nViolets are blue,\nAgar is sweet,\n" &
  ##             "As are you.").split('\n')
  ##    let b = ("Roses are red,\nViolets are blue,\nSugar is sweet,\n" &
  ##             "And so are you.").split('\n')
  ##    let d = newDiff(a, b)
  ##    let s = outputMinimasStr(d)
  ##
  ##    recoveredA = recoverOriginalFromMinima(b, s, parse = parseStr)
  ##
  ##    assert a[0] == recoveredA[0]
  ##    assert a[1] == recoveredA[1]
  ##    assert a[2] == recoveredA[2]
  ##    assert a[3] == recoveredA[3]
  ##
  result = @[]
  var lineA = 0
  var lineB = 0
  let mseq = minima.split("\n")
  for mop in mseq:
    if mop.startsWith(">"):
      lineB += 1
    elif mop.startsWith("<"):
      if mop.len > 1:
        result.add parse(mop[1 .. mop.high])
      else:
        result.add parse("")
    elif mop == "":  # empty lines should not happen, but just skip them if seen
      discard
    else:
      # anything other than < or > is a new line indicator
      let lines = mop.split(",")
      let nextA = parseInt(lines[0])
      let nextB = parseInt(lines[1])
      # jump ahead to the new location
      for i in lineB ..< nextB:
        result.add b[i]
      lineA = nextA
      lineB = nextB
  # append any remains from original not deleted by diff
  if lineB < b.len:
    for entry in b[lineB .. b.high]:
      result.add entry

