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
