use strict;
use Test::More 0.98;
use Data::Printer;

use_ok $_ for qw(
    Zabbix::Discovery::Formatter
);

my $disc = new_ok(
    "Zabbix::Discovery::Formatter"
);

my $arr_ref = [
    { host => 'Japan 1', count => 5 },
    { host => 'Japan 2', count => 12 },
    { host => 'Latvia',  count => 3 },
];
my $disc2 = Zabbix::Discovery::Formatter->new( data => $arr_ref);

my $json = $disc2->print;
print $disc2->print . "\n";

is_deeply( $disc2->data, $arr_ref, "Data is set correctly" );

my $row = { host => 'USA 1', count => 6};

$disc2->add($row);
$json = $disc2->print;
print $disc2->print . "\n";


my @arr2 = @$arr_ref;

push @arr2, $row;

is_deeply( $disc2->data, \@arr2, "Data is updated correctly" );


my $fmt = $disc2->print(pretty => 1);


done_testing;

