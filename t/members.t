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
use public;
use private;
use protected;
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
BEGIN { $Total_tests = 7 }


package Foo;

use public 		qw(Red Hate Airport);
use private   	qw(_What _No _Meep);
use protected 	qw(Northwest _puke _42 23);


package main;

# Check we got all the fields.
::ok( eqarray( [sort keys %Foo::FIELDS],
			   [sort qw(Red Hate Airport
						_What _No _Meep
						Northwest _puke _42 23)]
			 )
	);

use Class::Fields::Inheritance qw(:Attribs %attr);

# Check public fields
::ok( !(grep { !($attr{Foo}[$Foo::FIELDS{$_}-1] & _PUBLIC) } 
		qw(Red Hate Airport)) 
	);

# Check private fields
::ok( !(grep { !($attr{Foo}[$Foo::FIELDS{$_}-1] & _PRIVATE) } 
		qw(_What _No _Meep)) 
	);

# Check protected fields
::ok( !(grep { !($attr{Foo}[$Foo::FIELDS{$_}-1] & _PROTECTED) }
		qw(Northwest _puke _42 23))
	);


# Test inheritance of protected fields.
package Bar;

use fields qw(Hey _ar);
use base qw(Foo);


package main;

::ok( eqarray( [sort keys %Bar::FIELDS],
			   [sort qw(Hey _ar Red Hate Airport Northwest _puke _42 23)] 
			 )
	);


# Test warnings about poorly named data members.
my $w;
BEGIN {
	$SIG{__WARN__} = sub {
		if ($_[0] =~ /^Use of leading underscores to name public data fields is considered unwise/ or
		    $_[0] =~ /^Private data fields should be named with a leading underscore/) {
			$w++;
		}
		else {
			print $_[0];
		}
	};
}

package Ick;

use public qw(Yo roo _uh_oh ok_ay);
use protected qw(Find _no_problem);
use private qw(_roof _PANTS 42 oops);

::ok( $w == 3 );
