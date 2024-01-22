use Test2::V0;

use Types::Standard qw(Dict Str Int);

BEGIN {
    $ENV{PERL_CASEVAL_STRICT} = 1;
}

use caseval Human => Dict[
    name => Str,
    age => Int,
];

is Human, object {
    prop blessed => 'Type::Tiny';
    call display_name => 'Dict[age=>Int,name=>Str]';
}, 'Human is a Type::Tiny object';

my $human = Human::val(name => 'John', age => 42);
is $human, { name => 'John', age => 42 }, 'Human::val returns a hashref';

subtest 'PERL_CASEVAL_STRICT is enabled' => sub {
    like dies {
       $human->{foo};
    }, qr/Attempt to access disallowed key 'foo'/, 'Human::val is locked';

    like dies {
        $human->{name} = 'Jane';
    }, qr/Modification of a read-only value attempted/, 'Human::val is immutable';

    like dies {
        Human::val(foo => '');
    }, qr/Reference \{"foo" => ""\} did not pass type constraint/, 'Human::val validates';
};

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

    eval "use caseval Human => Str;";
    like $@, qr/^caseval name 'Human' is already defined./, "caseval name 'Human' is already defined.";
};

done_testing;
