requires 'perl', '5.008001';
requires 'Moo';
requires 'Types::Standard';
requires 'List::Util';
requires 'JSON';
requires 'Exporter';

on 'test' => sub {
    requires 'Test::More', '0.98';
};



