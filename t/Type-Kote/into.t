use Test2::V0;
use Types::Standard qw(Str Int Dict ArrayRef);

use kote Name => Str;

subtest 'Test `into` method' => sub {

    subtest 'Given non parameterizable type' => sub {
        ok dies { Name->into(Str) };
        ok dies { Name->into(sub { 1 }) };
    };

    subtest 'Given parameterizable type' => sub {
        my $List = Name->into(ArrayRef);
        isa_ok $List, 'Type::Kote', 'Type::Tiny';
        is $List->display_name, 'ArrayRef[Name]', 'display_name';

        my ($names, $err) = $List->create(['Alice', 'Bob']);
        ok !$err, 'No error';
        is $names, ['Alice', 'Bob'];
    };

    subtest 'Given parameterizable type with arguments' => sub {
        my $List = Name->into(ArrayRef, 1, 2);
        isa_ok $List, 'Type::Kote', 'Type::Tiny';
        is $List->display_name, 'ArrayRef[Name,1,2]', 'display_name';

        my ($names, $err) = $List->create(['Alice', 'Bob']);
        ok !$err, 'No error';
        is $names, ['Alice', 'Bob'];

        ($names, $err) = $List->create(['Alice', 'Bob', 'Charlie']);
        ok $err, 'Error';
        is $names, undef;
    };
};

done_testing;
