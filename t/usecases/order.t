use Test2::V0;

use lib 't/lib';

use Order::Customer qw(toCustomer);
use Order::Menu qw(Menu);
use Order::Service qw(toOrder order_total_price);

subtest 'order_total_price' => sub {
    my $err;

    (my $alice, $err) = toCustomer({ first_name => 'Alice', last_name => 'Liddell', email_address => ''});
    ok !$err;

    (my $menu, $err) = Menu->create({name => 'Curry', price => 1000});
    ok !$err;

    (my $order, $err) = toOrder($alice, $menu, 2);
    ok !$err;

    is order_total_price($order), 2000;

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
