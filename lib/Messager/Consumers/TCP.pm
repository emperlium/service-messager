package Messager::Consumers::TCP;

use strict;
use warnings;

use base qw(
    Nick::StandardBase
    IO::Select
);

sub type {
    return 'tcp';
}

sub add {
    @_ == 3 && $_[2] eq 'Messager'
        or return 0;
    $_[0] -> SUPER::add( $_[1] );
    return 1;
}

sub send {
    my( $self, $line ) = @_;
    my $wrote = 0;
    for (
        $self -> can_write( 0 )
    ) {
        if ( $_ -> connected() ) {
            print $_ $line;
            $wrote ++;
        } else {
            $self -> remove( $_ );
        }
    }
    $wrote >= $self -> count()
        and return;
    for ( grep
        ! $_ -> connected(),
        $self -> handles()
    ) {
        $self -> remove( $_ );
    }
}

1;
