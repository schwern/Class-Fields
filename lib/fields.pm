package fields;

use strict;
use vars qw($VERSION);

use Class::Fields qw(:Attribs :Fields);

use constant SUCCESS => 1;

$VERSION = "0.11";

sub import {
    # Dump the class.
    shift;
    
    my $package = caller(0);
    
	return SUCCESS unless @_;

    add_fields($package, PRIVATE, grep {/^_/} @_);
    add_fields($package, PUBLIC,  grep {!/^_/} @_);
}


1;

__END__
=head1 NAME

fields - compile-time class fields

=head1 SYNOPSIS

    {
        package Foo;
        use fields qw(foo bar _private);
    }
    ...
    my Foo $var = new Foo;
    $var->{foo} = 42;

    # This will generate a compile-time error.
    $var->{zap} = 42;

    {
        package Bar;
        use base 'Foo';
        use fields 'bar';             # hides Foo->{bar}
        use fields qw(baz _private);  # not shared with Foo
    }

=head1 DESCRIPTION

The C<fields> pragma enables compile-time verified class fields.  It
does so by updating the %FIELDS hash in the calling package.

If a typed lexical variable holding a reference is used to access a
hash element and the %FIELDS hash of the given type exists, then the
operation is turned into an array access at compile time.  The %FIELDS
hash maps from hash element names to the array indices.  If the hash
element is not present in the %FIELDS hash, then a compile-time error
is signaled.

Since the %FIELDS hash is used at compile-time, it must be set up at
compile-time too.  This is made easier with the help of the 'fields'
and the 'base' pragma modules.  The 'base' pragma will copy fields
from base classes and the 'fields' pragma adds new fields.  Field
names that start with an underscore character are made private to a
class and are not visible to subclasses.  Inherited fields can be
overridden but will generate a warning if used together with the C<-w>
switch.

The effect of all this is that you can have objects with named fields
which are as compact and as fast arrays to access.  This only works
as long as the objects are accessed through properly typed variables.
For untyped access to work you have to make sure that a reference to
the proper %FIELDS hash is assigned to the 0'th element of the array
object (so that the objects can be treated like an pseudo-hash).  A
constructor like this does the job:

  sub new
  {
      my $class = shift;
      no strict 'refs';
      my $self = bless [\%{$class.'::FIELDS'}], $class;
      return $self;
  }


=head1 SEE ALSO

L<base>, L<public>, L<private>, L<protected>,
L<perlref/Pseudo-hashes: Using an array as a hash>

=cut
