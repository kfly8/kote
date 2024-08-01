use Test2::V0;

use Types::Standard qw(Str);

use kote Foo => Str & sub { /^[A-Z][a-z]+$/ };

subtest 'Check valid kote name' => sub {
    my @invalid_names = (
        'str'        => "kote name 'str' is not CamelCase",
        'int'        => "kote name 'int' is not CamelCase",
        'dash-case'  => "kote name 'dash-case' is not CamelCase",
        'snake_case' => "kote name 'snake_case' is not CamelCase",
        '_Foo'       => "kote name '_Foo' is not CamelCase",
        '1Foo'       => "kote name '1Foo' is not CamelCase",
        'BEGIN'      => "kote name 'BEGIN' is forbidden",
        'CHECK'      => "kote name 'CHECK' is forbidden",
        'DESTROY'    => "kote name 'DESTROY' is forbidden",
        'END'        => "kote name 'END' is forbidden",
        'INIT'       => "kote name 'INIT' is forbidden",
        'UNITCHECK'  => "kote name 'UNITCHECK' is forbidden",
        'AUTOLOAD'   => "kote name 'AUTOLOAD' is forbidden",
        'STDIN'      => "kote name 'STDIN' is forbidden",
        'STDOUT'     => "kote name 'STDOUT' is forbidden",
        'STDERR'     => "kote name 'STDERR' is forbidden",
        'ARGV'       => "kote name 'ARGV' is forbidden",
        'ARGVOUT'    => "kote name 'ARGVOUT' is forbidden",
        'ENV'        => "kote name 'ENV' is forbidden",
        'INC'        => "kote name 'INC' is forbidden",
        'SIG'        => "kote name 'SIG' is forbidden",
    );

    while (my ($name, $error) = splice @invalid_names, 0, 2) {
        eval "use kote '$name' => Str;";
        like $@, qr/^$error/, "$error";
    }

    eval "use kote;";
    like $@, qr/^kote name is not given/, "kote name is not given";

    eval "use kote Foo => Str;";
    like $@, qr/^'Foo' is already defined/;
};

subtest 'Check valid type' => sub {
    eval "use kote Bar => 'Str';";
    like $@, qr/^Bar: Type must be a Type::Tiny/;
};

done_testing;
