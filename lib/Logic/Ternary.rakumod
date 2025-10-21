sub EXPORT(*@options --> Map()) {
	my Bool $export = True;
	if @options == 1 {
		if @options[0] eq "none" {
			$export  = False;
			@options = ();
		} elsif @options[0] eq "True" {
			@options = <True Unknown False>;
		} elsif @options[0] eq "True3" {
			@options = <True3 Unknown3 False3>;
		} elsif @options[0] eq "KnownTrue" {
			@options = <KnownTrue Unknown KnownFalse>;
		}
	}
	@options = <True Unknown False> unless @options;
	class Logic::Ternary { ... }

	multi infix:<cmp>(Logic::Ternary $a, Logic::Ternary $b) is export { $a.Int cmp $b.Int }
	multi infix:<min>(Logic::Ternary $a, Logic::Ternary $b) is export { Logic::Ternary($a.Int min $b.Int) }
	multi infix:<max>(Logic::Ternary $a, Logic::Ternary $b) is export { Logic::Ternary($a.Int max $b.Int) }

	multi prefix:<so3>(Logic::Ternary() $value) is export { $value }

	multi prefix:<not3>(Logic::Ternary() $value) is export { $value.not }

	multi infix:<and3>(Logic::Ternary() $a, Logic::Ternary() $b) is export { $a min $b }

	multi infix:<or3>(Logic::Ternary() $a, Logic::Ternary() $b) is export { $a max $b }

	multi infix:<xor3>(Logic::Ternary() $a, Logic::Ternary() $b) is export {
		($a or3 $b) and3 not3 ($a and3 $b)
	}

	class Logic::Ternary does Enumeration {
		my %enumerations =
			@options[0] => +1,
			@options[1] =>  0,
			@options[2] => -1,
		;
		my %anti = %enumerations.antipairs;

		method new(Str:D $val where @options.one) {
			self.bless: key => $val, value => %enumerations{$val}
		}

		multi method CALL-ME($value) {
			my $key = do given $value {
				when $_ =:= True    {              +1 }
				when $_ =:= False   {              -1 }
				when !*.defined     {               0 }
				when $_ !~~ Numeric {  .so ?? 1 !! -1 }
				when 0              {               0 }
				when 0.0            {               0 }
				when 0e0            {               0 }
				when Numeric        { ($_ / .abs).Int }
				default             {  .so ?? 1 !! -1 }
			}
			::?CLASS.new: %anti{$key}
		}

		method ^enum_from_value($, $value) { ::?CLASS.CALL-ME: $value }

		method is-true    { self >  0 }
		method is-false   { self <  0 }
		method is-unknown { self == 0 }

		multi method ACCEPTS( ::?CLASS:D: ::?CLASS:D $other ) { self == $other }

		method not(--> ::?CLASS) { Logic::Ternary((-1 * self).Int) }

		method so { self }

		method Bool {
			return Bool without self;
			$.is-true
		}

		multi method Int(::?CLASS:D:) { $.value }

		proto method COERCE($)                    {                    * }
		multi method COERCE(Bool:D $ where *.so ) {            self.(+1) }
		multi method COERCE(Bool:D $ where *.not) {            self.(-1) }
		multi method COERCE(Bool:U)               {            self.( 0) }
		multi method COERCE(Numeric $a)           {            self.($a) }
		multi method COERCE(Any $a)               { self.COERCE($a.Bool) }

		method defined {
			return Bool::False unless self.DEFINITE;
			self !~~ Logic::Ternary::<Unknown>
		}
	}

	use MONKEY-TYPING;
	augment class Any {
		method Ternary(--> Logic::Ternary()) { self }
	}

	Logic::Ternary::{@options[0]} = Logic::Ternary.new: @options[0];
	Logic::Ternary::{@options[1]} = Logic::Ternary.new: @options[1];
	Logic::Ternary::{@options[2]} = Logic::Ternary.new: @options[2];

	|(
		|(
			@options[0] => Logic::Ternary::{@options[0]},
			@options[1] => Logic::Ternary::{@options[1]},
			@options[2] => Logic::Ternary::{@options[2]},
		) if $export;
	),

	'&infix:<cmp>'   => &infix:<cmp>  ,
	'&infix:<min>'   => &infix:<min>  ,
	'&infix:<max>'   => &infix:<max>  ,

	'&infix:<and3>'  => &infix:<and3> ,
	'&infix:<or3>'   => &infix:<or3>  ,
	'&infix:<xor3>'  => &infix:<xor3> ,

	'&prefix:<so3>'  => &prefix:<so3> ,
	'&prefix:<not3>' => &prefix:<not3>,
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
