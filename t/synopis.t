use Test2::V0;

use Types::Standard qw(Str);

use caseval CharcterName => Str & sub { /^[A-Z][a-z]+$/ };

subtest 'name' => sub {
    is +CharcterName->name, 'CharcterName', 'CharcterName is CharcterName';
};

subtest 'create' => sub {
    my $err;

    (my $alice, $err) = CharcterName->create('Alice');
    is $alice->value, 'Alice', 'Alice is valid';
    is $alice->name, 'CharcterName', 'Alice is CharcterName';
    is $err, undef, 'No error';

    (my $bob, $err) = CharcterName->create('bob');
    is $bob, undef, 'bob is invalid';
    is $err, 'invalid value', 'bob is invalid';
};

subtest 'type' => sub {
    my $type = CharcterName->type;
    isa_ok $type, 'Type::Tiny';
    ok $type->is_a_type_of('Str');
    ok !$type->is_a_type_of('Int');
};

done_testing;
