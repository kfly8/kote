use Test2::V0;
use Types::Standard qw(Str);

use kote Name => Str;

subtest 'Test `complementary_type` method' => sub {
    my $NotName = Name->complementary_type;

    isa_ok $NotName, 'Type::Kote', 'Type::Tiny';
    ok $NotName->check({});
    ok !$NotName->check('Alice');
};

done_testing;
