package Class::Fields::Inherit;

use strict;
no strict 'refs';
use vars qw(@ISA @EXPORT $VERSION);

use Class::Fields::Fuxor;
use Class::Fields::Attribs;

$VERSION = '0.03';

require Exporter;
@ISA = qw(Exporter);

@EXPORT = qw( inherit_fields );

use constant SUCCESS => 1;
use constant FAILURE => !SUCCESS;

#'#
sub inherit_fields {
    my($derived, $base) = @_;

    return SUCCESS unless $base;

    my $battr = get_attr($base);
    my $dattr = get_attr($derived);
    my $dfields = get_fields($derived);
    my $bfields = get_fields($base);

    $dattr->[0] = @$battr;

    # Iterate through the base's fields adding all the non-private
    # ones to the derived class.  Hang on to the original attribute
    # (Public, Private, etc...) and add Inherited.
    # This is all too complicated to do efficiently with add_fields().
    while (my($k,$v) = each %$bfields) {
        my $fno;
	if ($fno = $dfields->{$k} and $fno != $v) {
	    require Carp;
	    Carp::croak ("Inherited %FIELDS can't override existing %FIELDS");
	}

        if( $battr->[$v] & PRIVATE ) {
            $dattr->[$v] = undef;
        }
        else {
            $dattr->[$v] = INHERITED | $battr->[$v];

            # Derived fields must be kept in the same position as the
            # base in order to make "static" typing work with psuedo-hashes.
            # Alas, this kills multiple field inheritance.
            $dfields->{$k} = $v;
        }
    }
}

return 'IRS Estate Tax Return Form 706';
__END__
=pod

=head1 NAME

Class::Fields::Inherit - Inheritance of %FIELDS


=head1 SYNOPSIS

    use Class::Fields::Inherit;
    inherit_fields($derived_class, $base_class);


=head1 DESCRIPTION

A simple module to handle inheritance of the %FIELDS hash.  base.pm is
usually its only customer, though there's nothing stopping you from
using it.

=over 4

=item B<inherit_fields>

  inherit_fields($derived_class, $base_class);

The $derived_class will inherit all of the $base_class's fields.  This
is a good chunk of what happens when you use base.pm.

=back

=head1 AUTHOR

Michael G Schwern <schwern@pobox.com> largely from code liberated from
fields.pm

=head1 SEE ALSO

L<base>, L<Class::Fields>
