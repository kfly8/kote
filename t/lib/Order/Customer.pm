package Order::Customer;

use strict;
use warnings;
use utf8;

our @EXPORT_OK;
push @EXPORT_OK, qw(toCustomer);

use Carp qw(croak);
use Types::Standard -types;

use kote UnvalidatedCustomer => Dict[
    first_name => Str,
    last_name => Str,
    email_address => Str,
];

use kote Str100 => Str & sub {
    my $l = length($_);
    1 <= $l && $l <= 100;
};

use kote PersonalName => Dict[
    first_name => Str100,
    last_name => Str100,
];

use kote EmailAddress => Str; # TODO

use kote Customer => Dict[
    name => PersonalName,
    email_address => EmailAddress
];

sub toCustomer {
    my ($info) = @_;
    UnvalidatedCustomer->assert_valid($info);

    croak "Must handle error" unless wantarray;

    my $err;

    (my $name, $err) = PersonalName->create({
        first_name => $info->{first_name},
        last_name => $info->{last_name},
    });
    return (undef, $err) if $err;

    (my $email_address, $err) = EmailAddress->create($info->{email_address});
    return (undef, $err) if $err;

    (my $customer, $err) = Customer->create({
        name => $name,
        email_address => $email_address,
    });
    return (undef, $err) if $err;

    return ($customer, undef);
}

1;
