package Messager::Consumers::WebSocket;

use strict;
use warnings;

use base 'Messager::Consumers::TCP';

use Digest::SHA 'sha1_base64';

sub type {
    return 'websocket';
}

sub add {
    my( $self, $client, $get ) = splice @_, 0, 3;
    $get =~ m'^GET /\??(.*?) HTTP/1.1$'
        or return 0;
    my %headers = map(
        { split ': ', $_, 2 }
        @_
    );
    exists( $headers{'Upgrade'} )
        && $headers{'Upgrade'} eq 'websocket'
            or return 0;
    my $key = $headers{'Sec-WebSocket-Key'}
        or return 0;
    my $digest = sha1_base64(
        $key . '258EAFA5-E914-47DA-95CA-C5AB0DC85B11'
    );
    $key = length( $digest ) % 4
        and $digest .= '=' x ( 4 - $key );
    $client -> blocking( 1 );
    print $client join( "\r\n",
        'HTTP/1.1 101 Switching Protocols',
        'Upgrade: websocket',
        'Connection: Upgrade',
        'Sec-WebSocket-Accept: ' . $digest,
        'Sec-WebSocket-Protocol: chat',
        '', ''
    );
    $self -> SUPER::add(
        $client, 'Messager', split /\+/, $1
    );
    return 1;
}

sub send {
    my( $self, $type, $line ) = @_;
    chomp $line;
    substr( $line, 0, 0 ) = pack 'C2', 129, length $line;
    $self -> SUPER::send( $type, $line );
}

1;
