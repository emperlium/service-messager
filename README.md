# service-messager

Lightweight messaging system along the lines of D-Bus but much simpler.

Messages consist of an array of strings.

## CPAN dependencies

 * IO::Socket::INET
 * Time::HiRes
 * Config::General
 * IO::Select
 * IO::Pipe

## Installation

You'll also need to install the lib-base repository from this account.

    sudo -s
    adduser --system --group messager
    passwd messager
    chmod 775 /home/messager
    exit
    newgrp messager
    cd /home/messager
    git clone git@github.com:emperlium/service-messager.git .
    cd config
    ln -s messager.conf.example messager.conf
    ln -s apache.conf.example apache.conf
    cd ../htdocs
    ln -s MessagerConfig.js.example MessagerConfig.js
    cd ../setup/module
    perl Makefile.PL
    sudo -s
    make install
    cp -p /home/messager/setup/messager.service /etc/systemd/system/
    systemctl enable messager
    systemctl start messager
    systemctl status messager
    ln -s /home/messager/config/apache.conf /etc/apache2/conf-enabled/messager.conf
    apache2ctl graceful

## Usage

If you need to connect to a server that isn't on the default host/ port.

    use Nick::Messager qw( %MESSAGER_PORTS $MESSAGER_SERVER );
    $MESSAGER_SERVER = 'hostname';
    $MESSAGER_PORTS{'consumer'} = port;
    $MESSAGER_PORTS{'producer'} = port;

Connect as a producer.

    use Nick::Messager::Producer;

    my $server = Nick::Messager::Producer -> new( 'producer_name' );
    for ( my $i = 1; $i <= 10; $i++ ) {
        $server -> send( 'event' => $i );
        sleep 1;
    }
    $server -> close();

Connect as a consumer.

    use Nick::Messager::Consumer;
    my $server = Nick::Messager::Consumer -> new();
    my @line;
    while ( @line = $server -> get() ) {
        printf "%s\n", join '|', @line;
    }
    die 'Server gone.';
