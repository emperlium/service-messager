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
    '', ''
);

sub add {
    $_[2] eq 'GET / HTTP/1.1'
        or return 0;
    for ( my $i = 3; $i <= $#_; $i ++ ) {
        if ( $_[$i] eq 'Accept: text/event-stream' ) {
            $_[0] -> SUPER::add( $_[1] );
            $_[1] -> print( $HEADER );
            return 1;
        }
    }
    return 0;
}

sub send {
    $_[0] -> SUPER::send(
        'data: ' . $_[1] . "\n"
    );
}

1;
