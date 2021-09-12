package Messager::Consumers::EventSource;

use strict;
use warnings;

use base qw(
    Messager::Consumers::TCP
    Exporter
);

our( @EXPORT_OK, $HEADER );

BEGIN {
    $HEADER = join( "\r\n",
        'HTTP/1.1 200 OK',
        'Content-Type: text/event-stream',
        'Cache-Control: no-cache',
        'Access-Control-Allow-Origin: *',
        'Connection: %s',
        '', ''
    );
    @EXPORT_OK = qw( $HEADER );
}

sub type {
    return 'eventsource';
}

sub add {
    my( $self, $client, $req, @headers ) = @_;
    if ( $req =~ m'^GET /\??(.*?) HTTP/1.1$' ) {
        for ( @headers ) {
            if ( $_ eq 'Accept: text/event-stream' ) {
                $self -> SUPER::add(
                    $client, 'Messager', split /\+/, $1
                );
                $client -> printf( $HEADER => 'keep-alive' );
                return 1;
            }
        }
    } elsif ( $req =~ m'^HEAD /(.*?) HTTP/1.1$' ) {
        $client -> printf( $HEADER => 'close' );
        $client -> close();
        return 2;
    }
    return 0;
}

sub send {
    $_[0] -> SUPER::send( $_[1], "data: $_[2]\n\n" );
}

1;
