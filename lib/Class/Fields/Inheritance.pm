package Class::Fields::Inheritance;

use strict;
no strict 'refs';
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);

$VERSION = 0.01;

require Exporter;
@ISA = qw(Exporter);

@EXPORT = qw(_PUBLIC
			 _PRIVATE
			 _INHERITED
			 _PROTECTED
			);
@EXPORT_OK = qw(%attr inherit add_fields);
%EXPORT_TAGS = (
				'Attribs' 	=> [qw(_PUBLIC _PRIVATE _INHERITED _PROTECTED)],
				'Inherit'	=> [qw(inherit add_fields)],
			   );
				

sub _PUBLIC    	() { 1 }	# Open to the public, will be inherited.
sub _PRIVATE   	() { 2 }	# Not to be used by anyone but that class, 
							# will not be inherited
sub _INHERITED 	() { 4 }	# This member was inherited
sub _PROTECTED	() { 8 }	# Not to be used by anyone but that class and its
							# subclasses, will be inherited.


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

sub add_fields {
	# Read the first two parameters.  The rest are field names.
	my($package, $attrib) = splice(@_, 0, 2);
	
	my $fields = \%{"$package\::FIELDS"};
    my $fattr = ($attr{$package} ||= []);

	foreach my $f (@_) {
		if (my $fno = $fields->{$f}) {
	    	require Carp;
			if ($fattr->[$fno-1] & _INHERITED) {
				Carp::carp("Hides field '$f' in base class") if $^W;
            } else {
                Carp::croak("Field name '$f' already in use");
            }
		}
		$fields->{$f} = @$fattr + 1;
        push(@$fattr, $attrib);
    }
}


sub inherit
{
    my($derived, $base) = @_;

    if (keys %{"$derived\::FIELDS"}) {
    	require Carp;
		Carp::croak("Inherited %FIELDS can't override existing %FIELDS");
    } else {
		my $base_fields    = \%{"$base\::FIELDS"};
		my $derived_fields = \%{"$derived\::FIELDS"};

		$attr{$derived}[@{$attr{$base}}-1] = undef;
		while (my($k,$v) = each %$base_fields) {
			next if $attr{$base}[$v-1] & _PRIVATE;
			$attr{$derived}[$v-1] = _INHERITED;
			$derived_fields->{$k} = $v;
		}
	}
}


sub _dump  # sometimes useful for debugging
{
   for my $pkg (sort keys %attr) {
      print "\n$pkg";
      if (@{"$pkg\::ISA"}) {
         print " (", join(", ", @{"$pkg\::ISA"}), ")";
      }
      print "\n";
      my $fields = \%{"$pkg\::FIELDS"};
      for my $f (sort {$fields->{$a} <=> $fields->{$b}} keys %$fields) {
         my $no = $fields->{$f};
         print "   $no: $f";
         my $fattr = $attr{$pkg}[$no-1];
         if (defined $fattr) {
            my @a;
	    	push(@a, "public")    if $fattr & _PUBLIC;
            push(@a, "private")   if $fattr & _PRIVATE;
            push(@a, "inherited") if $fattr & _INHERITED;
            push(@a, "protected") if $fattr & _PROTECTED;
            print "\t(", join(", ", @a), ")";
         }
         print "\n";
      }
   }
}
