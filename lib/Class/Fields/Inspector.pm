package Class::Fields::Inspector;

use strict;

use vars qw(@ISA @EXPORT);

$VERSION = 0.01;

# is_* will push themselves onto @EXPORT

use Class::Fields qw(:Attribs :Fields);


# Mapping of attribute names to their internal values.
my %NAMED_ATTRIBS = (
					 Public 	=> 	PUBLIC,
					 Private	=> 	PRIVATE,
					 Inherited	=>	INHERITED,
					 Protected	=>	PROTECTED,
					);

=pod

=head1 NAME

Class::Fields::Inspector - Inspect the fields of a class.


=head1 SYNOPSIS

    use Class::Fields::Inspector;

    is_public	($class, $field);
    is_private	($class, $field);
    is_protected($class, $field);
    is_inherited($class, $field);

    @fields = show_fields($class, @attribs);

    $attrib 	= field_attrib_mask($class, $field);
    @attribs	= field_attribs($class, $field);

    dump_all_attribs(@classes);


    # All functions also work as methods.
    package Foo;
    use base qw( Class::Fields::Inspector );

    Foo->is_public($field);
    @fields = Foo->show_fields(@attribs);
    # ...etc...


=head1 DESCRIPTION

A collection of utility functions/methods for examining the data
fields of a class which uses the %FIELDS hash.

The functions in this module also serve double-duty as methods and can
be used that way by having your module inherit from it.  For example:

    package Foo;
    use base qw( Class::Fields::Inspector );
    use fields qw( this that _whatever );

    print "'_whatever' is a private data member of 'Foo'" if
        Foo->is_private('_whatever');

    # Let's assume we have a new() method defined for Foo, okay?
    $obj = Foo->new;
    print "'this' is a public data member of 'Foo'" if
        $obj->is_public('this');

=over 4

=item B<is_public>

=item B<is_private>

=item B<is_protected>

=item B<is_inherited>

  is_public($class, $field);
  is_private($class, $field);
  ...etc...
        or
  $obj->is_public($field);
        or
  Class->is_public($field);

A bunch of functions to quickly check if a given $field in a given $class
is of a given type.  For example...

  package Foo;
  use fields qw( Ford _Nixon );

  package Bar;
  use base qw(Foo);

  # This will print only 'Ford is public' because Ford is a public
  # field of the class Bar.  _Nixon is a private field of the class
  # Foo, but it is not inherited.
  print 'Ford is public' 		if is_public('Bar', 'Ford');
  print '_Nixon is inherited' 	if is_inherited('Foo', '_Nixon');


=cut

# Generate is_public, etc... from %NAMED_ATTRIBS For each attribute we
# generate a simple named closure.  Seemed the laziest way to do it,
# lets us update %NAMED_ATTRIBS without having to make a new function.
while( my($attrib, $attr_val) = each %NAMED_ATTRIBS ) {
	my $fname = 'is_'.lc $attrib;
	*{$fname} = sub {
		my($proto, $field) = @_;

		# So we can be called either as a function or a method from
		# a class name or an object.
		my($class) = ref $proto || $proto;
		my $fattrib = field_attrib_mask($class, $field);
		
		return $fattrib & $attr_val;
	};

	push @EXPORT, $fname;
}

=pod

=item B<show_fields>

  @all_fields	= show_fields($class);
  @fields 		= show_fields($class, @attribs);
        or
  @all_fields 	= $obj->show_fields;
  @fields		= $obj->show_fields(@attribs);
        or
  @all_fields	= Class->show_fields;
  @fields		= Class->show_fields(@attribs);

This will list all fields in a given $class that have the given set of
@attribs.  If @attribs is not given it will simply list all fields.

The currently available attributes are:
    Public, Private, Protected and Inherited

For example:

    package Foo;
    use fields qw(this that meme);

    package Bar;
    use base qw(Foo);
    use fields qw(salmon);

    # @fields contains 'that' and 'meme' since they are Public and
    # Inherited.  It doesn't contain 'salmon' since while it is Public
    # it is not Inherited.
    @fields = show_fields('Bar', qw(Private Inherited));

=cut

sub show_fields {
	my($proto, @attribs) = @_;

	# Allow its tri-nature.
	my($class) = ref $proto || $proto;

	my $fields	= \%{$class.'::FIELDS'};

	# Shortcut:  Return all fields if they don't specify a set of
	# attributes.
	return keys %$fields unless @attribs;
	
	# Figure out the bitmask for the attribute set they'd like.
	my $want_attr = 0;
	foreach my $attrib (@attribs) {
		unless( defined $NAMED_ATTRIBS{$attrib} ) {
			require Carp;
			Carp::croak("'$attrib' is not a valid field attribute");
		}
		$want_attr |= $NAMED_ATTRIBS{$attrib};
	}

	# Return all fields with the requested bitmask.
	my $fattr 	= get_attr($class);
	return grep { $fattr->[$fields->{$_}-1] & $want_attr } keys %$fields;
}

=pod

=item B<field_attrib_mask>

  $attrib = field_attrib_mask($class, $field);
        or
  $attrib = $obj->field_attrib_mask($field);
        or
  $attrib = Class->field_attrib_mask($field);

It will tell you the numeric attribute for the given $field in the
given $class.  $attrib is a bitmask which must be interpreted with
the PUBLIC, PRIVATE, etc... constants from Class::Fields.

field_attribs() is probably easier to work with in general.

=cut

sub field_attrib_mask {
	my($proto, $field) = @_;
	my($class) = ref $proto || $proto;
	my $fields 	= get_fields($class);
	my $fattr 	= get_attr($class);
	return $fattr->[$fields->{$field} - 1];
}

=pod

=item B<field_attribs>

  @attribs = field_attribs($class, $field);
        or
  @attribs = $obj->field_attribs($field);
        or
  @attribs = Class->field_attribs($field);

Exactly the same as field_attrib_mask(), except that instead of
returning a bitmask it returns a somewhat friendlier list of
attributes which are applied to this field.  For example...

  package Foo;
  use fields qw( yarrow );

  package Bar;
  use base qw(Foo);

  # @attribs will contain 'Public' and 'Inherited'
  @attribs = field_attribs('Bar', 'yarrow');

The attributes returned are the same as those taken by show_fields().

=cut

sub field_attribs {
	my($proto, $field) = @_;
	my($class) = ref $proto || $proto;

	my @attribs = ();
	my $attr_mask = field_attribs_mask($class, $field);
	
	while( my($attr_name, $attr_val) = each %NAMED_ATTRIBS ) {
		push @attribs, $attr_name if $attr_mask & $attr_val;
	}

	return @attribs;
}

=pod

=item B<dump_all_attribs>

  dump_all_attribs;
  dump_all_attribs(@classes);
        or
  Class->dump_all_attribs;
        or
  $obj->dump_all_attribs;

A debugging tool which simply prints to STDERR everything it can about
a given set of @classes in a relatively formated manner.

Alas, this function works slightly differently if used as a function
as opposed to a method:

When called as a function it will print out attribute information
about all @classes given.  If no @classes are given it will print out
the attributes of -every- class it can find that has attributes.

When uses as a method, it will print out attribute information for the
class or object which uses the method.  No arguments are accepted.

I'm not entirely happy about this split and I might change it in the
future.

=cut

# Backwards compatiblity.
*_dump = \&dump_all_attribs;

sub dump_all_attribs {
	my @classes = @_;

	# Everything goes to STDERR.
	my $old_fh = select(STDERR);

	# Disallow $obj->dump_all_attribs(@classes);  Too ambiguous to live.
	# Alas, I can't check for Class->dump_all_attribs(@classes).
	if ( @classes > 1 and ref $classes[0] ) {
		require Carp;
		Carp::croak('$obj->dump_all_attribs(@classes) is too ambiguous.  Use only as $obj->dump_all_attribs()');
	}

	# Allow $obj->dump_all_attribs; to work.
	$classes[0] = ref $classes[0] || $classes[0] if @classes == 1;

	# Have to do a little encapsulation breaking here.  Oh well, at least
	# its keeping it in the family.
	my @classes = sort keys %fields::attr unless @classes;

 	for my $class (@classes) {
		print "\n$class";
		if (@{"$class\::ISA"}) {
			print " (", join(", ", @{"$class\::ISA"}), ")";
		}
		print "\n";
		my $fields = get_fields($class);
		for my $f (sort {$fields->{$a} <=> $fields->{$b}} keys %$fields) {
			my $no = $fields->{$f};
			print "   $no: $f";
			print "\t(", join(", ", field_attribs($class, $f), ")");
			print "\n";
		}
	}
		
	select($old_fh);
}

=pod

=head1 AUTHOR

Michael G Schwern <schwern@pobox.com> with much code liberated from the
original fields.pm.


=head1 SEE ALSO

L<fields.pm>

=cut

return q|I'll get you next time, Gadget!|;
