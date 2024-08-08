use Test2::V0;
use Types::Standard qw(Str);

use kote Name => Str;

subtest 'Test `maybe` method' => sub {

    my $Maybe = Name->maybe;
    isa_ok $Maybe, 'Type::Kote', 'Type::Tiny';
    is $Maybe->display_name, 'Maybe[Name]', 'display_name';

    my ($name, $err) = $Maybe->create('Alice');
    ok !$err, 'No error';
    is $name, 'Alice';

    ($name, $err) = $Maybe->create(undef);
    ok !$err, 'Allow undef';
    is $name, undef;

    ($name, $err) = $Maybe->create({});
    ok $err, 'Error';
    is $name, undef;
};

done_testing;
