use Test2::V0;

use Types::Standard qw(Str);

subtest 'Already defined' => sub {
    use kote Foo => Str & sub { /^[A-Z][a-z]+$/ };

    eval "use kote Foo => Str;";
    like $@, qr/^'Foo' is already defined/;
};

subtest 'Not given name' => sub {
    eval "use kote;";
    like $@, qr/^name is required/;
};

subtest 'Forbidden name' => sub {
    eval "use kote BEGIN => Str;";
    like $@, qr/^'BEGIN' is forbidden/;
};

subtest 'Invalid name' => sub {
    my @invalid_names = (qw/
        1
        str
        int
        foo_bar
        dash-case
        1Foo
    /);

    for my $name (@invalid_names) {
        like warning {
            eval "use kote '$name' => Str;";
        }, qr/^"$name" is not a valid type name/;
        like $@, qr/^Failed to create '$name'/, $name;
    }
};

subtest 'Valid name' => sub {
    my @valid_names = (qw/
        FooBar
        Foo1
        _Foo
        Foo_
        Foo_Bar
        FOO
        FOO_BAR
    /);

    for my $name (@valid_names) {
        eval "use kote $name => Str;";
        ok !$@, $name;
    }
};

subtest 'Invalid type' => sub {
    eval "use kote Bar => 'Str';";
    like $@, qr/^Bar: type must be able to be a Type::Tiny/;
};

subtest 'Valid type' => sub {
    eval "use kote Bar1 => sub { 1 };";
    ok !$@, 'CodeRef';
};

done_testing;
