# NAME

Zabbix::Discovery::Formatter - Boilerplat formatting for Zabbix Low-Level 
Discovery

# SYNOPSIS

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
    

# DESCRIPTION

Zabbix::Discovery::Formatter is a simple module to convert a perl ArrayRef of
non multi-dimensional HashRefs to a properly formatted with:

- Add the `data` tag at the beginning of the JSON data.
- Validate the data structure (it is an array or array reference 
consisting of hashrefs that are exactlyo one layer deep)
- Capitalize the key names.
- Prepend the key name with a `#` symbol
- Wrap the key name in curly braces: `{#KEY}`
- Convert the data structure to JSON.

# Methods

## Non Object-Oriented Usage

This is probably easier if your data structure already exists, and all you want
to do is eliminate boiler plate formatting.

- zabbix\_disco( $arr\_ref )
- zabbix\_disco( $arr\_ref, { pretty => 1 } )

    Simply wraps the appropriate array rerence as JSON, doing all of the steps as
    indicated above.  It should be possible to return this to the discovery 
    request. 

    Setting `pretty => 1` will "pretty print" the JSON.  It's probably
    best to pretty print only for debugging purposes, as pretty printing is both 
    slower and consumes more bandwidth.

## Object-Oriented Usage

This is probably the way to go if you are iterating over data and want to pass
the individual rows diretly to the object.  An example of this would be when
processing rows from a database in a `while` loop.

- new()
- new( data => $arr\_ref );

    This will create a new Zabbix::Discovery::Formatter object with either an 
    empty array reference for `->data` or with `$arra_ref` as << ->data>>.

- data
=item data( $arr\_ref )

    Get the array reference stored in the object if there is no argument, replace
    the array reference if there is an argument.

- add

    Add a new hashref to the arrayref.

# LICENSE

Copyright (C) Ben Kaufman.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Ben Kaufman <ben.whosgonna.com@gmail.com>
