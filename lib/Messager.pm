package Messager;

use strict;
use warnings;

use base qw( Nick::StandardBase Exporter );

our( @EXPORT_OK, $MESSAGER_HOME );

BEGIN {
    @EXPORT_OK = qw(
        $MESSAGER_HOME
    );
    exists( $ENV{'MESSAGER_HOME'} )
        or Messager -> throw(
            q{Environment variable MESSAGER_HOME isn't set}
        );
    $MESSAGER_HOME = $ENV{'MESSAGER_HOME'};
    -d $MESSAGER_HOME
        or Messager -> throw(
            'Missing MESSAGER_HOME dir: ' . $MESSAGER_HOME
        );
}

1;
