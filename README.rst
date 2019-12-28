Introduction to diffoutput
==============================================================================
ver 0.1.1

.. image:: https://raw.githubusercontent.com/yglukhov/nimble-tag/master/nimble.png
   :height: 34
   :width: 131
   :alt: nimble
   :target: https://nimble.directory/pkg/diffoutput

.. image:: https://repo.support/img/rst-banner.png
   :height: 34
   :width: 131
   :alt: repo.support
   :target: https://repo.support/gh/JohnAD/diffoutput

This library provides a collection of supporting output methods for the
`diff <https://nimble.directory/pkg/diff>`_ library.

In addition to the ``diff`` library requirement that the sequences of ``T`` have
procedures supporting ``==`` and ``hash()``, this library also requires that
the sequences support stringification with ``$``. For the recovery procedures,
a parsing procedure is needed for converting the ``$`` string back into ``T``.



Table Of Contents
=================

1. `Introduction to diffoutput <https://github.com/JohnAD/diffoutput>`__
2. Appendices

    A. `diffoutput Reference <https://github.com/JohnAD/diffoutput/blob/master/docs/diffoutput-ref.rst>`__
