package private;

use strict;

use vars qw($VERSION);

$VERSION = 0.02;

use Class::Fields qw(:Attribs :Fields);

sub import {
	#Dump the class.
	shift;
	
	my $pack = caller;
	foreach my $field (@_) {
		unless( $field =~ /^_/ ) {
			require Carp;
		 	Carp::carp("Private data fields should be named with a ",
		 			   "leading underscore") if $^W;
		}
	}
	add_fields($pack, PRIVATE, @_);
}


return 'pants of infinity';
__END__
=pod

=head1 NAME

  private - Add private data members to Perl classes


=head1 SYNOPSIS

  package GI::Joe;

  use private qw( _SexualPrefs _IsSpy );


=head1 DESCRIPTION

private.pm adds a list of keys as private data members to the current
class.  See L<public> for more info.

Private data members are those pieces of data which are expected to be
only accessed by methods of the class which owns them.  They are not
inherited by subclasses.

private.pm serves a subset of the functionality of fields.pm.

  use private qw(_Foo);

is almost exactly the same as:

  use fields qw(_Foo);

with the exception that you can (if you REALLY want to) do something
like this:

  use private qw(Foo);

Whereas one cannot do this with fields.pm. (Note: This is considered
unwise and private.pm will scream about it if you have Perl's warnings
on.)

Additionally, private.pm is a bit clearer in its intent and is not
necessarily implying use of pseudo-hashes.


=head1 MUSINGS

I fully expect private.pm to eventually mutate into a real pragma
someday when a better formalized OO data system for Perl supplants the
current fledgling pseudo-hashes.

=head1 HISTORY

This module was added as of version 5.6

=head1 AUTHOR

Michae G Schwern <schwern@pobox.com>

=head1 SEE ALSO

L<public>, L<protected>, L<fields>, L<base>, L<Class::Fields::Inspector>

=cut
