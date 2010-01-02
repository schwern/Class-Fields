# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

$SIG{__WARN__} = sub { return if $_[0] =~ /^Pseudo-hashes are deprecated/ };

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
use fields;
$loaded = 1;
ok(1, 'compile');
######################### End of black magic.

# Utility testing functions.
sub ok {
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
        my($e1,$e2) = ($a1->[$_], $a2->[$_]);
        unless($e1 eq $e2) {
            if( UNIVERSAL::isa($e1, 'ARRAY') and 
                UNIVERSAL::isa($e2, 'ARRAY') ) 
            {
                $ok = eqarray($e1, $e2);
            }
            else {
                $ok = 0;
            }
            last unless $ok;
        }
    }
    return $ok;
}

# Change this to your # of ok() calls + 1
BEGIN { $Total_tests = 4 }

# Test the example from the Class::Fields man page.

package Test::Autoload::Example;

use base qw(Class::Fields);
use public  qw(this that up down);
use private qw(_left _right);
use fields;

use vars qw($AUTOLOAD);
{
    no strict 'refs';

    sub AUTOLOAD {
        my $self = $_[0];
        my $class = ref $self;

        my($field) = $AUTOLOAD =~ /::([^:]+)$/;

        return if $field eq 'DESTROY';

        # If its a public field, set up a named closure as its
        # data accessor.
        if ( $self->is_public($field) ) {
            *{$class."::$field"} = sub {
                my($self) = shift;
                if (@_) {
                    $self->{$field} = shift;
                }
                return $self->{$field};
            };
            goto &{$class."::$field"};
        } else {
            die "'$field' is not a public data member of '$class'";
        }
    }
}

my $obj = fields::new(__PACKAGE__);
$obj->this(42);
::ok( $obj->this == 42 );
::ok( $obj->{this} == 42 );

eval {
    $obj->_left;
};
::ok( scalar $@ =~ /^'_left' is not a public data member of 'Test::Autoload::Example'/ );
