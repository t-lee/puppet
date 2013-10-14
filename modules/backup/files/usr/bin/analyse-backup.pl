#!/usr/bin/perl -w

use strict;
use MIME::Lite;
use File::Basename;
use Sys::Hostname;
use Proc::ProcessTable;
use Parallel::ForkManager;
use Config::IniFiles;
use Data::Dumper;




my $max_exectime = 300;


#my $dir = "/var/log/backup";
my $backuplog = shift @ARGV;
&alert("arg1 'backup log file' is missing",1) unless defined $backuplog or not length $backuplog;
&alert("not such file $backuplog",1) unless -f $backuplog;

my $logrotate_extension = "";
if (basename($backuplog) =~ /\.log(.*)$/) {
    $logrotate_extension = $1;
}

### lets find lines like:
###
### 2013-10-08 00:44:37     15773           SYSCMD: rsync -R -av --delete --numeric-ids -e "ssh -oStrictHostKeyChecking=no -oBatchMode=yes -2"  --exclude '/proc/*' --exclude '/sys/*' --exclude '/mnt/*' --exclude '/run/' root@d-13.spreegle.de:/var/data/nfs/devbliss_nexus/ /mnt/devbliss_backup/2013-10-08_000004/d-13.spreegle.de/ >>/var/log/backup/d-13.spreegle.de-devbliss_nexus.log 2>&1
open(FH,$backuplog) or &alert("cannot read $backuplog: $!",1);
while ( my $line = <FH> ) {
    chomp($line);
    next if $line !~ /^\d\d\d\d-\d\d-\d\d\s+\d\d:\d\d:\d\d\s+\d+\s+SYSCMD: rsync\s+.+\s+(\S+@\S+)\s+(\S+)\s>>\s?(\S+)/;
#    &logmsg("$1\n$2\n$3");
    my $logfile = $3.$logrotate_extension;
    my $backup_folder = $2;

    &analyse_backup($logfile,$backup_folder);

}
close FH;

&end();



sub analyse_backup {
    my $logfile = shift;
    my $backup_folder = shift;

    my $size = 0;
    my $files = 0;
    my $dirs = 0;
    my $deleted_files = 0;
    my $unknown_lines = 0;
    open(PIPE,"$logfile") or &alert("cannot cat file $logfile: $!",1);
    while ( my $line = <PIPE> ) {
        chomp($line);
        next if $line =~ /^total size is/;
        next if $line =~ /^sent \d+ bytes/;
        next if $line =~ /^$/;
        next if $line =~ /receiving incremental file list/;
        next if $line =~ /some files vanished before they could be transferred/;
        if ( $line =~ /^deleting /) {
            $deleted_files++;
        } elsif (-f "$backup_folder/$line") {
            $size += (stat("$backup_folder/$line"))[7];
            $files++;
        } elsif (-d "$backup_folder/$line") {
            $dirs++;
        } else {
            $unknown_lines++;
        #    &syscmd("ls -la $backup_folder/$line");
        #    &logmsg("unknown line: $line");
        }
    }
    close PIPE;

    &logmsg("rsync stats for $backup_folder from $logfile:");
    &logmsg("\t  files synced: $files");
    &logmsg("\t   dirs synced: $dirs");
    &logmsg("\t     MB synced: ".int($size/1024/1024));
    &logmsg("\t deleted files: $deleted_files");
    &logmsg("\tunknown events: $unknown_lines");
    &logmsg("");
}






sub syscmd
{
    my $cmd = shift;
    &logmsg("\tSYSCMD: $cmd");
    system($cmd);
    return 0 if ($? & 127);
    return 0 if ($? & 128);
    return 0 if ($? >> 8);
    #return 0 if (system($cmd) >> 8);
    return 1;
}

sub check_lock {

    my $line;
    my $found = 0;
    my $processid;
    my $processgroup;
    my $lockfile = shift();

    # Make sure only one copy is running
    if (-e $lockfile) {
        &logmsg ("Found a Lockfile!");

        open (LCK, "<$lockfile") || &alert("Cannot open $lockfile: $!",1);
        while (my $line = <LCK>) {
            next if ($line =~ /^[;\#]/ );
            chomp($line);
            $processid = $line;
        }
        close (LCK);

        my $t = new Proc::ProcessTable;
        foreach ( @{$t->table} ){
            #$found = 1,last if ($processid == $_->pid);
            if ($processid == $_->pid) {
                $found = 1;
                $processgroup = $_->pgrp;
                last;
            }
        }

        if ( $found == 0) {
            &logmsg ("Process not running, deleting lockfile");
            unlink ($lockfile);
        } else {
            if ( (-M $lockfile) > ($max_exectime / (60*24)) ) {
                &alert("Process $processid too old, killing its processgroup $processgroup.");
                #unlink($lockfile) if (kill -9, $processid);
                if (kill -9 => $processgroup) {
                    unlink($lockfile)
                } else {
                    &logmsg("cannot kill processgroup $processgroup: $!");
                }
            } else {
                &logmsg ("Process running, exiting!");
                &end();
            }
        }
    }

    if (! -e $lockfile)
    {
        &logmsg("no process running, creating lockfile");
        open(FH,">$lockfile") || &alert("cannot open $lockfile: $!",1);
        print FH "$$\n";
        close FH;
    } else {
        &logmsg ("Process still running, exiting!");
        &end();
    }
}


sub alert {

    my ($message, $exit) = @_;

    &logmsg("ALERT: $message");

    &end($exit) if defined $exit and $exit ne "0";
}


sub end {
    my ($exit) = @_;
    exit $exit if defined $exit;
    exit 0;
}


sub logmsg {
    my ($msg) = @_;
    for (split(/\n/,$msg))
    {
        chomp;
        print "$_\n";
    }
}

sub now
{
    my @now = localtime;
    return sprintf("%d-%02d-%02d %02d:%02d:%02d",$now[5]+1900,$now[4]+1,$now[3],$now[2],$now[1],$now[0]);
}


