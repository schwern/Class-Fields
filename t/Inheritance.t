# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)
use strict;

use vars qw($Total_tests);

my $loaded;
my $test_num = 1;
BEGIN { $| = 1; $^W = 1; }
END {print "not ok $test_num\n" unless $loaded;}
print "1..$Total_tests\n";
use Class::Fields::Inheritance;
$loaded = 1;
print "ok $test_num\n";
$test_num++;
######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):
sub ok {
	my($test, $name) = shift;
	print "not " unless $test;
	print "ok $test_num";
	print " - $name" if defined $name;
	print "\n";
	$test_num++;
}

sub eqarray  {
	my($a1, $a2) = @_;
	return 0 unless @$a1 == @$a2;
	my $ok = 1;
	for (0..$#{$a1}) { 
	    unless($a1->[$_] eq $a2->[$_]) {
		$ok = 0;
		last;
	    }
	}
	return $ok;
}

# Change this to your # of ok() calls + 1
BEGIN { $Total_tests = 11 }

package Foo;

use Class::Fields::Inheritance;

# Check that the attributes exported okay.
::ok( Class::Fields::Inheritance::_PRIVATE 	== _PRIVATE );
::ok( Class::Fields::Inheritance::_PUBLIC  	== _PUBLIC );
::ok( Class::Fields::Inheritance::_INHERITED 	== _INHERITED );
::ok( Class::Fields::Inheritance::_PROTECTED	== _PROTECTED );


package Bar;

use Class::Fields::Inheritance qw(:Inherit :Attribs);
BEGIN {
	add_fields('Yar', _PUBLIC, 		qw(Pub Pants));
	add_fields('Yar', _PRIVATE, 	qw(_Priv _Pantaloons));
	add_fields('Yar', _PROTECTED,	qw(_Prot Armoured));
}
::ok( ::eqarray([sort keys %Yar::FIELDS], 
				[sort qw(Pub Pants _Priv _Pantaloons _Prot Armoured)] 
			   ) 
	);

my Yar $yar = [];

eval {
	$yar->{Pub} 	= "Foo";
	$yar->{_Priv} 	= "Bar";
	$yar->{Armoured} = "Hey";
};
::ok($@ eq '' or $@ !~ /no such field/i);


BEGIN {
	inherit('Pants', 'Yar');
}

::ok( ::eqarray([sort keys %Pants::FIELDS], 
				[sort qw(Pub Pants _Prot Armoured)] 
			   ) 
	);

# Can't use compile time (my Pants) because then eval won't catch
# the error (it won't be run time)
my $trousers = bless [\%Pants::FIELDS], 'Pants';

eval {
	$trousers->{Pub} 		= "Whatver";
	$trousers->{Pants} 		= "This too";
	$trousers->{_Prot} 		= "Hey oh";
	$trousers->{Armoured}	= 4;
};
::ok($@ eq '' or $@ !~ /no such field/i);

eval {
	$trousers->{_Priv} = "Yarrow";
};
::ok($@ =~ /no such( \w+)? field/i);

eval {
	$trousers->{_Pantaloons} = "Yarrow";
};
::ok($@ =~ /no such( \w+)? field/i);






