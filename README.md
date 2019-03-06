# Zabbix-Discovery
Simplify conversion of Perl data structures to Zabbix Discovery Data Structures.


Provider "sugar" to take a perl data structure (an arrayref consisting of a single level hashref), and encapsulate it for Zabbix LLDs:

This should:
1 Optionally add the "data" tag at the beginning (Zabbix 4.0 behavior vs pre 4.0 behavior).  Need to determine what default would be, and how to override.
1 Validate the data structure (it is an array or array reference consisting of hashrefs that are exactlyo one layer deep)
1 Capitalize the key name.
1 Prepend the key name with a "#" symbol
1 Wrap the key name in curly braces {#KEY}
1 Convert the data structure to JSON.


## Example
```perl
use strict;
use warnings;
use Zabbix::Discovery 'zabbix_discovery';

my $data = [
    { host => 'Japan 1', count => 5 },
    { host => 'Japan 2', count => 12 },
    { host => 'Latvia',  count => 3 },
];
 
my $output = zabbix_discovery($data);
print $output;
 ```
 
The result should be:
```json
{
    "data": [
        {
            "{#HOST}": "Japan 1",
            "{#COUNT}": "5"
        },
        {
            "{#HOST}": "Japan 2",
            "{#COUNT}": "12"
        },
        {
            "{#HOST}": "Latvia",
            "{#COUNT}": "3"
        }
    ]
}
```
