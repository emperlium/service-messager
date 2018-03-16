#!/usr/bin/perl -w

use strict;
use warnings;

$| = 1;

use Nick::HandleBinEnvDir;

BEGIN {
    Nick::HandleBinEnvDir -> handle( 'MESSAGER_HOME' );
}

use base 'Nick::StandardBase';

use Nick::Messager qw( %MESSAGER_PORTS $MESSAGER_SERVER );
use Nick::Messager::Consumer;
use Messager::Config;

$MESSAGER_PORTS{'consumer'}
    = Messager::Config -> instance()
        -> consumers();
$MESSAGER_SERVER = 'localhost';

my $server = Nick::Messager::Consumer -> new();

main -> log(
    'Listening on port: ' . $MESSAGER_PORTS{'consumer'}
);
my @line;
while ( @line = $server -> get() ) {
    main -> log( join '|', @line );
}
main -> log( 'Server gone.' );
