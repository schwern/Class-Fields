package public;

use strict;

use vars qw($VERSION);

$VERSION = 0.01;

use Class::Fields::Inheritance qw(:Attribs :Inherit);

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
	add_fields($pack, _PUBLIC, @_);
}


return 'Do not forget to **enjoy the path**';
