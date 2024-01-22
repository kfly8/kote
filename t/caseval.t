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

done_testing;
