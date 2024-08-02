package Order::Service;

use strict;
use warnings;
use utf8;
use lib 't/lib';

our @EXPORT_OK;
push @EXPORT_OK, qw(order);

use Carp qw(croak);
use Types::Standard -types;

use Order::Customer qw(Customer);
use Order::Menu qw(Menu);

use kote OrderMenu => Dict[
    menu => Menu,
    amount => Int,
];

use kote Order => Dict[
    customer => Customer,
    list => ArrayRef[OrderMenu],
];

sub order {
    my ($customer, $menu, $amount) = @_;

    my $err;

    (my $order_menu, $err) = OrderMenu->create({
        menu => $menu,
        amount => $amount,
    });
    return (undef, $err) if $err;

    Order->create({
        customer => $customer,
        list => [$order_menu],
    });
}

1;
