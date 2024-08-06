use Test2::V0;

use Types::Standard qw(Str);

use kote Foo => Str;

subtest 'single value' => sub {
    my ($err, $foo) = Foo->create('foo');
    is $err, undef, 'no error';
};

subtest 'multiple values' => sub {
    my ($err, $foo, $bar) = Foo->create('foo', 'bar');
    is $err, undef, 'no error';
    is $foo, 'foo';
    is $bar, 'bar';

    ($err, my @values) = Foo->create('foo', 'bar');
    is $err, undef, 'no error';
    is \@values, ['foo', 'bar'];
};

subtest 'single illegal value' => sub {
    my ($err, $foo) = Foo->create({});
    ok $err;
    note $err;
    is $foo, undef;
};

subtest 'multiple illegal values' => sub {
    my ($err, $foo, $bar) = Foo->create({}, 'bar');
    ok $err;
    note $err;
    is $foo, undef;
    is $bar, undef;
};

subtest 'no value' => sub{
    my ($err, $foo) = Foo->create();
    ok !$err;
    is $foo, undef;
};

done_testing;
