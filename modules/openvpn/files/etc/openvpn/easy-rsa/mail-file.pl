#!/usr/bin/perl -W

use strict;
use MIME::Lite;
use Getopt::Long;
use File::Basename;
use Net::Domain qw(hostname hostfqdn hostdomain domainname);

my $to = "";
my $file = "";

GetOptions ( "to=s"    => \$to,
             "file=s"  => \$file);


die("option --to is missing or has no email address format") if (!defined $to or !length $to or $to !~ /^[^@]+@[^@]+$/);
die("option --file is missing") if (!defined $file or !length $file);
die("no such file $file") if (!-f $file);

my $f = basename($file);
my $cert = $f;
$cert =~ s/\.txt$//;

my $mail = MIME::Lite->new(
    From     => 'root@'.hostfqdn(),
    To       => "$to",
    Subject  => "new OpenVPN certificate for $to",
    Type     => 'multipart/mixed'
);

$mail->attach(Type     => 'TEXT',
              Data     => "Hello,

today you receive a new OpenVPN certificate file for accessing ".hostfqdn().".

Instructions:
1) save the attached file ($f) to disk
2) rename it to $cert (remove .txt suffix)
3) replace your existing certificate file with it

Look at the following instructions for further help.

Regards
openvpn team


#################################
## for OSX / Tunnelblick users ##

Disconnect from ".hostfqdn()." OpenVPN tunnel first.

Your Tunnelblick configuration and certificates should be located at the
following directory:

~/Library/Application Support/Tunnelblick/Configurations/".hostfqdn().".tblk/Contents/Resources

See http://code.google.com/p/tunnelblick/wiki/cFileLocations#Configuration_Files
for further instructions if you have problems where to find your Turnnelblick
configuration.

Use a command line to copy $cert to the following directory.
Using the Finder will probably not work since you cannot enter the ".hostfqdn().".tblk
subdirectory by double click.

When connecting to ".hostfqdn()." OpenVPN again Tunnelblick will ask you to verify
the changes you made with your password. Please do so.



######################
## for Windows user ##

Disconnect from ".hostfqdn()." OpenVPN tunnel first.

Copy $cert to the directory where you have your OpenVPN configuration.
Usually its something like c:\\programm files\\openvpn\\config\\.
This will replace the existing certificate with the new file.

Maybe you need to restart your OpenVPN Client Gui. Try to start the tunnel.

###########################################################
###########################################################


");

$mail->attach(Type     => 'text/plain',
              Path     => $file,
              Filename => basename($file),
              Disposition => 'attachment'
);


$mail->send;


