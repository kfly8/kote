requires 'perl', '5.020000';

requires 'Data::Lock';
requires 'Type::Tiny', '1.010002';

on 'test' => sub {
    requires 'Test2::Suite', '0.000140';
};

on configure => sub {
    requires 'Module::Build::Tiny', '0.035';
};
