use Test2::V0;

use Types::Standard qw(Str);

use caseval Foo => Str & sub { /^[A-Z][a-z]+$/ };

subtest 'Check valid caseval name' => sub {
    my @invalid_names = (
        'str'        => "caseval name 'str' is not CamelCase",
        'int'        => "caseval name 'int' is not CamelCase",
        'dash-case'  => "caseval name 'dash-case' is not CamelCase",
        'snake_case' => "caseval name 'snake_case' is not CamelCase",
        '_Foo'       => "caseval name '_Foo' is not CamelCase",
        '1Foo'       => "caseval name '1Foo' is not CamelCase",
        'BEGIN'      => "caseval name 'BEGIN' is forbidden",
        'CHECK'      => "caseval name 'CHECK' is forbidden",
        'DESTROY'    => "caseval name 'DESTROY' is forbidden",
        'END'        => "caseval name 'END' is forbidden",
        'INIT'       => "caseval name 'INIT' is forbidden",
        'UNITCHECK'  => "caseval name 'UNITCHECK' is forbidden",
        'AUTOLOAD'   => "caseval name 'AUTOLOAD' is forbidden",
        'STDIN'      => "caseval name 'STDIN' is forbidden",
        'STDOUT'     => "caseval name 'STDOUT' is forbidden",
        'STDERR'     => "caseval name 'STDERR' is forbidden",
        'ARGV'       => "caseval name 'ARGV' is forbidden",
        'ARGVOUT'    => "caseval name 'ARGVOUT' is forbidden",
        'ENV'        => "caseval name 'ENV' is forbidden",
        'INC'        => "caseval name 'INC' is forbidden",
        'SIG'        => "caseval name 'SIG' is forbidden",
    );

    while (my ($name, $error) = splice @invalid_names, 0, 2) {
        eval "use caseval '$name' => Str;";
        like $@, qr/^$error/, "$error";
    }

    eval "use caseval;";
    like $@, qr/^caseval name is not given/, "caseval name is not given";

    eval "use caseval Foo => Str;";
    like $@, qr/^'Foo' is already defined/;
};

subtest 'Check valid type' => sub {
    eval "use caseval Bar => 'Str';";
    like $@, qr/^Invalid type for 'Bar'/;
};

done_testing;
