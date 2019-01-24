package Messager::Consumers::EventSource;

use strict;
use warnings;

use base qw(
    IO::Select
    Messager::Consumers::TCP
);

sub type {
    return 'eventsource';
}

our $HEADER = join( "\r\n",
    'HTTP/1.1 200 OK',
    'Content-Type: text/event-stream',
    'Cache-Control: no-cache',
    'Access-Control-Allow-Origin: *',
    'Connection: %s',
    '', ''
);

sub add {
    my( $self, $client, $req, @headers ) = @_;
    if ( $req eq 'GET / HTTP/1.1' ) {
        for ( @headers ) {
            if ( $_ eq 'Accept: text/event-stream' ) {
                $self -> SUPER::add( $client );
                $client -> printf( $HEADER => 'keep-alive' );
                return 1;
            }
        }
    } elsif ( $req eq 'HEAD / HTTP/1.1' ) {
        $client -> printf( $HEADER => 'close' );
        $client -> close();
        return 2;
    }
    return 0;
}

sub send {
    $_[0] -> SUPER::send( "data: $_[1]\n\n" );
}

1;
