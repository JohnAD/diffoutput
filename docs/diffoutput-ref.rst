diffoutput Reference
==============================================================================

The following are the references for diffoutput.



Types
=====



.. _Markup.type:
Markup
---------------------------------------------------------

    .. code:: nim

        Markup* = object
          spanStart: string
          spanEnd: string
          tagEqualSymbol: string
          tagEqualStart: string
          tagEqualEnd: string
          tagInsertSymbol: string
          tagInsertStart: string
          tagInsertEnd: string
          tagDeleteSymbol: string
          tagDeleteStart: string
          tagDeleteEnd: string
          tagReplaceSymbol: string
          tagReplaceStart: string
          tagReplaceEnd: string
          contentStart: string
          contentEnd: string


    source line: `20 <../src/diffoutput.nim#L20>`__

    This object type is used to describe how the spans should be decorated
    with strings






Procs, Methods, Iterators
=========================


.. _outputMinimaStr.p:
outputMinimaStr
---------------------------------------------------------

    .. code:: nim

        proc outputMinimaStr*[T](d: Diff[T]): string =

    source line: `194 <../src/diffoutput.nim#L194>`__

    Generate a very small string easily parsed for later regeneration
    of the original or the updated document.
    
    Each sequence of action begins with a line number and then is followed
    by lines prefixed with either ``<`` or ``>`` for insertion or deletion
    repectively. Following that the ``$`` serialization is output followed by
    a carriage return (``\n``).
    
    For this function to work properly, the type T must have a ``$`` serialization
    that DOES NOT include a carriage return.
    
    .. code:: nim
    
       let a = ("Tulips are yellow,\nViolets are blue,\nAgar is sweet,\n" &
                "As are you.").split('\n')
       let b = ("Roses are red,\nViolets are blue,\nSugar is sweet,\n" &
                "And so are you.").split('\n')
       let d = newDiff(a, b)
       let s = outputMinimasStr(d)
       echo s
    
    which creates the following output:
    
    .. code:: text
    
        0,0
        <Tulips are yellow,
        >Roses are red,
        2,2
        <Agar is sweet,
        <As are you.
        >Sugar is sweet,
        >And so are you.
    


.. _outputSimpleStr.p:
outputSimpleStr
---------------------------------------------------------

    .. code:: nim

        proc outputSimpleStr*[T](d: Diff[T], markup=SimpleTextMarkup): string =

    source line: `80 <../src/diffoutput.nim#L80>`__

    Stringifies the diff as a series of lines prefixed with
    either a space, less-than, or greater-than symbol (or any other
    symbols chosen) followed by the string equivalant of the content.
    
    For ``tagReplace``, an equivalent delete is followed by an insert.
    
    This function only works if type [T] has a ``$`` stringify function.
    
    .. code:: text
    
        > new line one
          same a
          same b
        < removed line 1
        < removed line 2
        > line added at the end
    
    ``markup``: The tuple of strings used to "decorate" the series of lines. There
    is a constant called CommonHTMLMarkup available for use with web pages.


.. _outputUnixDiffStr.p:
outputUnixDiffStr
---------------------------------------------------------

    .. code:: nim

        proc outputUnixDiffStr*[T](d: Diff[T]): string =

    source line: `139 <../src/diffoutput.nim#L139>`__

    generates a string document is identical to the output generated
    by the unix ``diff`` command.
    
    details:
    
    * http://man7.org/linux/man-pages/man1/diff.1.html
    * https://www.computerhope.com/unix/udiff.htm


.. _recoverNewFromMinima.p:
recoverNewFromMinima
---------------------------------------------------------

    .. code:: nim

        proc recoverNewFromMinima*[T](a: seq[T], minima: string, parse: (string) -> T): seq[T] =

    source line: `250 <../src/diffoutput.nim#L250>`__

    Using the original sequence and a "minima" diff string, generate
    the new sequence described by the minima string.
    
    For this function to work properly, the seq type T must have a ``parse``
    serialization procedure.
    
    Example of use:
    
    .. code:: nim
    
       proc parse(source: string): string =
         result = source
    
       let a = ("Tulips are yellow,\nViolets are blue,\nAgar is sweet,\n" &
                "As are you.").split('\n')
       let b = ("Roses are red,\nViolets are blue,\nSugar is sweet,\n" &
                "And so are you.").split('\n')
       let d = newDiff(a, b)
       let s = outputMinimasStr(d)
    
       recoveredB = recoverNewFromMinima(a, s)
    
       assert b[0] == recoveredB[0]
       assert b[1] == recoveredB[1]
       assert b[2] == recoveredB[2]
       assert b[3] == recoveredB[3]
    


.. _recoverOriginalFromMinima.p:
recoverOriginalFromMinima
---------------------------------------------------------

    .. code:: nim

        proc recoverOriginalFromMinima*[T](b: seq[T], minima: string, parse: (string) -> T): seq[T] =

    source line: `308 <../src/diffoutput.nim#L308>`__

    Using the original sequence and a "minima" diff string, generate
    the new sequence described by the minima string.
    
    For this function to work properly, the seq type T must have a ``parse``
    serialization procedure.
    
    Example of use:
    
    .. code:: nim
    
       proc parse(source: string): string =
         result = source
    
       let a = ("Tulips are yellow,\nViolets are blue,\nAgar is sweet,\n" &
                "As are you.").split('\n')
       let b = ("Roses are red,\nViolets are blue,\nSugar is sweet,\n" &
                "And so are you.").split('\n')
       let d = newDiff(a, b)
       let s = outputMinimasStr(d)
    
       recoveredB = recoverNewFromMinima(a, s)
    
       assert b[0] == recoveredB[0]
       assert b[1] == recoveredB[1]
       assert b[2] == recoveredB[2]
       assert b[3] == recoveredB[3]
    







Table Of Contents
=================

1. `Introduction to diffoutput <https://github.com/JohnAD/diffoutput>`__
2. Appendices

    A. `diffoutput Reference <diffoutput-ref.rst>`__
