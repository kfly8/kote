use Test2::V0;
use Types::Standard qw(Str Dict);

use kote ID => Str;
use kote Name => Str;

subtest 'Test `optional` method' => sub {

    my $Optional = Name->optional;
    isa_ok $Optional, 'Type::Kote', 'Type::Tiny';
    is $Optional->display_name, 'Optional[Name]', 'display_name';

    my ($name, $err) = $Optional->create('Alice');
    ok !$err, 'No error';
    is $name, 'Alice';

    ($name, $err) = $Optional->create(undef);
    ok $err, 'Error';
    is $name, undef;

    my $Dict = Dict[id => ID, name => $Optional];
    ok $Dict->check({id => 123, name => 'Alice'}), 'valid';
    ok $Dict->check({id => 456 }), 'Allow `name` key is optional';
    ok !$Dict->check({id => 789, name => undef }), 'invalid';
};

done_testing;
