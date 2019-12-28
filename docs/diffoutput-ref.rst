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


    source line: `21 <../src/diffoutput.nim#L21>`__

    This object type is used to describe how spans should be decorated
    with strings
    
    Two constants are available as examples: ``SimpleTextMarkup`` and
    ``CommonHTMLMarkup``






Procs, Methods, Iterators
=========================


.. _outputMinimaStr.p:
outputMinimaStr
---------------------------------------------------------

    .. code:: nim

        proc outputMinimaStr*[T](d: Diff[T]): string =

    source line: `210 <../src/diffoutput.nim#L210>`__

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

    source line: `84 <../src/diffoutput.nim#L84>`__

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
    
    The general order the elements are:
    
    * ``spanStart``
    * ``tag{Equal,Insert,Delete}Start``
    * ``tag{Equal,Insert,Delete}Symbol``
    * ``contentStart``
    * *content of span*
    * ``contentEnd``
    * ``tag{Equal,Insert,Delete}End``
    * ``spanEnd``


.. _outputUnixDiffStr.p:
outputUnixDiffStr
---------------------------------------------------------

    .. code:: nim

        proc outputUnixDiffStr*[T](d: Diff[T]): string =

    source line: `154 <../src/diffoutput.nim#L154>`__

    generates a string document that is identical to the output generated
    by the unix ``diff`` command. At least in format; subtle algorithmic
    quirks may show different ways to express the same differences.
    
    reference:
    
    * man page: http://man7.org/linux/man-pages/man1/diff.1.html
    * https://www.computerhope.com/unix/udiff.htm


.. _recoverNewFromMinima.p:
recoverNewFromMinima
---------------------------------------------------------

    .. code:: nim

        proc recoverNewFromMinima*[T](a: seq[T], minima: string, parse: (string) -> T): seq[T] =

    source line: `266 <../src/diffoutput.nim#L266>`__

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

    source line: `324 <../src/diffoutput.nim#L324>`__

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
