package Nick::Messager::Consumer;

use strict;
use warnings;

use base 'Nick::Messager';

use IO::Select;

=pod

=head1 NAME

Nick::Messager::Consumer - Connect to a messager service as a consumer.

=head1 SYNOPSIS

    use Nick::Messager qw( %MESSAGER_PORTS $MESSAGER_SERVER );
    use Nick::Messager::Consumer;

    # $MESSAGER_SERVER = 'hostname';
    # $MESSAGER_PORTS{'consumer'} = port;

    my $server = Nick::Messager::Consumer -> new();
    my @line;
    while ( @line = $server -> get() ) {
        printf "%s\n", join '|', @line;
    }
    die 'Server gone.';

=cut

sub new {
    my( $class ) = @_;
    my $server = $class -> connect();
    my $select = IO::Select -> new();
    $select -> add( $server );
    return bless {
        'server' => $server,
        'select' => $select
    } => $class;
}

sub connect {
    my $fh = $_[0] -> SUPER::connect( 'consumer' );
    print $fh "Messager\n\n";
    return $fh;
}

sub get {
    my( $self ) = @_;
    exists( $$self{'server'} )
        or return ();
    my $line;
    if (
        $$self{'server'} -> connected() && defined(
            $line = $$self{'server'} -> getline()
        )
    ) {
        return split "\t", substr(
            $line, 0, -1
        );
    } else {
        $self -> close();
        return ();
    }
}

sub can_read {
    my( $self, $timeout ) = @_;
    return $$self{'server'} -> connected()
        && $$self{'select'} -> can_read( $timeout || 0 );
}

sub flush {
    my( $self ) = @_;
    exists( $$self{'server'} )
        or return;
    my( $server, $select ) = @$self{ qw( server select ) };
    while (
        $server -> connected()
        && $select -> can_read( 0 )
    ) {
        $server -> getline()
    }
}

sub close {
    my( $self ) = @_;
    exists(
        $$self{'server'}
    ) && exists(
        $$self{'select'}
    ) and delete(
        $$self{'select'}
    ) -> remove(
        $$self{'server'}
    );
    $self -> SUPER::close();
}

1;
