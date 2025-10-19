enum Logic::Ternary (
	False   => -1,
	Unknown =>  0,
	True    => +1,
);

BEGIN {
	Logic::Ternary.^add_multi_method: "gist",    my multi method gist(Logic::Ternary:D:)    {
		self > 0
			?? "True"
			!! self < 0
				?? "False"
				!! "Unknown"
	}

	Logic::Ternary.^add_multi_method: "raku",    my multi method raku(Logic::Ternary:D:)    {
		$.gist
	}

	Logic::Ternary.^add_method: "is-true",    my method is-true    { self >  0 }
	Logic::Ternary.^add_method: "is-false",   my method is-false   { self <  0 }
	Logic::Ternary.^add_method: "is-unknown", my method is-unknown { self == 0 }

	Logic::Ternary.^add_multi_method: "ACCEPTS", my method ACCEPTS(
		Logic::Ternary:D:
		Logic::Ternary:D $other
	) {
		when $.is-true    &&  $other.is-true    { Bool::True  }
		when $.is-true    && !$other.is-true    { Bool::False }
		when $.is-false   &&  $other.is-false   { Bool::True  }
		when $.is-false   && !$other.is-false   { Bool::False }
		when $.is-unknown &&  $other.is-unknown { Bool::True  }
		when $.is-unknown && !$other.is-unknown { Bool::False }
	}

	Logic::Ternary.^add_method: "not", my method not(--> Logic::Ternary) {
		when $.is-true    { Logic::Ternary::False   }
		when $.is-unknown { Logic::Ternary::Unknown }
		when $.is-false   { Logic::Ternary::True    }
	}

	Logic::Ternary.^add_method: "so", my method so { self }

	Logic::Ternary.^add_method: "Bool", my method Bool { $.is-true }
}

multi so(Logic::Ternary $value) is export { $value.so }
multi SO(Logic::Ternary $value) is export { $value.so }

multi NOT(Logic::Ternary $value) is export { $value.not }
multi not(Logic::Ternary $value) is export { $value.not }
multi prefix:<!>(Logic::Ternary $value) is export { $value.not }

multi infix:<AND>(Logic::Ternary $a, Logic::Ternary $b) is export { $a min $b }
multi infix:<and>(Logic::Ternary $a, Logic::Ternary $b) is export { $a AND $b }
multi infix:<&&>(Logic::Ternary $a,  Logic::Ternary $b) is export { $a AND $b }

multi infix:<AND>(Logic::Ternary::Unknown $a,  $b where *.so ) is export { $a }
multi infix:<AND>(Logic::Ternary::Unknown $a,  $b where *.not) is export { $b }
multi infix:<AND>(Logic::Ternary::True  $a, $b) is export { $b }
multi infix:<AND>(Logic::Ternary::False $a, $b) is export { $a }

multi infix:<and>(Logic::Ternary $a, $b) is export { $a AND $b }
multi infix:<&&>(Logic::Ternary  $a, $b) is export { $a AND $b }

multi infix:<AND>($a where *.so , Logic::Ternary $b) is export { $b }
multi infix:<AND>($a where *.not, Logic::Ternary $b) is export { $a }

multi infix:<and>($a, Logic::Ternary $b) is export { $a AND $b }
multi infix:<&&>( $a, Logic::Ternary $b) is export { $a AND $b }

#########################

multi infix:<OR>(Logic::Ternary $a, Logic::Ternary $b) is export { $a max $b }
multi infix:<or>(Logic::Ternary $a, Logic::Ternary $b) is export { $a OR $b }
multi infix:<||>(Logic::Ternary $a, Logic::Ternary $b) is export { $a OR $b }

multi infix:<OR>(Logic::Ternary::Unknown $a, $b ) is export { $a }
multi infix:<OR>(Logic::Ternary::True  $a, $b) is export { $a }
multi infix:<OR>(Logic::Ternary::False $a, $b) is export { $b }

multi infix:<or>(Logic::Ternary $a, $b) is export { $a AND $b }
multi infix:<||>(Logic::Ternary $a, $b) is export { $a AND $b }

multi infix:<OR>($a where *.so , Logic::Ternary $b) is export { $a }
multi infix:<OR>($a where *.not, Logic::Ternary $b) is export { $b }

multi infix:<or>($a, Logic::Ternary $b) is export { $a AND $b }
multi infix:<||>( $a, Logic::Ternary $b) is export { $a AND $b }

###############################

multi infix:<XOR>(Logic::Ternary $a, Logic::Ternary $b) is export { ($a OR $b) AND NOT($a AND $b) }
multi infix:<xor>(Logic::Ternary $a, Logic::Ternary $b) is export { $a XOR $b }
multi infix:<^^>(Logic::Ternary $a,  Logic::Ternary $b) is export { $a XOR $b }

###############################
#
multi infix:<//>(Logic::Ternary::Unknown $a, $b) is export { $b }
multi infix:<//>(Logic::Ternary:U $a, $b) is export { $b }
multi infix:<//>(Logic::Ternary $a, $b) is export { $a }

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
=end code

=head1 DESCRIPTION

Logic::Ternary implements a three-valued logic for Raku:
C<True> (+1), C<Unknown> (0) and C<False> (-1). The values are
C<Logic::Ternary::True>, C<Logic::Ternary::Unknown> and
C<Logic::Ternary::False>.

- Predicates: C<.is-true>, C<.is-false>, C<.is-unknown>.
- Negation: C<NOT $x> or C<$x.not>.
- Booleanization: C<Bool($x)> is true only when C<$x> is C<True>.
- Coercion: C<Numeric.Ternary> maps negatives→C<False>, zero→C<Unknown>, positives→C<True>; C<Bool.Ternary> preserves C<True/False> and yields C<Unknown> when undefined.

=head2 Operators

Always use the UPPERCASE operators:

- C<AND>: ternary conjunction with appropriate semantics.
- C<OR>: ternary disjunction with appropriate semantics.
- C<XOR>: defined as C<(A OR B) AND NOT(A AND B)>.
- C<!> and C<NOT>: negation.
- C<//>: ternary "defined-or": returns the right operand when the left is C<Unknown> or a type object (uninstantiated).

=head2 Important: and/&&/or/||/xor/^^

The lowercase operators C<and>, C<&&>, C<or>, C<||>, C<xor> and C<^^>
are likely not to work correctly with C<Logic::Ternary>. The Raku parser
gives those operators special short-circuit handling, which can bypass our
multis and/or force early booleanization.

- Prefer C<AND>, C<OR> and C<XOR>.
- I plan to address this with RakuAST in future versions so the lowercase
  counterparts can work transparently.

=head2 Quick examples

=begin code :lang<raku>
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
=end code

=head1 AUTHOR

Fernando Corrêa de Oliveira <fco@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2025 Fernando Corrêa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
