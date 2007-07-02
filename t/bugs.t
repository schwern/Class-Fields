#!/usr/bin/perl -w

use strict;
use Test::More tests => 2;


# Here we emulate a bug with base.pm not finding the Exporter version
# for some reason.
use lib qw(t);
use base qw(Dummy);

is( $Dummy::VERSION, 5.562,       "base.pm doesn't confuse the version" );


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


::like( $warnings, <<'WARN', 'Improper use of fields & base warned about' );
/^Bar is inheriting from Foo but already has its own fields!
This will cause problems.*
Be sure you use base BEFORE declaring fields/
WARN
