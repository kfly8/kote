package kote;
use strict;
use warnings;

our $VERSION = "0.01";

use Carp qw(croak);
use Scalar::Util qw(blessed);
use Type::Tiny;

use Type::Kote;

# kote name must be CamelCase
my $normal_kote_name = qr/^[A-Z][a-zA-Z0-9]*$/;

my %forbidden_kote_name = map { $_ => 1 } qw{
    BEGIN CHECK DESTROY END INIT UNITCHECK
    AUTOLOAD STDIN STDOUT STDERR ARGV ARGVOUT ENV INC SIG
};

sub import {
    my $class = shift;
    my ($name, $type) = @_;

    if (my $e = _validate_name($name)) {
        croak($e);
    }

    my $caller = caller;
    if ($caller->can($name)) {
        croak "'$name' is already defined.";
    }

    $type = Types::TypeTiny::to_TypeTiny($type);
    unless (blessed($type) && $type->isa('Type::Tiny')) {
        croak "Invalid type for '$name'";
    }

    my $ktype = Type::Kote->new(
        name   => $name,
        parent => $type,
    );

    $ktype->coercion->freeze;
    unless ($caller->can('meta')) {
        require Type::Library;
        Type::Library->import({ into => $caller }, '-base');
    }

    $caller->meta->add_type($ktype);
}

sub _validate_name {
    my ($name) = @_;

    if (!$name) {
        return 'kote name is not given';
    }
    elsif ($name !~ $normal_kote_name) {
        return "kote name '$name' is not CamelCase.";
    }
    elsif ($forbidden_kote_name{$name}) {
        return "kote name '$name' is forbidden.";
    }

    return;
}

1;
__END__

=encoding utf-8

=head1 NAME

kote - It's new $module

=head1 SYNOPSIS

    use kote;

=head1 DESCRIPTION

kote is ...

=head1 LICENSE

Copyright (C) kobaken.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

kobaken E<lt>kentafly88@gmail.comE<gt>

=cut

