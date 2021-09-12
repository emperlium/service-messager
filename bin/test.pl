#!/usr/bin/perl -w

use strict;
use warnings;
no warnings 'threads';

use threads;

use Time::HiRes 'sleep';

use Nick::HandleBinEnvDir;

BEGIN {
    Nick::HandleBinEnvDir -> handle( 'MESSAGER_HOME' );
}

use Nick::Messager qw( %MESSAGER_PORTS $MESSAGER_SERVER $MESSAGER_BLOCKING );
use Nick::Messager::Consumer;
use Nick::Messager::Producer;
use Nick::Error;

$MESSAGER_SERVER = 'localhost';

our $CONSUMERS = 2;
our $PRODUCERS = 2;
our $SLEEP_OFF = 1;
our $SLEEP_MIN = .1;
our $MAX_LINES = 3;

#$MESSAGER_BLOCKING = 0;

use Messager::Config;

my $config = Messager::Config -> instance();
my $port;
for (
    qw( producer consumer )
) {
    $port = $config -> get( $_ . 's' );
    print "$_: $port\n";
    $MESSAGER_PORTS{$_} = $port;
}

$SIG{'KILL'} = sub {
    threads -> exit();
};

{  # consumers
    for my $name ( 1 .. $CONSUMERS ) {
        async {
            my $server = Nick::Messager::Consumer -> new(
                'producer_name_' . $name
            ) or return;
            my @line;
            while ( @line = $server -> get() ) {
                print join( '|', 'client' . $name, @line ), "\n";
            }
        };
    }
    async {
        my $server = Nick::Messager::Consumer -> new();
        my @line;
        while ( @line = $server -> get() ) {
            print join( '|', 'consumer', @line ), "\n";
            sleep $SLEEP_OFF * 2;
            $server -> flush();
        }
    };
}

my @producers;
{  # producers
    $MAX_LINES --;
    for ( 1 .. $PRODUCERS ) {
        push @producers => async {
            random_sleep();
            print "create server $_\n";
            my $server = Nick::Messager::Producer -> new( 'producer_name_' . $_ );
            my $max = int( rand $MAX_LINES ) + $MAX_LINES;
            for ( my $i = 1; $i <= $max; $i++ ) {
                $server -> send( 'event_name' => $i );
                random_sleep();
            }
            print "producer_name_$_ close after $max\n";
            $server -> send( 'finished' );
            $server -> close();
        };
    }
}

sub random_sleep {
    sleep ( rand $SLEEP_OFF ) + $SLEEP_MIN;
}

for ( ;; ) {
    grep( $_ -> is_running(), @producers )
        or last;
    sleep 1;
}

my $error;
for (
    threads -> list()
) {
    $error = $_ -> error()
        and $error -> error();
    $_ -> is_running()
        and $_ -> kill( 'KILL' );
    $_ -> is_detached()
        or $_ -> detach();
}
