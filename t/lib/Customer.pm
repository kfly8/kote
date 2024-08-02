package Customer;
use strict;
use warnings;

use Types::Standard -types;
use Types::Common::String -types;
use Carp qw(croak);

use kote UnvalidatedCustomerInfo => Dict[
    first_name => Str,
    last_name => Str,
    email_address => Str,
];

use kote PersonalName => Dict[
    first_name => StrLength[1, 100],
    last_name => StrLength[1, 100],
];

use kote EmailAddress => Str; # TODO

use kote CustomerInfo => Dict[
    name => PersonalName,
    email_address => EmailAddress
];

sub toCustomerInfo {
    my ($info) = @_;
    UnvalidatedCustomerInfo->assert_valid($info);

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


