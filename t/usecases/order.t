use Test2::V0;

use lib 't/lib';

use Order::Customer qw(toCustomer);
use Order::Menu qw(Menu);
use Order::Service qw(order);

subtest 'order' => sub {
    my $err;

    (my $alice, $err) = toCustomer({ first_name => 'Alice', last_name => 'Liddell', email_address => ''});
    ok !$err;

    (my $menu, $err) = Menu->create({name => 'Curry', price => 1000});
    ok !$err;

    (my $order, $err) = order($alice, $menu, 2);
    ok !$err;

    is $order, {
        customer => {
            name => {
                first_name => 'Alice',
                last_name => 'Liddell',
            },
            email_address => '',
        },
        list => [
            {
                menu => {
                    name => 'Curry',
                    price => 1000,
                },
                amount => 2,
            },
        ],
    };
};

done_testing;
