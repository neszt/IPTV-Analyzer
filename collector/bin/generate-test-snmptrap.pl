#!/usr/bin/perl -w -I../lib/

=head1 NAME

generate-test-snmptrap - Manually generating a collector snmptrap

=head1 SYNOPSIS

 generate-test-snmptrap [options]

This program can be used for test-generating different types of SNMP
traps, which is generated by the iptv-collector in different error
situations.  This is very useful when adjusting you infrastructure to
handle these different types of traps, without having to provoke these
errors in production.

=cut

use strict;
use warnings;
use Data::Dumper;

use IPTV::Analyzer::Config;
my $cfg = get_config();
#my $cfg = IPTV::Analyzer::Config->new();

#use IPTV::Analyzer::mpeg2ts;
use IPTV::Analyzer::snmptrap;


use Getopt::Long qw(:config no_ignore_case);
use Pod::Usage;

my %opt;
my ($opt_help, $opt_man);

GetOptions(
  'traphost|h=s'  => \$opt{traphost},
  'community=s'   => \$opt{community},
  'multicast=s'   => \$opt{multicast},
  'src_ip'        => \$opt{src_ip},
  'help!'         => \$opt_help,
  'man!'          => \$opt_man
) or pod2usage(-verbose => 0);

pod2usage(-verbose => 1) if defined $opt_help;
pod2usage(-verbose => 2) if defined $opt_man;

# Assign default values if not defined
$opt{traphost}  = $opt{traphost}   || '127.0.0.1';
$opt{community} = $opt{community}  || 'public';
$opt{multicast} = $opt{multicast}  || '224.224.224.224';
$opt{src_ip}    = $opt{src_ip}     || '10.10.10.42';

=head2 OPTIONS

    --traphost|-h  Who to send the trap to (default: 127.0.0.1)
    --community    The SNMPv2 community (default: public)
    --multicast    The multicast dst address having issues (default: 224.1.2.3)
    --src_ip       The streams source IP-address (default:10.10.10.42)

=cut

print "open_snmp_session() to $opt{traphost}\n";
my $res_ses = open_snmp_session($opt{traphost}, $opt{community});
#open_snmp_session("127.0.0.1", "public");
if (!$res_ses) {
    print " - ERROR: cannot open session\n";
} else {
    print " - Established SNMP session\n";
}


print "send_snmptrap()\n";
my $res = send_snmptrap(4, "no_signal", $opt{multicast}, $opt{src_ip});
if (!$res) {
    print " - ERROR: cannot send snmptrap\n";
} else {
    print " - SNMP trap transmitted\n";
}


print "close_snmp_session()\n";
close_snmp_session();

#print "send_snmptrap()\n";
#send_snmptrap();

print "END\n";
