package Messager::Consumers;

use strict;
use warnings;

use base 'Messager::Base';

use IO::Select;

use Messager::Consumers::TCP;
use Messager::Consumers::EventSource;
use Messager::Consumers::WebSocket;

sub server {
    my( $class, $pipe ) = @_;
    return $class -> SUPER::server(
        'consumers' => sub {
            my( $server ) = @_;
            my $read_select = IO::Select -> new();
            $read_select -> add( $server );
            $pipe -> reader();
            $pipe -> blocking( 0 );
            $read_select -> add( $pipe );
            my( $client, $line, @request, $started );
            my @consumers = map(
                $_ -> new(), qw(
                    Messager::Consumers::TCP
                    Messager::Consumers::EventSource
                    Messager::Consumers::WebSocket
                )
            );
            my $client_select = IO::Select -> new();
            my( $id, $type );
            my $handle_client = sub {
                $started = time;
                $#request = -1;
                $client -> blocking( 0 );
                while (
                    $client_select -> can_read( 1 )
                    &&
                    time - $started < 3
                    &&
                    @request < 30
                ) {
                    for $line ( $client -> getlines() ) {
                        $line =~ s/\r?\n$//;
                        if ( $line ) {
                            push @request => $line;
                        } else {
                            for ( @consumers ) {
                                if (
                                    $type = $_ -> add( $client, @request )
                                ) {
                                    shift @request;
                                    $type == 1 and $class -> log( sprintf
                                        'Got %s consumer client (%s): %s',
                                        $_ -> type(),
                                        join( '|', $_ -> last_types() ),
                                        $client -> peerhost()
                                    );
                                    return;
                                }
                            }
                            last;
                        }
                    }
                }
                $class -> error( sprintf
                    'Rejecting client from %s after %d secs with request: %s',
                    $client -> peerhost(),
                    time - $started,
                    join ' | ', @request
                );
                $client -> close();
            };
            for ( ;; ) {
                for (
                    $read_select -> can_read()
                ) {
                    if ( $_ == $server ) {
                        $client = $server -> accept();
                        $client -> autoflush( 1 );
                        $client_select -> add( $client );
                        &$handle_client();
                        $client_select -> remove( $client );
                    } else {
                        while ( $line = $pipe -> getline() ) {
                            $type = substr( $line, 0, index $line, "\t" );
                            for (
                                grep $_ -> count(), @consumers
                            ) {
                                $_ -> send( $type, $line );
                            }
                        }
                    }
                }
            }
        }
    );
}

1;
