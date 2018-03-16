package Messager::Config;

use strict;
use warnings;

use base qw( Messager Class::Singleton );

use Messager '$MESSAGER_HOME';

use Config::General ();

our( $CONFIG_FILE, $AUTOLOAD );

BEGIN {
    $CONFIG_FILE = $MESSAGER_HOME . 'config/messager.conf';
}

sub _new_instance {
    my( $class ) = @_;
    -f $CONFIG_FILE or $class -> throw(
        'Missing config file: ' . $CONFIG_FILE
    );
    my $conf = Config::General -> new(
        '-file'                 => $CONFIG_FILE,
        '-AllowMultiOptions'    => 1,
    ) or $class -> throw(
        'Unable to initialise Config::General with file: ' . $CONFIG_FILE
    );
    return bless {
        $conf -> getall()
    } => $class;
}

sub get {
    my $got = shift;
    for ( @_ ) {
        ref( $got ) && exists( $$got{$_} )
            or last;
        $got = $$got{$_};
    }
    return $got;
}

sub AUTOLOAD {
    substr( $AUTOLOAD, -7 ) eq 'DESTROY'
        and return;
    substr $AUTOLOAD, 0, rindex( $AUTOLOAD, ':' ) + 1, '';
    return exists( $_[0] -> {$AUTOLOAD} )
        ? $_[0] -> {$AUTOLOAD}
        : undef;
}

1;
