package Messager::Producers;

use strict;
use warnings;

use base 'Messager::Base';

use threads;
use threads::shared;

sub server {
    my( $class, $queue ) = @_;
    return $class -> SUPER::server(
        'producers' => sub {
            my( $server ) = @_;
            while (
                my $client = $server -> accept()
            ) {
                threads -> create(
                    sub {
                        local $SIG{'KILL'} = sub {
                            $client -> close();
                            threads -> exit();
                        };
                        my $type = $client -> getline()
                            or return $class -> error(
                                'Producer first line should be server name'
                            );
                        $class -> log(
                            'Got producer client: '
                            . substr $type, 0, -1
                        );
                        substr $type, -1, 1, "\t";
                        while ( <$client> ) {
                            lock $queue;
                            push @$queue => $type . $_;
                            cond_signal $queue;
                        }
                    }
                ) -> detach();
            }
        }
    );
}

1;
