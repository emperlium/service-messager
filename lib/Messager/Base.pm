package Messager::Base;

use strict;
use warnings;

use threads;
use threads::shared;

use base 'Messager';

use IO::Socket::INET;

use Messager::Config;

sub server {
    my( $class, $type, $sub ) = @_;
    my $port = Messager::Config -> instance() -> get( $type );
    my $ok :shared;
    threads -> create(
        sub {
            my $server = IO::Socket::INET -> new(
                'LocalPort'     => $port,
                'Type'          => SOCK_STREAM,
                'Reuse'         => 1,
                'Listen'        => 10
            );
            {
                lock $ok;
                if ( $server ) {
                    $ok = 1;
                    $class -> log(
                        "Started TCP $type server on port $port"
                    );
                } else {
                    $ok = 0;
                    $class -> error(
                        "Couldn't be a TCP $type server on port $port: $@"
                    );
                }
                cond_signal $ok;
            }
            local $SIG{'KILL'} = sub {
                $server -> close();
                threads -> exit();
            };
            $ok or return;
            &$sub( $server );
        }
    ) -> detach();
    lock $ok;
    cond_wait $ok;
    return $ok;
}

1;
