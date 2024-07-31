use Test2::V0;

use Carp qw(croak);
use Types::Standard qw(Str Dict);
use Types::Common::String qw(StrLength);

use constant ASSERT => 1;

use caseval UnvalidatedCustomerInfo => Dict[
    first_name => Str,
    last_name => Str,
    email_address => Str,
];

use caseval PersonalName => Dict[
    first_name => StrLength[1, 100],
    last_name => StrLength[1, 100],
];

use caseval EmailAddress => Str; # TODO

use caseval CustomerInfo => Dict[
    name => PersonalName,
    email_address => EmailAddress
];

sub toCustomerInfo {
    my ($info) = @_;
    ASSERT && UnvalidatedCustomerInfo->assert_valid($info);

    croak "Must handle error" unless wantarray;

    my $err;

    (my $name, $err) = PersonalName->create({
        first_name => $info->{first_name},
        last_name => $info->{last_name},
    });
    return (undef, $err) if $err;

    (my $email_address, $err) = EmailAddress->create($info->{email_address});
    return (undef, $err) if $err;

    (my $customer_info, $err) = CustomerInfo->create({
        name => $name,
        email_address => $email_address,
    });
    return (undef, $err) if $err;

    return ($customer_info, undef);
}

subtest 'main' => sub {
    my $err;

    (my $info, $err) = UnvalidatedCustomerInfo->create({
        first_name => 'Alice',
        last_name => 'Liddell',
        email_address => '...',
    });
    ok !$err, 'No error';

    (my $customer_info, $err) = toCustomerInfo($info);
    ok !$err, 'No error';

    # call domain logic
    is $customer_info->{name}{first_name}, 'Alice';
};

subtest 'fail' => sub {
    my $err;

    (my $info, $err) = UnvalidatedCustomerInfo->create({
        first_name => 'Alice' x 100,
        last_name => 'Liddell',
        email_address => '...',
    });
    ok !$err, 'No error';

    (my $customer_info, $err) = toCustomerInfo($info);
    ok $err, 'Error';
};

done_testing;
