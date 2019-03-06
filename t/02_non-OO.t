use strict;
use Test::More 0.98;
use Data::Printer;


BEGIN {
    use_ok(
        "Zabbix::Discovery::Formatter", 'zabbix_disco'
    );
}


my $arr_ref = [
    { host => 'Japan 1', count => 5 },
    { host => 'Japan 2', count => 12 },
    { host => 'Latvia',  count => 3 },
];

my $output = zabbix_disco($arr_ref);
p $output;

$output = zabbix_disco($arr_ref, {pretty => 1});
p $output;

done_testing;
exit;


my $disc2 = Zabbix::Discovery::Formatter->new( data => $arr_ref);

is_deeply( $disc2->data, $arr_ref, "Data is set correctly" );

my $row = { host => 'USA 1', count => 6};

$disc2->add_row($row);

my @arr2 = @$arr_ref;

push @arr2, $row;

is_deeply( $disc2->data, \@arr2, "Data is updated correctly" );


my $fmt = $disc2->print(pretty => 1);
p $fmt;



done_testing;

