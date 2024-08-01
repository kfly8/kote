use Test2::V0;

use lib 'examples/lib';

use Foo qw(CharacterName MonsterName toCharacterName);

{
    my ($alice, $e) = CharacterName->create('Alice');
    is $alice, 'Alice';
    ok !$e;
}

{
    my ($goblin, $e) = MonsterName->create('Goblin');
    is $goblin, 'Goblin';
    ok !$e;
}

{
    my $e;
    (my $alice, $e) = Foo->run('Alice');
    is $alice, 'Alice';
    ok !$e;

    (my $bob, $e) = Foo->run('bob');
    ok !$bob;
    ok $e;
}

{

    my $e;
    my $raw = 'Alice';
    (my $alice, $e) = toCharacterName($raw);
    is $alice, 'Alice';
    ok !$e;
}

done_testing;
