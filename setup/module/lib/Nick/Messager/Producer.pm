package Nick::Messager::Producer;

use strict;
use warnings;

use base 'Nick::Messager';

=pod

=head1 NAME

Nick::Messager::Producer - Connect to a messager service as a producer.

=head1 SYNOPSIS

    use Nick::Messager qw( %MESSAGER_PORTS $MESSAGER_SERVER );
    use Nick::Messager::Producer;

    # $MESSAGER_SERVER = 'hostname';
    # $MESSAGER_PORTS{'producer'} = port;

    my $server = Nick::Messager::Producer -> new( 'producer_name' );
    for ( my $i = 1; $i <= 10; $i++ ) {
        $server -> send( 'event' => $i );
        sleep 1;
    }
    $server -> close();

=cut

sub new {
    my( $class, $type ) = @_;
    my $server = $class -> connect();
    $server -> autoflush( 1 );
    $server -> print( $type, "\n" );
    return bless { 'server' => $server } => $class;
}

sub connect {
    return $_[0] -> SUPER::connect( 'producer' );
}

sub send {
    my $self = shift;
    exists( $$self{'server'} )
        or return 0;
    if ( $$self{'server'} -> connected() ) {
        $$self{'server'} -> print(
            join( "\t", @_ ), "\n"
        );
        return 1;
    } else {
        $self -> close();
        return 0;
    }
}

sub close {
    my( $self ) = @_;
    exists( $$self{'server'} ) or return;
    my $server = delete $$self{'server'};
    if ( $server -> connected() ) {
        $server -> flush();
        $server -> shutdown( 2 );
        $server -> close();
    }
}

1;
