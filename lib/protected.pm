=head1 NAME

protected - "private" data fields which are inherited by child classes


=head1 SYNOPSIS

	package Foo;
	use fields qw(foo bar _private)
	use protected qw(_pants _spoon);
	
	sub squonk {
		my($self) = shift;
		$self->{_pants} = 'Infinite Trousers';
		$self->{_spoon} = 'What stirs me, stirs everything';
		...
	}
	
	package Bar;
	# Inherits foo, bar, this and _that
	use base qw(Foo);
	...
	
	package Harfurfar;
	my Bar $bar = Bar->new;
	$bar->squonk;  # This works because Foo::squonk() uses _pants and
				   # _spoon, which are inherited by Bar.

	

=head1 DESCRIPTION

The C<protected> module implements something like Protected data
members you might find in a language with a more traditional OO
implementation such as C++.

Protected data members are similar to private ones with the notable
exception in that they are inherited by subclasses.  This is useful
where you have private information which would be useful for
subclasses to know as well.

For example: A class which stores an object in a database might have a
protected member "_Changed" to keep track of changes to the object so
it does not have to waste time re-writing the entire thing to disk.
Subclasses of this obviously need a _Changed field as well, but it
would be breaking encapsilation if the author had to remember to "use
fields qw(_Changed)" (Assuming, of course, they're using fields and
not just a plain hash.  In which case forget this whole module.)


=head2 The Camel Behind The Curtain

In reality, there is no difference between a "protected" variable and
a "public" on in Perl.  The only real difference is that the protected
module doesn't care what the field is called (ie. if it starts with an
underscore or not) whereas fields uses the name to determine if the
variable is public or private (ie. inherited or not).


=head1 AUTHOR

Michael G Schwern <schwern@pobox.com>


=head1 SEE ALSO

L<public>, L<private>, L<fields>, L<Class::Fields>, L<base>


=cut

package protected;

use strict;

use vars qw($VERSION);

$VERSION = 0.02;

use Class::Fields qw(:Attribs :Fields);

sub import {
	#Dump the class.
	shift;
	
	my $package = caller;
	add_fields($package, PROTECTED, @_);
}

return 'I like traffic lights';
