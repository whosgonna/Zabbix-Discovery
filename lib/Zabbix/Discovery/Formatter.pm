package Zabbix::Discovery::Formatter;
use 5.010;
use strict;
use warnings;

use Exporter qw(import);
 
our @EXPORT_OK = qw(zabbix_disco);

use Moo;
use Types::Standard qw(:all);
use List::Util 'any';
use JSON;



our $VERSION = "v0.0.2";

## Will need to provide a built time check of the ArrayRef passed to data
has data => (
    is => 'rw',
    isa => ArrayRef[],
    default => sub { return []; },
    required => 1,
);

# Debatable if the "data" key is needed.  If so it would be 'pre40'; 
# No logic written for this yet.
has pre40 => (
    is      => 'rw',
    isa     => Bool,
    default => 0,
);


# When handling data in an OO fashion allow the caller to keep adding
# data.  This is a convenience method, so the object can be created first,
# and then rows can be appended easily as the script iterates over data. 
sub add {
    my $self = shift;
    my $row  = shift;
    if ( any { ref } values %$row ) {
        die( "MultiDemensional Data is not allowed for a row");
    }

    my @array = @{ $self->data } ;
    push @array, $row;
    $self->data(\@array);
};


# Returns an a perl datastructure (an arrayref of hashrefs) with the zabbix
# 'data' identifier, and key names capitalized, with a leading '#' symbol, 
# and inside of curly brackets.  This is not yet formatted as JSON, so it can
# be manipulated further if we need to.
sub _format {
    my $self = shift;
    my $data = $self->data;
    my $out  = { data => [] };

    for my $row ( @$data ) {
        my %new_row = map { 
            ('{#' . uc $_ . '}') #  makes 'key' '{#KEY}'
              => $row->{$_}      #  value stays the same
        }  keys %$row;

        push @{ $out->{data} }, \%new_row;
    }

    return $out;
}

# JSON encodes the _format(ed) data:  This will accept a argument of ( pretty 
# => 1 ) to 'pretty print' the JSON for easier debugging.
sub print {
    my $self   = shift;
    my %args   = @_;
    my $format = $self->_format;

    if ( $args{pretty} ) {
        my $json = to_json($format, { pretty => 1 } );
        return $json;
    }

    my $json = encode_json( $format );
    return $json;
}


# This is the non-OO interface.  If the user has only a proper $data structure,
# then this will return (non-pretty) JSON data.  It accepts arguments as a
# hashref.  The only currently valid argument is pretty => 1.
sub zabbix_disco {
    my $data = shift;
    my $args = shift;

    my $zabbix_disco = Zabbix::Discovery::Formatter->new( data => $data );
    $zabbix_disco->print(%$args);
}



1;
__END__

=encoding utf-8

=head1 NAME

Zabbix::Discovery::Formatter - Boilerplat formatting for Zabbix Low-Level 
Discovery

=head1 SYNOPSIS


 use strict;
 use warnings;
 use Zabbix::Discovery::Formatter;
 
 my $arr_ref = [
     { host => 'Japan 1', count => 5 },
     { host => 'Japan 2', count => 12 },
     { host => 'Latvia',  count => 3 },
 ];
 
 my $discovery = Zabbix::Discovery::Formatter->new( data => $array_ref );
 print $discovery->print;
 
 # Prints:
 # {"data":[{"{#HOST}":"Japan 1","{#COUNT}":5},{"{#HOST}":"Japan 2","{#COUNT}":12},{"{#HOST}":"Latvia","{#COUNT}":3}]}
 
 my $new_row = { host => 'USA 1', count => 6};
 $discovery->add( $new_row );
 print $discovery->print;
 
 # Prints:
 # {"data":[{"{#HOST}":"Japan 1","{#COUNT}":5},{"{#COUNT}":12,"{#HOST}":"Japan 2"},{"{#HOST}":"Latvia","{#COUNT}":3},{"{#HOST}":"USA 1","{#COUNT}":6}]}

Non object-oriented usage: 

 use strict;
 use warnings;
 
 my $arr_ref = [
     { host => 'Japan 1', count => 5 },
     { host => 'Japan 2', count => 12 },
     { host => 'Latvia',  count => 3 },
 ];
 
 use Zabbix::Discovery::Formatter 'zabbix_disco';
 my $json = zabbix_disco( $arr_ref );
 print $json;
 
 # Prints:
 # {"data":[{"{#HOST}":"Japan 1","{#COUNT}":5},{"{#COUNT}":12,"{#HOST}":"Japan 2"},{"{#HOST}":"Latvia","{#COUNT}":3},{"{#HOST}":"USA 1","{#COUNT}":6}]}
 

=head1 DESCRIPTION

Zabbix::Discovery::Formatter is a simple module to convert a perl ArrayRef of
non multi-dimensional HashRefs to a properly formatted with:

=over 2

=item * Add the C<data> tag at the beginning of the JSON data.

=item * Validate the data structure (it is an array or array reference 
consisting of hashrefs that are exactlyo one layer deep)

=item * Capitalize the key names.

=item * Prepend the key name with a C<#> symbol

=item * Wrap the key name in curly braces: C<{#KEY}>

=item * Convert the data structure to JSON.

=back

=head1 Methods

=head2 Non Object-Oriented Usage

This is probably easier if your data structure already exists, and all you want
to do is eliminate boiler plate formatting.

=over 4

=item zabbix_disco( $arr_ref )

=item zabbix_disco( $arr_ref, { pretty => 1 } )

Simply wraps the appropriate array rerence as JSON, doing all of the steps as
indicated above.  It should be possible to return this to the discovery 
request. 

Setting C<< pretty => 1 >> will "pretty print" the JSON.  It's probably
best to pretty print only for debugging purposes, as pretty printing is both 
slower and consumes more bandwidth.


=back

=head2 Object-Oriented Usage

This is probably the way to go if you are iterating over data and want to pass
the individual rows diretly to the object.  An example of this would be when
processing rows from a database in a C<while> loop.

=over 4

=item new()

=item new( data => $arr_ref );

This will create a new Zabbix::Discovery::Formatter object with either an 
empty array reference for C<< ->data >> or with C<$arra_ref> as << ->data>>.

=item data
=item data( $arr_ref )

Get the array reference stored in the object if there is no argument, replace
the array reference if there is an argument.

=item add

Add a new hashref to the arrayref.

=back

=head1 LICENSE

Copyright (C) Ben Kaufman.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Ben Kaufman E<lt>ben.whosgonna.com@gmail.comE<gt>

=cut

