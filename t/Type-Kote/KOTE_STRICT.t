use Test2::V0;

BEGIN {
    $ENV{KOTE_STRICT} = 0;
}

use Types::Standard qw(Str);

use kote PlayerName => Str & sub { /^[A-Z][a-z]+$/ };

subtest 'When KOTE_STRICT is false' => sub {
    my ($name, $err) = PlayerName->create(1234);
    is $name, 1234, 'invalid value is returned';
    is $err, undef, 'No error';
};

done_testing;
