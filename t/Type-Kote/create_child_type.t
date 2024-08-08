use Test2::V0;
use Types::Standard qw(Str);

use kote Name => Str;

# Type::Kote#create_child_type makes a new Type::Kote.
subtest 'Test `create_child_type` method' => sub {
    my $Alice = Name->create_child_type(
        constraint => sub { $_ eq 'Alice' },
    );

    isa_ok $Alice, 'Type::Kote', 'Type::Tiny';
    ok $Alice->check('Alice');
    ok !$Alice->check('Bob');
    ok $Alice->parent == Name, 'parent';
};

# `where` method is shorthand for `create_child_type`
subtest 'Test `where` method' => sub {
    my $Alice = Name->where(sub { $_ eq 'Alice' });

    isa_ok $Alice, 'Type::Kote', 'Type::Tiny';
    ok $Alice->check('Alice');
    ok !$Alice->check('Bob');
    ok $Alice->parent == Name, 'parent';
};

done_testing
