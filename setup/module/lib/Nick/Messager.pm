package Nick::Messager;

use strict;
use warnings;

use base qw( Nick::StandardBase Exporter );

use IO::Socket::INET;

our(
    $VERSION, @EXPORT_OK, %MESSAGER_PORTS, $MESSAGER_SERVER, $MESSAGER_TIMEOUT,
    $MESSAGER_BLOCKING
);

BEGIN {
    $VERSION = '1.00';
    @EXPORT_OK = qw(
        %MESSAGER_PORTS $MESSAGER_SERVER $MESSAGER_TIMEOUT
        $MESSAGER_BLOCKING
    );
    %MESSAGER_PORTS = qw(
        producer 8024
        consumer 8025
    );
    $MESSAGER_SERVER = '127.0.0.1';
    $MESSAGER_TIMEOUT = 5;
    $MESSAGER_BLOCKING = 1;
}

sub connect {
    my( $class, $type ) = @_;
    exists( $MESSAGER_PORTS{$type} )
        or $class -> throw(
            'Unknown messager type: ' . $type
        );
    return(
        IO::Socket::INET -> new(
            'PeerAddr'  => $MESSAGER_SERVER,
            'PeerPort'  => $MESSAGER_PORTS{$type},
            'Proto'     => 'tcp',
            'Type'      => SOCK_STREAM,
            'Timeout'   => $MESSAGER_TIMEOUT,
            'Blocking'  => $MESSAGER_BLOCKING
        ) or $class -> throw(
            "Unable to connect to $type messager at $MESSAGER_SERVER:$MESSAGER_PORTS{$type}: $@"
        )
    );
}

1;
