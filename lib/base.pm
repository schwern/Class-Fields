package base;

use vars qw($VERSION);
$VERSION = '1.95';

use constant SUCCESS => (1==1);
use constant FAILURE => !SUCCESS;

# Since loading Class::Fields::Fuxor unnecessarily is considered
# inefficient, we define our own has_fields() to work with.
sub has_fields {
    my($proto) = shift;
    my($class) = ref $proto || $proto;
    my $fglob;
    return $fglob = ${"$class\::"}{"FIELDS"} and *$fglob{HASH};
}


sub import {
    my $class = shift;

    return SUCCESS unless @_;

    # List of base classes from which we will inherit %FIELDS.
    my $fields_base;

    my $inheritor = caller(0);

    foreach my $base (@_) {
        next if $inheritor->isa($base);

        push @{"$inheritor\::ISA"}, $base;

        unless (exists ${"$base\::"}{VERSION}) {
            eval "require $base";
            # Only ignore "Can't locate" errors from our eval require.
            # Other fatal errors (syntax etc) must be reported.
            die if $@ && $@ !~ /^Can't locate .*? at \(eval /; #'#
            unless (%{"$base\::"}) {
                require Carp;
                Carp::croak("Base class package \"$base\" is empty.\n",
                            "\t(Perhaps you need to 'use' the module ",
                            "which defines that package first.)");
            }
            ${"$base\::"}{VERSION} = "-1, set by base.pm"
              unless exists ${"$base\::"}{VERSION};
        }

        # A simple test like (defined %{"$base\::FIELDS"}) will
        # sometimes produce typo warnings because it would create
        # the hash if it was not present before.
        #
        # We don't just check to see if the base in question has %FIELDS
        # defined, we also check to see if it has -inheritable- fields.
        # Its perfectly alright to inherit from multiple classes that have 
        # %FIELDS as long as only one of them has fields to give.
        if ( has_fields($base) ) {
	    require Class::Fields;

	    # Check to see if there are fields to be inherited.
	    if ( Class::Fields::show_fields($base, 'Public') or
		 Class::Fields::show_fields($base, 'Protected') ) {

		# No multiple fields inheritence *suck*
		if ($fields_base) {
		    require Carp;
		    Carp::croak("Can't multiply inherit %FIELDS");
		} else {
		    $fields_base = $base;
		}
	    }
        }
    }

    if( defined $fields_base ) {
	require Class::Fields::Inherit;
        Class::Fields::Inherit::inherit_fields($inheritor, $fields_base);
    }
}

1;

__END__

=head1 NAME

base - Establish IS-A relationship with base class at compile time

=head1 SYNOPSIS

    package Baz;
    use base qw(Foo Bar);

=head1 DESCRIPTION

Roughly similar in effect to

    BEGIN {
        require Foo;
        require Bar;
        push @ISA, qw(Foo Bar);
    }

Will also initialize the %FIELDS hash if one of the base classes has
it using all public and protected data members of the base classes.
Multiple Inheritence of fields is B<NOT> supported.  If two or more
base classes each have inheritable fields the 'base' pragma will
croak.  See L<fields>, L<public> and L<protected> for a description of
this feature.

When strict 'vars' is in scope I<base> also lets you assign to @ISA
without having to declare @ISA with the 'vars' pragma first.

If any of the base classes are not loaded yet, I<base> silently
C<require>s them.  Whether to C<require> a base class package is
determined by the absence of a global $VERSION in the base package.
If $VERSION is not detected even after loading it, <base> will
define $VERSION in the base package, setting it to the string
C<-1, defined by base.pm>.

=head1 HISTORY

This module was introduced with Perl 5.004_04.


=head1 NOTE

This is the base.pm which was installed as part of the Class::Fields
package.  B<NOT> the base.pm which is distributed with Perl.  This
version should safely emulate everything that 5.6.0's base.pm does.
It passes all of 5.6.0's regression tests.

It should also work under 5.005_03, although if you're going to be
screwing around with pseudohashes you really should upgrade to 5.6.0.

=head1 SEE ALSO

L<fields>, L<public>, L<protected>, L<protected>, L<Class::Fields>

=cut
