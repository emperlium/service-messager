package Messager::Main;

use strict;
use warnings;

use base 'Messager';

use threads;
use threads::shared;

use IO::Pipe;

use Nick::Log;

use Messager::Producers;
use Messager::Consumers;

use sigtrap 'handler' => sub{
    Messager -> error( 'Caught a PIPE signal' );
} => 'PIPE';

sub run {
    my( $class ) = @_;
    my @queue :shared;
    Messager::Producers -> server( \@queue )
        or return;
    my $pipe = IO::Pipe -> new();
    Messager::Consumers -> server( $pipe )
        or return;
    $pipe -> writer();
    $pipe -> autoflush( 1 );
    $class -> started();
    for ( ;; ) {
        lock @queue;
        cond_wait @queue;
        lock @queue;
        while ( @queue ) {
            print $pipe shift( @queue );
        }
    }
}

sub started {
}

1;
