use Test2::V0;
use Types::Standard qw(Str Int Dict ArrayRef);

use kote Name => Str & sub { /^[A-Z][a-z]+$/ };
use kote Level => Int & sub { $_ >= 1 && $_ <= 100 };

use kote Character     => Dict[ name => Name, level => Level ];
use kote CharacterList => ArrayRef[Character];

subtest 'Test `create` method' => sub {

    subtest 'Calling in non List context' => sub {
        like dies {
            Name->create('Alice')
        }, qr/^Must handle error/;

        like dies {
            my $name = Name->create('Alice');
        }, qr/^Must handle error/;
    };

    subtest 'When a string type' => sub {
        my ($name, $err) = Name->create('Alice');
        is $err, undef, 'No error';
        is $name, 'Alice';

        ($name, $err) = Name->create('bob');
        ok $err, 'Error';
        is $name, undef, 'invalid value';
    };

    subtest 'When a number type' => sub {
        my ($level, $err) = Level->create(3);
        is $err, undef, 'No error';
        is $level, 3;

        ($level, $err) = Level->create(0);
        ok $err, 'Error';
        is $level, undef, 'invalid value';
    };

    subtest 'When a dictionary type' => sub {
        my ($character, $err) = Character->create({name => 'Alice', level => 99});
        is $err, undef, 'No error';
        is $character, {
            name => 'Alice',
            level => 99,
        };

        subtest 'Result is readonly' => sub {
            ok dies { $character->{name} = 'Bob' }, 'assign to readonly field';
            ok dies { $character->{foo} }, 'access to unknown field';
        };

        ($character, $err) = Character->create({name => 'Bob', level => 0});
        ok $err, 'Error';
        is $character, undef, 'invalid value';
    };

    subtest 'When a arrayref type' => sub {
        my ($list, $err) = CharacterList->create([
            {name => 'Alice', level => 99},
            {name => 'Bob', level => 1},
        ]);
        is $err, undef, 'No error';
        is $list, [
            {name => 'Alice', level => 99},
            {name => 'Bob', level => 1},
        ];

        subtest 'Result is readonly' => sub {
            ok dies { $list->[0]{name} = 'Bob' }, 'assign to readonly field';
            ok dies { $list->[0]{foo} }, 'access to unknown field';
        };

        ($list, $err) = CharacterList->create([
            {name => 'Alice', level => 99},
            {name => 'Bob', level => 0},
        ]);
        ok $err;
        is $list, undef, 'invalid value';
    };
};

done_testing;
