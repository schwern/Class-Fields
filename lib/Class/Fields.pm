package Class::Fields;

use strict;
no strict 'refs';
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);

$VERSION = 0.03;

require Exporter;
@ISA = qw(Exporter);

use constant SUCCESS	=> 1;				
use constant FAILURE 	=> !SUCCESS;

=pod

=head1 NAME

  Class::Fields - Manipulating %FIELDS

=head1 SYNOPSIS

  # As functions.
  use Class::Fields qw(:Fields);
  add_fields($class, $attrib, @fields);
  has_fields($class);
  $fields = get_fields($class);
  $fattr  = get_attr($class);

  # This gives you the constants PUBLIC PRIVATE INHERITED and PROTECTED
  use Class::Fields qw(:Attribs);


  # As methods.
  package Foo;
  use base qw( Class::Fields );

  Foo->add_fields($attrib, @fields);
  Foo->has_fields;
  $fields 	= Foo->get_fields;
  $fattr	= Foo->get_attr;
  

=head1 DESCRIPTION

This is a module for low level manipuation of the %FIELDS hash and its
accompying %attr hash.  Typically one does not want to mess with this
stuff and instead uses fields.pm and friends or perhaps
Class::Fields::Inspector.

=cut

%EXPORT_TAGS = (
				'Attribs' 	=> [qw( PUBLIC PRIVATE INHERITED PROTECTED )],
				'Fields'	=> [qw( add_fields has_fields get_fields get_attr 
								  )],
			   );
Exporter::export_ok_tags(qw( Attribs Fields ));

# Inheritance constants.
use constant PUBLIC 	=> 2**0;	# Open to the public, will be inherited.
use constant PRIVATE   	=> 2**1;	# Not to be used by anyone but that class, 
                                    # will not be inherited
use constant INHERITED	=> 2**2;	# This member was inherited
use constant PROTECTED	=> 2**3;	# Not to be used by anyone but that class 
                                    # and its subclasses, will be inherited.

# For backwards compatibility.
# contant.pm doesn't like leading underscores.  Damn.
sub _PUBLIC 	() { PUBLIC 	}
sub _PRIVATE	() { PRIVATE 	}
sub _INHERITED	() { INHERITED	}
sub _PROTECTED	() { PROTECTED	}

# The %attr hash holds the attributes of the currently assigned fields
# per class.  The hash is indexed by class names and the hash value is
# an array reference.  The array is indexed with the field numbers
# (minus one) and the values are integer bit masks (or undef).  The
# size of the array also indicates the next field index to assign for
# additional fields in this class.
#
# BTW %attr is part of fields for legacy reasons.  We alias it here to make
# life easier.
use vars qw(%attr);
*attr = \%fields::attr;

=pod

=item B<add_fields>

  add_fields($class, $attrib, @fields);

Adds a bunch of @fields to the given $class using the given $attrib.
For example:

    # Add the public fields 'this' and 'that' to the class Foo.
    add_fields('Foo', PUBLIC, qw(this that));

This 90% of fields.pm, public.pm, etc...

=cut

sub add_fields {
	# Read the first two parameters.  The rest are field names.
	my($proto, $attrib) = splice(@_, 0, 2);
	my($class) = ref $proto || $proto;
	
	# Quick bail out if nothing is to be added.
	return SUCCESS unless @_;
	
	my $fields = \%{"$class\::FIELDS"};
	() = \%{"$class\::FIELDS"};  # Shut up a typo warning if %FIELDS
	                               # doesn't already exist.
    my $fattr = ($attr{$class} ||= []);

	foreach my $f (@_) {
		if (my $fno = $fields->{$f}) {
	    	require Carp;
			if ($fattr->[$fno-1] & INHERITED) {
				Carp::carp("Hides field '$f' in base class") if $^W;
            } else {
                Carp::croak("Field name '$f' already in use");
            }
		}
		$fields->{$f} = @$fattr + 1;
        push(@$fattr, $attrib);
    }
}

=pod

=item B<has_fields>

  has_fields($class);

A simple check to see if the given $class has a %FIELDS hash defined.
A simple test like (defined %{"$class\::FIELDS"}) will sometimes
produce typo warnings because it would create the hash if it was not
present before.

=cut

sub has_fields {
	my($proto) = shift;
	my($class) = ref $proto || $proto;
	my $fglob;
	return $fglob = ${"$class\::"}{"FIELDS"} and *$fglob{HASH};
}

=pod

=item B<get_attr>

  $fattr = get_attr($class);

Get's the field attribute array for the given $class.  This is roughly
equivalent to $fields::attr{$class} but we put a nice wrapper around
it for compatibility and readability.

$fattr is an array reference containing the attributes of the fields
in the given $class.  Each entry in $fattr corresponds to the position
indicated by the $class's %FIELDS has.  For example:

    package Foo;
    use fields qw(this _that);

    $fattr = get_attr('Foo');

    # Get the attributes for '_that' in the class 'Foo'.
    $that_attribs = print $fattr->[$Foo::FIELDS->{_that}];

=cut

sub get_attr {
	my($proto) = shift;
	my($class) = ref $proto || $proto;
	return $attr{$class};
}

=pod

=item B<get_fields>

  $fields = get_fields($class);

Gets a reference to the %FIELDS hash for the given $class.

=cut

sub get_fields {
	my($proto) = shift;
	my($class) = ref $proto || $proto;
	
	if( has_fields($class) ) {
		return \%{$class.'::FIELDS'};
	}
	else {
		return FAILURE;
	}
}

=pod

=head1 AUTHOR

Michael G Schwern <schwern@pobox.com> based heavily on code liberated
from the original fields.pm and base.pm.


=head1 SEE ALSO

L<fields>, L<base>, L<public>, L<private>, L<protected>,
L<Class::Fields::Inspector>

=cut

return 'Maybe we should have stopped with Smalltalk.';
