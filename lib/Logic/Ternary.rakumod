enum Logic::Ternary (
	False   => -1,
	Unknown =>  0,
	True    => +1,
);

BEGIN {
	Logic::Ternary.^add_method: "is-true",    my method is-true    { self >  0 }
	Logic::Ternary.^add_method: "is-false",   my method is-false   { self <  0 }
	Logic::Ternary.^add_method: "is-unknown", my method is-unknown { self == 0 }

	Logic::Ternary.^add_multi_method: "ACCEPTS", my method ACCEPTS(
		Logic::Ternary:D:
		Logic::Ternary:D $other
	) { self == $other }

	Logic::Ternary.^add_method: "not", my method not(--> Logic::Ternary) { (-1 * self).Ternary }

	Logic::Ternary.^add_method: "so", my method so { self }

	Logic::Ternary.^add_method: "Bool", my method Bool { $.is-true }
}

multi prefix:<so3>($value) is export { $value.Ternary.so }

multi prefix:<not3>($value) is export { $value.Ternary.not }

multi infix:<and3>($a, $b) is export { $a.Ternary min $b.Ternary }

multi infix:<or3>($a, $b) is export { $a.Ternary max $b.Ternary }

multi infix:<xor3>($a is copy, $b is copy) is export {
	$a .= Ternary;
	$b .= Ternary;
	($a or3 $b) and3 not3 ($a and3 $b)
}


use MONKEY-TYPING;
augment class Any {
	proto method Ternary(--> Logic::Ternary) { * }
	multi method Ternary(::?CLASS:U:) { Logic::Ternary::Unknown }
	multi method Ternary(::?CLASS:D:) { Logic::Ternary::Unknown }
	multi method Ternary(Numeric:D:)  {
		return Logic::Ternary::Unknown if self == 0;
		given self / self.abs {
			when * < 0 { Logic::Ternary::False }
			when * > 0 { Logic::Ternary::True  }
			default { die "Error converting {self} to ternary" }
		}
	}
}
augment class Int {
	multi method defined(Logic::Ternary::Unknown:) { self }
}

augment class Bool {
	method Ternary {
		return Logic::Ternary::Unknown without self;
		self ?? Logic::Ternary::True !! Logic::Ternary::False
	}
}

=begin pod

=head1 NAME

Logic::Ternary — Ternary logic for Raku

=head1 SYNOPSIS

=begin code :lang<raku>
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
=end code

=head1 DESCRIPTION

Logic::Ternary implements a three-valued logic for Raku:
=item C<True> (+1),
=item C<Unknown> (0),
=item and C<False> (-1).

Values are C<Logic::Ternary::True>, C<Logic::Ternary::Unknown>, and
C<Logic::Ternary::False>.

=item Predicates: C<.is-true>, C<.is-false>, C<.is-unknown>.
=item Negation: C<not3 $x>.
=item Booleanization: C<Bool($x)> is true only when C<$x> is C<True>.
=begin item
Coercion: C<Numeric.Ternary> maps:
=item negatives→C<False>,
=item zero→C<Unknown>,
=item positives→C<True>;
C<Bool.Ternary> preserves C<True/False> and yields C<Unknown> when undefined.
=end item

=head2 Operators

These operators always coerce both operands with C<.Ternary>:

=item C<and3>: ternary conjunction.
=item C<or3>: ternary disjunction.
=item C<xor3>: defined as C<(A or3 B) and3 not3(A and3 B)>.
=item C<not3>: negation.
=item C<so3>: ternarisation.

=head2 Quick examples

=begin code :lang<raku>
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
=end code

=head1 AUTHOR

Fernando Corrêa de Oliveira <fco@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2025 Fernando Corrêa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
