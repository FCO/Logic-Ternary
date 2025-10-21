[![Actions Status](https://github.com/FCO/Logic-Ternary/actions/workflows/test.yml/badge.svg)](https://github.com/FCO/Logic-Ternary/actions)

NAME
====

Logic::Ternary — Ternary logic for Raku

SYNOPSIS
========

```raku
use Logic::Ternary;

my $t = True;
my $f = False;
my $u = Unknown;

# Negation
dd not3 $t;              # Logic::Ternary::False
dd not3 $u;              # Logic::Ternary::Unknown

# Conjunction/Disjunction/xor (operands are coerced to Ternary)
dd $t and3 $u;            # Logic::Ternary::Unknown
dd $t or3  $u;            # Logic::Ternary::True
dd $t xor3 $t;            # Logic::Ternary::False

# Coercions
dd  1 .Ternary;          # Logic::Ternary::True
dd -3 .Ternary;          # Logic::Ternary::False
dd  0 .Ternary;          # Logic::Ternary::Unknown
dd Bool::True.Ternary;   # Logic::Ternary::True
dd Bool.Ternary;         # Logic::Ternary::Unknown
```

DESCRIPTION
===========

Logic::Ternary implements a three-valued logic for Raku:

  * `True` (+1),

  * `Unknown` (0),

  * and `False` (-1).

Values are `Logic::Ternary::True`, `Logic::Ternary::Unknown`, and `Logic::Ternary::False`.

  * Predicates: `.is-true`, `.is-false`, `.is-unknown`.

  * Negation: `not3 $x`.

  * Booleanization: `Bool($x)` is true only when `$x` is `True`.

  * Coercion: `Numeric.Ternary` maps:

      * negatives→`False`,

      * zero→`Unknown`,

      * positives→`True`; `Bool.Ternary` preserves `True/False` and yields `Unknown` when undefined.

Operators
---------

These operators always coerce both operands with `.Ternary`:

  * `and3`: ternary conjunction.

  * `or3`: ternary disjunction.

  * `xor3`: defined as `(A or3 B) and3 not3(A and3 B)`.

  * `not3`: negation.

  * `so3`: ternarisation.

Quick examples
--------------

```raku
use Logic::Ternary;

my $u = Unknown;

# and3 behavior
dd $u and3 True;   # Logic::Ternary::Unknown
dd $u and3 False;  # Logic::Ternary::False

# or3 behavior
dd True or3 $u;    # Logic::Ternary::True
dd $u or3 False;   # Logic::Ternary::Unknown

# Mixed types are coerced
dd 1 and3 0;       # Logic::Ternary::Unknown
dd -2 or3  1;      # Logic::Ternary::True

dd not3 1;         # Logic::Ternary::False
```

Exports
-------

By default, `use Logic::Ternary;` exports the enum names

  * `True`,

  * `Unknown`,

  * `False`

and the operators:

  * `not3`,

  * `and3`,

  * `or3`,

  * `xor3`,

  * `so3`.

You can customize which enum names are exported by passing options to the `use` line:

  * Single shorthands:

      * `<True> ` — same as `<True Unknown False> `.

      * `<True3> ` — exports `<True3 Unknown3 False3> `.

      * `<KnownTrue> ` — exports `<KnownTrue Unknown KnownFalse> `.

  * Custom list: Provide three identifiers: `<Yes Maybe No> `.

  * None: `<none> ` disables exporting the enum names to the lexical scope; operators are still exported. Fully qualified enum values are always available under `Logic::Ternary::`.

```raku
use Logic::Ternary;                 # True/Unknown/False
use Logic::Ternary <True>;          # same as default
use Logic::Ternary <True3>;         # True3/Unknown3/False3
use Logic::Ternary <KnownTrue>;     # KnownTrue/Unknown/KnownFalse
use Logic::Ternary <Yes Maybe No>;  # custom names
use Logic::Ternary <none>;          # no constants; operators only
say (not3 1).Int;                   # -1
say Logic::Ternary::True.raku;      # 'Logic::Ternary::True'
```

AUTHOR
======

Fernando Corrêa de Oliveira <fco@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2025 Fernando Corrêa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

