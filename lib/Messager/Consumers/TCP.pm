package Messager::Consumers::TCP;

use strict;
use warnings;

use base 'Nick::StandardBase';

use IO::Select;

sub type {
    return 'tcp';
}

sub new {
    my( $class ) = @_;
    return bless {
        'select'    => IO::Select -> new(),
        'types'     => {}
    } => $class;
}

sub add {
    my( $self, $client, $name, @types ) = @_;
    $name && $name eq 'Messager'
        or return 0;
    $$self{'select'} -> add( $client );
    my $fn = $client -> fileno();
    @types or @types = ( 'all' );
    for ( @types ) {
        $$self{'types'}{$fn}{$_} = 1;
    }
    $$self{'last_types'} = \@types;
    return 1;
}

sub count {
    $_[0]{'select'} -> count();
}

sub last_types {
    return @{ $_[0]{'last_types'} };
}

sub send {
    my( $self, $type, $line ) = @_;
    my( $select, $types ) = @$self{ qw( select types ) };
    my $ready = 0;
    my $fn;
    for my $client (
        $select -> can_write( 0 )
    ) {
        if ( $client -> connected() ) {
            $ready ++;
            $fn = $client -> fileno();
            exists( $$types{$fn}{'all'} )
                || exists( $$types{$fn}{$type} )
                    and print $client $line;
        } else {
            $self -> remove( $client );
        }
    }
    $ready >= $select -> count()
        and return;
    for ( grep
        ! $_ -> connected(),
        $select -> handles()
    ) {
        $self -> remove( $_ );
    }
}

sub remove {
    my( $self, $client ) = @_;
    $$self{'select'} -> remove( $client );
    delete $$self{'types'}{
        $client -> fileno()
    };
}

1;
