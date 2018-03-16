#!/usr/bin/perl -w

use strict;
use warnings;

use Nick::HandleBinEnvDir;
use Nick::SystemdNotifier;

BEGIN {
    Nick::HandleBinEnvDir -> handle( 'MESSAGER_HOME' );
}

use Messager::Main;

Nick::SystemdNotifier -> run( 'Messager::Main' );
