# $Id$ 
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
use Class::Fields;
$loaded = 1;
print "ok $test_num - Compile\n";
$test_num++;
######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):
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
        unless($a1->[$_] eq $a2->[$_]) {
            $ok = 0;
            last;
        }
    }
    return $ok;
}

# Change this to your # of ok() calls + 1
BEGIN { $Total_tests = 23 }

package Foo;

use public      qw(this that);
use private     qw(_eep _orp);
use protected   qw(Pants _stuff);
use base qw( Class::Fields );

package Bar;

use base qw( Class::Fields Foo);

::ok( Foo->is_public('this'),           'Method:  is_public()'              );
::ok( !Foo->is_public('_stuff'),        'Method:  is_public(), false'       );
::ok( !Foo->is_public('fnord'),         'Method:  is_public(), no field'    );

::ok( Foo->is_private('_eep'),          'Method:  is_private()'             );
::ok( Foo->is_protected('_stuff'),      'Method:  is_protected()'           );
::ok( Bar->is_inherited('this'),        'Method:  is_inherited()'           );

::ok( Foo->is_field('_eep'),            'Method:  is_field()'               );
::ok( !Foo->is_field('fnord'),           'Method:  is_field(), false'       );

::ok( ::eqarray([ sort Foo->show_fields ], 
              [ sort qw(this that _eep _orp Pants _stuff) ]),
                                        'Method:  show_fields() all'        );
::ok( ::eqarray([ sort Bar->show_fields(qw(Inherited)) ], 
              [ sort qw(this that Pants _stuff) ]),
                                        'Method:  show_fields() Inherited'  );
::ok( ::eqarray([ sort Foo->show_fields('Public') ], 
              [ sort qw(this that) ]),
                                        'Method:  show_fields() Public'     );
::ok( ::eqarray([ sort Bar->show_fields('Public', 'Inherited') ], 
              [ sort qw(this that) ]),
                            'Method:  show_fields() Public & Inherited'     );
::ok( ::eqarray([ sort Foo->show_fields('Public', 'Inherited') ], 
              [ sort qw() ]),
                         'Method:  show_fields() Public & Inherited, empty' );


package main;
use Class::Fields;

::ok( is_public('Foo', 'this'),         'Function:  is_public()'            );
::ok( !is_public('Foo', '_stuff'),      'Function:  is_public(), false'     );
::ok( !is_public('Foo', 'fnord'),       'Function:  is_public(), no field'  );

::ok( is_private('Foo', '_eep'),        'Function:  is_private()'           );
::ok( is_protected('Foo', '_stuff'),    'Function:  is_protected()'         );

use Class::Fields::Attribs;
::ok( field_attrib_mask('Bar', 'Pants') == PROTECTED|INHERITED,
                                        'field_attrib_mask()'               );
::ok( ::eqarray([sort &field_attribs('Bar', 'Pants')],
                [sort qw(Protected Inherited)]),
                                        'field_attribs()'                   );

# Can't really think of a way to test dump_all_attribs().


# Make sure show_fields() doens't autovivify %FIELDS.
use Class::Fields::Fuxor;
::ok( !show_fields("I::have::no::FIELDS") );
::ok( !has_fields("I::have::no::FIELDS"),         "has_fields() autoviv bug" );
