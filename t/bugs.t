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
use base;
$loaded = 1;
print "ok $test_num - Compiled\n";
$test_num++;
######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):
sub ok ($$) {
    my($test, $name) = @_;
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
BEGIN { $Total_tests = 3 }


# Here we emulate a bug with base.pm not finding the Exporter version
# for some reason.
use lib qw(t);
use base qw(Dummy);

ok( $Dummy::VERSION == 5.562,       "base.pm doesn't confuse the version" );
                                  
    


# Test a bug reported by Pasha Sadri
# <NEBBIPJPBMMMDNHELFELOEEECHAA.pasha@yahoo-inc.com>

my $warnings;
BEGIN {
    $SIG{__WARN__} = sub { $warnings = join '', @_ };
}

package Foo;
use fields;
use protected qw(protected_f);


package Bar;
use public qw(f);
use base qw(Foo); # base comes after 'use public'


::ok( $warnings eq <<WARN,    'Improper use of fields & base warned about' );
Bar is inheriting from Foo but already has its own fields!
This will cause problems with pseudo-hashes.
Be sure you use base BEFORE declaring fields
WARN
