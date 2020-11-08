#!/usr/bin/perl -w

use strict;
use warnings;

BEGIN {
    exists( $ENV{'MESSAGER_HOME'} )
        or die "Environment variable MESSAGER_HOME isn't set";
}

use lib $ENV{'MESSAGER_HOME'} . 'lib';

use Nick::Error ':try';
use Messager::Config;
use Nick::Messager '%MESSAGER_PORTS';
use Nick::Messager::Consumer;
use Messager::Consumers::EventSource '$HEADER';


BEGIN {
    $MESSAGER_PORTS{'consumer'}
        = Messager::Config -> instance()
            -> consumers();
}

$| = 1;

{
    if (
        $ENV{'REQUEST_METHOD'} eq 'GET'
        &&
        exists( $ENV{'HTTP_ACCEPT'} )
        &&
        $ENV{'HTTP_ACCEPT'} eq 'text/event-stream'
    ) {
        printf $HEADER => 'keep-alive';
        try {
            my $server = Nick::Messager::Consumer -> new();
            my @line;
            while ( @line = $server -> get() ) {
                printf "data: %s\n\n", join "\t", @line;
            }
            warn "Message server gone.";
        } catch Nick::Error with {
            warn shift() -> text();
        };
    } else {
        printf $HEADER => 'close';
    }
}
