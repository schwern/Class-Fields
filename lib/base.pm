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

Will also initialize the %FIELDS hash if one or more of the base
classes has it using all public and protected data members of the base
classes.  Multiple Inheritance is supported.  If two or more base
classes each wish to endow the same fields, the 'base' pragma will
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

=head1 SEE ALSO

L<fields>, L<public>, L<protected>

=cut

package base;
use vars qw($VERSION);
$VERSION = "1.90";

use constant SUCCESS => 1;

sub import {
    my $class = shift;

	return SUCCESS unless @_;

	# List of base classes from which we will inherit %FIELDS.
	my @fields_bases = ();

    my $inheritor = caller(0);

    foreach my $base (@_) {
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
        my $fglob;
        if ($fglob = ${"$base\::"}{"FIELDS"} and *$fglob{HASH}) {
            push @fields_bases, $base;
		}
    }

    if( @fields_bases ) {
		require Class::Fields::Inheritance;
		Class::Fields::Inheritance::inherit($inheritor, @fields_bases);
	}

    push @{"$inheritor\::ISA"}, @_;
}

1;
