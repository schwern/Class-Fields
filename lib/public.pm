package public;

use strict;

use vars qw($VERSION);

$VERSION = 0.02;

use Class::Fields qw(:Attribs :Fields);

sub import {
	#Dump the class.
	shift;
	
	my $pack = caller;
	foreach my $field (@_) {
		if( $field =~ /^_/ ) {
			require Carp;
		 	Carp::carp("Use of leading underscores to name public data ",
		 			   "fields is considered unwise.") if $^W;
		}
	}
	add_fields($pack, PUBLIC, @_);
}


return 'Do not forget to **enjoy the path**';
