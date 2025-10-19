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
dd $t.not;               # Logic::Ternary::False
dd NOT($u);              # Logic::Ternary::Unknown

# Conjunction/Disjunction/XOR (use UPPERCASE)
dd $t AND $u;            # Logic::Ternary::Unknown
dd $t OR  $u;            # Logic::Ternary::True
dd $t XOR $t;            # Logic::Ternary::False

# Coercions
dd  1 .Ternary;          # Logic::Ternary::True
dd -3 .Ternary;          # Logic::Ternary::False
dd  0 .Ternary;          # Logic::Ternary::Unknown
dd Bool::True.Ternary;   # Logic::Ternary::True
dd Bool.Ternary;         # Logic::Ternary::Unknown

# Ternary defined-or fallback
dd $u // $t;             # Logic::Ternary::True
dd $f // $t;             # Logic::Ternary::False
```

DESCRIPTION
===========

Logic::Ternary implements a three-valued logic for Raku:

  * `True` (+1),

  * `Unknown` (0)

  * and `False` (-1).

The values are `Logic::Ternary::True`, `Logic::Ternary::Unknown` and `Logic::Ternary::False`.

  * Predicates: `.is-true`, `.is-false`, `.is-unknown`.

  * Negation: `NOT $x` or `$x.not`.

  * Booleanization: `Bool($x)` is true only when `$x` is `True`.

  * Coercion: `Numeric.Ternary` maps negatives→`False`, zero→`Unknown`, positives→`True`; `Bool.Ternary` preserves `True/False` and yields `Unknown` when undefined.

Operators
---------

Always use the UPPERCASE operators:

  * `AND`: ternary conjunction with appropriate semantics.

  * `OR`: ternary disjunction with appropriate semantics.

  * `XOR`: defined as `(A OR B) AND NOT(A AND B)`.

  * `.not` and `NOT`: negation.

  * `//`: ternary "defined-or": returns the right operand when the left is `Unknown` or a type object (uninstantiated).

Important: and/&&/or/||/xor/^^
------------------------------

The lowercase operators `and`, `&&`, `or`, `||`, `xor` and `^^` are likely not to work correctly with `Logic::Ternary`. The Raku parser gives those operators special short-circuit handling, which can bypass our multis and/or force early booleanization.

  * Prefer `AND`, `OR` and `XOR`.

  * I plan to address this with RakuAST in future versions so the lowercase counterparts can work transparently.

Quick examples
--------------

```raku
my $u = Logic::Ternary::Unknown;

# AND behavior
dd $u AND True;   # Logic::Ternary::Unknown
dd $u AND False;  # Logic::Ternary::False

# OR behavior
dd True OR $u;    # Logic::Ternary::True
dd $u OR False;   # Logic::Ternary::Unknown

# Smartmatch (~~)
dd True ~~ True;     # Bool::True
dd True ~~ Unknown;  # Bool::False
```

AUTHOR
======

Fernando Corrêa de Oliveira <fco@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2025 Fernando Corrêa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

