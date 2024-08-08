use Test2::V0;

use Types::Standard -types;

use kote Name => Str & sub { /^[A-Z][a-z]+$/ };

subtest 'where' => sub {
    my $Alice = Name->where(sub { $_ eq 'Alice' });

    isa_ok $Alice, 'Type::Kote', 'Type::Tiny';
    ok $Alice->check('Alice');
    ok !$Alice->check('Bob');
    ok $Alice->parent == Name, 'parent';
};

subtest 'create_child_type' => sub {
    my $Alice = Name->create_child_type(
        constraint => sub { $_ eq 'Alice' },
    );

    isa_ok $Alice, 'Type::Kote', 'Type::Tiny';
    ok $Alice->check('Alice');
    ok !$Alice->check('Bob');
    ok $Alice->parent == Name, 'parent';
};

subtest 'complementary_type' => sub {
    my $NotName = Name->complementary_type;

    isa_ok $NotName, 'Type::Kote', 'Type::Tiny';
    ok $NotName->check({});
    ok !$NotName->check('Alice');
};

done_testing;
