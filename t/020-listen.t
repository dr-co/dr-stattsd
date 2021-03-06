#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use open qw(:std :utf8);
use lib qw(lib ../lib t/lib);

use Test::More tests    => 11;
use Encode qw(decode encode);


BEGIN {
    use_ok 'DR::Statsd::Test';
    use_ok 'DR::Statsd::Proxy';

    use_ok 'Coro';
    use_ok 'Coro::AnyEvent';
}


my $port = free_port;
like $port => qr{^\d+$}, 'free port found';

my $rport = free_port;
like $rport => qr{^\d+$}, 'free port for remote found';

isnt $rport, $port, 'Ports are not the same';

my $s = new DR::Statsd::Proxy
                bind_port       => $port,
                parent          => "udp://127.0.0.1:$rport"
;

isa_ok $s => DR::Statsd::Proxy::, 'instance created';

ok $s->start, 'started';
        

my $sc = IO::Socket::INET->new(
            PeerAddr    => '127.0.0.1',
            PeerPort    => $port,
            Proto       => 'tcp',
        );
diag $! unless
    ok $sc, 'connected';


ok $s->stop, 'stopped';

