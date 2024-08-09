use Test2::V0;
use Types::Standard qw(Str Int Dict ArrayRef);

use kote Name => Str;

subtest 'Test `item_of` method' => sub {

    subtest 'Given non parameterizable type' => sub {
        ok dies { Name->item_of(Str) };
        ok dies { Name->item_of(sub { 1 }) };
    };

    subtest 'Given parameterizable type' => sub {
        my $List = Name->item_of(ArrayRef);
        isa_ok $List, 'Type::Kote', 'Type::Tiny';
        is $List->display_name, 'ArrayRef[Name]', 'display_name';

        my ($names, $err) = $List->create(['Alice', 'Bob']);
        ok !$err, 'No error';
        is $names, ['Alice', 'Bob'];
    };

    subtest 'Given parameterizable type with arguments' => sub {
        my $List = Name->item_of(ArrayRef, 1, 2);
        isa_ok $List, 'Type::Kote', 'Type::Tiny';
        is $List->display_name, 'ArrayRef[Name,1,2]', 'display_name';

        my ($names, $err) = $List->create(['Alice', 'Bob']);
        ok !$err, 'No error';
        is $names, ['Alice', 'Bob'];

        ($names, $err) = $List->create(['Alice', 'Bob', 'Charlie']);
        ok $err, 'Error';
        is $names, undef;
    };

    subtest 'Given parameterizable Type::Kote' => sub {

        use kote MyList => Type::Kote->new(
            name_generator => sub {
                my ($me, $T) = @_;
                return sprintf("MyList[%s]", $T->display_name);
            },
            constraint_generator => sub {
                my ($T) = @_;
                return sub {
                    my ($value) = @_;
                    return 0 unless ref $value eq 'ARRAY';
                    return 0 if grep { !$T->check($_) } @$value;
                    return 1;
                }
            },
        );

        my $List = Name->item_of(MyList);
        isa_ok $List, 'Type::Kote', 'Type::Tiny';
        is $List->display_name, 'MyList[Name]', 'display_name';

        my ($names, $err) = $List->create(['Alice', 'Bob']);
        ok !$err, 'No error';
        is $names, ['Alice', 'Bob'];
    };
};

done_testing;
