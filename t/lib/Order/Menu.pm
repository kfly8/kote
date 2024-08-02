package Order::Menu;

use strict;
use warnings;
use utf8;

use Carp qw(croak);
use Types::Standard -types;

use kote MenuName => Str;
use kote MenuPrice => Int;

use kote Menu => Dict[
    name => MenuName,
    price => MenuPrice,
];

1;
