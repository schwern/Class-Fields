package fields;

use 5.005;
use strict;
no strict 'refs';
use vars qw($VERSION);

use Class::Fields::Fuxor;
use Class::Fields::Attribs;
use Carp::Assert;

use constant SUCCESS => 1;

$VERSION = "0.14";

sub import {
    my($class, @fields) = @_;
    
    my $package = caller(0);
    
    return SUCCESS unless @fields;

    my @attribs = ();
    foreach my $field (@fields) {
        my $attr = ($field =~ /^_/) ? PRIVATE : PUBLIC;

        push @attribs, $attr;
    }

    assert(@fields == @attribs) if DEBUG;

    # Can't use add_fields() since fields.pm needs them all at once
    # for magical reasons.  Also preserves field ordering.
    add_field_set($package, \@fields, \@attribs);
}

=pod

=head1 NAME

fields - compile-time class fields

=head1 SYNOPSIS

  package Foo;
  use fields qw(foo bar _Foo_private);

  sub new {
      my $proto = shift;
      my $class = ref $proto || $proto;
      
      my Foo $self = fields::new($class);

      $self->{_Foo_private} = "this is Foo's secret";
      $self->{foo} = 'everybody knows';
      $self->{bar} = 'an open bar';

      return $self;
  }

  my Foo $foo_obj = Foo->new;
  $foo_obj->{foo} = 42;

  # This will generate a compile-time error.  zap is not a
  # public field of Foo.
  $foo_obj->{zap} = 42;


  # subclassing
  package Bar;
  use base 'Foo';
  use fields qw(baz _Bar_private);  # fields not shared with foo.

  sub new {
      my $proto = shift;
      $self = $proto->SUPER::new;  # call Foo's new()

      $self->{baz} = 'and stuff';  # initialize my own fields.
      $self->{_Bar_private} = 'our little secret';

      return $self;
  }


=head1 DESCRIPTION

The C<fields> pragma enables compile-time verified class fields.

NOTE: The current implementation keeps the declared fields in the %FIELDS
hash of the calling package, but this may change in future versions.
Do B<not> update the %FIELDS hash directly, because it must be created
at compile-time for it to be fully useful, as is done by this pragma.

If a typed lexical variable (my Dog $spot) holding a reference is used
to access a hash element and a package/class with the same name as the
type has declared class fields using this pragma, then the operation
is turned into an array access at compile time.
(L<perlref/"Pseudo-hashes: Using an array as a hash">)

The relatied C<base> pragma will combine fields from base classes and
any fields declared using the C<fields> pragma.  This enables field
inheritance to work properly.

Field names that start with an underscore character are made private
to a class and are not visible to subclasses.  Inherited fields can be
overridden but will generate a warning if used together with the C<-w>
switch.

The effect of all this is that you can have objects with named fields
which are as compact and as fast arrays to access.  This only works as
long as the objects are accessed through properly typed variables.  If
the objects are not typed, access is only checked at run-time and
performance may suffer a bit.

=head2 Functions

=over 4

=item B<new>

  $obj = fields::new($class);
  $obj = fields::new($another_obj);

fields::new() creates and blesses a pseudo-hash comprised of the
fields declared using the C<fields> pragma into the specified class.
This makes it possible to write a constructor like this:

    package Critter::Sounds;
    use fields qw(cat dog bird);

    sub new {
        my $proto = shift;
        my $class = ref $proto || $proto;

        my Critter::Sounds $self = fields::new($class);

        %$self = (
                  cat     => 'meow',
                  dog     => 'bark',
                  dogcow  => 'moof',
                 );
        
        return $self;
    }

=cut

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;
    return bless [\%{$class . "::FIELDS"}], $class;
}

=pod

=item B<phash>

    $phash = fields::phash;
    $phash = fields::phash(\@keys);
    $phash = fields::phash(\@keys, \@values);
    $phash = fields::phash(%hash);

fields::phash() can be used to create and initialize a plain
(unblessed) pseudo-hash.  It is prefered that this function be used
instead of creating pseudo-hashes directly.

If no arguments are given the resulting pseudohash will be empty and
have no fields.

The optional @keys will be used to initialize the keys/fields of the
resulting hash.  @values, also optional, will be used as the values
for each key.  If @values contains less elements than @keys, the
trailing elements of the pseudo-hash will not be initialized.  If
there are more @values than @keys the function will throw a warning
(it may die in the future).

This makes it particularly useful for creating a pseudo-hash from
subroutine arguments.

    sub dogtag {
        my $tag = fields::phash([qw(name rank serial_num)], [@_]);
    }

fields::phash() also accepts a plain %hash used to construct the
pseudo-hash.  Examples:

    my $tag = fields::phash(name       => 'Kirk',
                            rank       => 'Captain',
                            serial_num => 42
                           );

    my $phash = fields::phash(%args);

=cut

sub phash {
    my $keys = {};
    my $values = [];

    if( ref $_[0] ) {   # Called as phash(\@keys, \@values)
        my($keys_in, $vals_in) = @_;

        @{$keys}{@$keys_in} = 1..@$keys_in;
        $values = $vals_in if defined $vals_in;

        if( @_ > 2 ) {      # sanity check
            require Carp;
            Carp::croak("Expected at most two array refs.");
        }
    }
    else {
        if( @_ % 2 ) {
            require Carp;
            Carp::croak("Odd number of elements initializing pseudo-hash.");
        }

        my $i = 0;
        @$keys{grep ++$i %2, @_} = 1 .. @_ / 2;

        $i = 0;
        $values = [grep $i++ % 2, @_];
    }

    # Make sure we didn't get too many values.
    if( @$values > keys %$keys ) {
        require Carp;
        Carp::carp("More values than keys were given.");
    }
    
    return [$keys, @$values];
}

=pod

=back

=head1 SEE ALSO

L<base>, L<public>, L<private>, L<protected>, L<Class::Fields>
L<perlref/"Pseudo-hashes: Using an array as a hash">

=head1 B<NOTE>

This is the version of fields.pm which comes with Class::Fields.  NOT
the version which is distributed with Perl.  This version should
safely emulate everything that perl 5.6.0's fields.pm does.  It passes
all of 5.6.0's regression tests.

It should also work under 5.005_03, although if you're going to be
screwing around with pseudohashes you really should upgrade to 5.6.0.

=head1 AUTHOR

Michael G Schwern <schwern@pobox.com>.  fields::new(), fields::phash()
and most of the documentation taken from the original fields.pm.

=cut

1;
