use Test2::V0;

use lib 't/lib';

use Character qw(Character character_summary_message);

subtest 'Character' => sub {
    my $err;

    (my $alice, $err) = Character->create({name => 'Alice', level => 99});
    is $err, undef, 'No error';
    is $alice, {name => 'Alice', level => 99};

    (my $bob, $err) = Character->create({name => 'bob', level => 0});
    is $bob, undef, 'invalid value';
    ok $err, 'Error';
};

subtest 'character_summary_message' => sub {
    my $err;

    (my $alice, $err) = Character->create({name => 'Alice', level => 99});
    is character_summary_message($alice), 'Name: Alice, Level: 99';
};

done_testing;
