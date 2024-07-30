use Test2::V0;

use caseval CharcterName => sub { /^[A-Z][a-z]+$/ };

subtest 'Alice' => sub {
    my ($alice, $err) = CharcterName->create('Alice');
    is $alice->value, 'Alice', 'Alice is valid';
    is $alice->name, 'CharcterName', 'Alice is CharcterName';
    is $err, undef, 'No error';
};

subtest 'bob' => sub {
    my ($bob, $err) = CharcterName->create('bob');
    is $bob, undef, 'bob is invalid';
    is $err, 'invalid value', 'bob is invalid';
};

subtest 'type' => sub {
    my $CharacterName = CharcterName->type;
    is $CharacterName, object {
        prop blessed => 'Type::Tiny';
        call name => 'CharcterName';
    };
};

done_testing;
