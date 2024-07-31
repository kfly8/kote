use Test2::V0;

use Types::Standard qw(Str Int Dict);

use caseval CharacterName => Str & sub { /^[A-Z][a-z]+$/ };
use caseval MonsterName => Str & sub { /^[A-Z][a-z]+$/ };
use caseval CharacterLevel => Int & sub { $_ >= 1 && $_ <= 100 };

use caseval Character => Dict[
    name => CharacterName,
    level => CharacterLevel,
];

subtest '__typename' => sub {
    is +CharacterName->__typename, 'CharacterName', '__typename is CharacterName';
    is +Character->__typename, 'Character', '__typename is Character';
};

subtest 'create' => sub {

    subtest 'When type is string' => sub {
        my $err;

        (my $alice, $err) = CharacterName->create('Alice');
        is $err, undef, 'No error';
        is $alice->__typename, 'CharacterName';
        is $alice, 'Alice';

        (my $bob, $err) = CharacterName->create('bob');
        is $bob, undef, 'invalid value';
        ok $err, 'Error';
    };

    subtest 'When type is number' => sub {
        my $err;

        (my $level, $err) = CharacterLevel->create(3);
        is $err, undef, 'No error';
        is $level->__typename, 'CharacterLevel';
        is $level, 3;

        (my $level2, $err) = CharacterLevel->create(0);
        is $level2, undef, 'invalid value';
        ok $err, 'Error';
    };

    subtest 'When type is dictionary' => sub {
        (my $alice, my $err) = Character->create({name => 'Alice', level => 99});
        is $err, undef, 'No error';

        my $name = $alice->name;
        is $name, 'Alice';
        is $name->__typename, 'CharacterName';

        my $level = $alice->level;
        is $level, 99;
        is $level->__typename, 'CharacterLevel';

        is $alice->name, 'Alice';
        is $alice->level, 99;
        is $alice, {
            name => 'Alice',
            level => 99,
        };
        is $alice->__typename, 'Character';

        (my $bob, $err) = Character->create({name => 'bob', level => 0});
        is $bob, undef, 'invalid value';
        ok $err, 'Error';
    };
};

subtest 'type' => sub {
    my $type = CharacterName->type;
    isa_ok $type, 'Type::Tiny';
    ok $type->is_a_type_of('Str');
    ok !$type->is_a_type_of('Int');
};

subtest 'check' => sub {
    my $err;
    (my $alice, $err) = CharacterName->create('Alice');
    (my $malice, $err) = MonsterName->create('Alice');

    ok CharacterName->check($alice);
    ok !CharacterName->check('Alice');
    ok !CharacterName->check($malice), 'Different type';
};

done_testing;
