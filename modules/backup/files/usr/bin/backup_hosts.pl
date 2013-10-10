#!/usr/bin/perl -w

use strict;
use MIME::Lite;
use File::Basename;
use Sys::Hostname;
use Proc::ProcessTable;
use Parallel::ForkManager;
use Config::IniFiles;
use Data::Dumper;
use Getopt::Long;
use Date::Manip;

&Date_Init ("Language=English", "DateFormat=non-US");



my $progname    = File::Basename::basename($0);
my $basename    = File::Basename::dirname($0);
my $program     = $basename."/".$progname;
my $hostname    = hostname();
my $proginfo  = "$program at $hostname";
my $configfile      = "";
my $alertlevel = 3;

&logmsg("$progname starting");

&GetOptions ( 	"cfg=s"  => \$configfile);

&alert("no valid global config defined",$alertlevel,1) if (! length $configfile or ! -f $configfile or ! -r $configfile);


my ($config) = &read_config();
my %config = %$config;

&check_lock($config{"GLOBAL"}{"lock_file"});


# creating snapshots
my $current_snapshot = &now();
$current_snapshot =~ s/\s+/_/;
$current_snapshot =~ s/:+//g;
my @backup_dirs = ();
for my $value(values %config) {
    next if (!defined $$value{"backup_dir"});
    next if (grep(/$$value{"backup_dir"}/,@backup_dirs));
    push @backup_dirs,$$value{"backup_dir"};
    &rotate_backups($$value{"backup_dir"},$current_snapshot);
}

my $pm = new Parallel::ForkManager($config{"GLOBAL"}{"max_processes"});
for my $key(sort keys %config)
{
    next if ($key eq "GLOBAL");
    $pm->start() and next;

    my %hash = %{$config{$key}};

    my $tmpdir = $hash{"backup_dir"}."/".$current_snapshot."/".$hash{servername}.$hash{dest_dir};
    unless (-d $tmpdir) {
        &syscmd("mkdir -p $tmpdir") or &alert("cannot create directory '$tmpdir': $!",2,1);
    }
    undef $tmpdir;
    
    my $excludes = "";
    for (@{$hash{exclude}}) {
        $excludes .= " --exclude '$_'";
    }
    my $relative = "";
    $relative = "-R" if $hash{"relative"} eq "yes";
#  WAS IST DAS?
#    my $cmd = "rsync $relative ".$hash{rsync_options}." $excludes ".$hash{src_dir}." ".$hash{"backup_dir"}."/".$current_snapshot."/".$hash{servername}.$hash{dest_dir}." >>".$config{"GLOBAL"}{"log_dir"}."/$key.log 2>&1";
   my $cmd = "rsync $relative ".$hash{rsync_options}." $excludes ".$hash{remote_user}."@".$hash{servername}.":".$hash{src_dir}." ".$hash{"backup_dir"}."/".$current_snapshot."/".$hash{servername}.$hash{dest_dir}." >>".$config{"GLOBAL"}{"log_dir"}."/$key.log 2>&1";
#
    if (&syscmd($cmd)) {
        &logmsg("$cmd finished");
    } else {
        &alert("error in execution of '$cmd': $!",2,0);
    }

    ##############################################################
    ###### saving directory structure of excluded areas ##########
    if ($hash{save_excludes_dir_structure} eq "yes") {
        unlink("$hash{backup_dir}/$key.tmp") if (-f "$hash{backup_dir}/$key.tmp");
        for my $exclude (@{$hash{exclude}}) {
            if ($hash{src_dir} eq "/" and $exclude =~ /^(\/proc|\/sys)(\/.+|\/)?$/) {
                &logmsg("will not save directory structure of $hash{servername}:$exclude");
                next;
            }

            my @tmpprunefs = ();
            for my $fs (@{$config{"GLOBAL"}{"excludes_allowed_fs_types"}}) {
                push @tmpprunefs, "! -fstype $fs";
	    }
	    my $prunefs = "";
	    $prunefs = join(" -a ", @tmpprunefs) . " -o " if scalar @tmpprunefs;

            $exclude =~ s/^\/+//;
            $exclude =~ s/\/+$//;
            my $tmpsrc_dir = "/";
	    if ($hash{"relative"} eq "no") {
                $tmpsrc_dir = $hash{src_dir};
	    }
            &logmsg("saving directory structure of $hash{servername}:$tmpsrc_dir/$exclude");
            $cmd = "ssh ".$hash{remote_user}.'@'.$hash{servername}." 'cd $tmpsrc_dir && find $exclude $prunefs \\\( -type d -o -type l -a -exec test -d {} \\\; \\\) -a -print | sort' >> $hash{backup_dir}/$key.tmp";
            &syscmd($cmd) || &alert("error in execution of '$cmd': $!",2,1);
        }

        if (-f "$hash{backup_dir}/$key.tmp") {
            my $tmpsrc_dir = "/";
	    if ($hash{"relative"} eq "no") {
                $tmpsrc_dir = $hash{src_dir};
	    }
            $cmd = "rsync -av --delete --files-from='$hash{backup_dir}/$key.tmp' -e ssh ".$hash{remote_user}.'@'.$hash{servername}.":$tmpsrc_dir ".$hash{"backup_dir"}."/".$current_snapshot."/".$hash{servername}.$hash{dest_dir}." >>".$config{"GLOBAL"}{"log_dir"}."/$key.log 2>&1";
            &syscmd($cmd) || &alert("error in execution of '$cmd': $!",2,1);
            unlink("$hash{backup_dir}/$key.tmp") if (-f "$hash{backup_dir}/$key.tmp");
	}
    }


    
    $pm->finish();
}
$pm->wait_all_children();

#&disk_usage(\@backup_dirs,$current_snapshot);
#&disk_free(@backup_dirs);

unlink($config{"GLOBAL"}{"lock_file"});

&end();



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

        open (LCK, "<$lockfile") || &alert("Cannot open $lockfile: $!",$alertlevel,1);
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
            if ( (-M $lockfile) > ($config{"GLOBAL"}{"max_exectime"} / (60*24)) ) {
                &alert("Process $processid too old, killing its processgroup $processgroup.",2);
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
        open(FH,">$lockfile") || &alert("cannot open $lockfile: $!",$alertlevel,1);
	print FH "$$\n";
	close FH;
    } else {
        &logmsg ("Process still running, exiting!");
        &end();
    }
}


sub alert {

    my ($message, $local_alertlevel, $exit) = @_;
    $local_alertlevel = $alertlevel unless defined $local_alertlevel;

    &logmsg("ALERT($local_alertlevel): $message");

    if ($local_alertlevel == 2) {
        my $msg = new MIME::Lite (
            From    =>  'root@neutral-zone.de',
            To      =>  'root@neutral-zone.de',
            Subject =>  "$proginfo ($$)",
            Type    =>  'TEXT',
            Data    =>  $message);

        $msg -> send();
    } elsif ($local_alertlevel == 3) {
        my $msg = new MIME::Lite (
            From    =>  'root@neutral-zone.de',
            To      =>  'root@neutral-zone.de',
            Subject =>  "$proginfo ($$): $message",
            Type    =>  'TEXT',
            Data    =>  '');

        $msg -> send();
    }

    &end($exit) if defined $exit and $exit ne "0";
}


sub end {
    my ($exit) = @_;
    &logmsg("$progname finished");
    exit $exit if defined $exit;
    exit 0;
}


sub logmsg {
    my ($msg) = @_;
    my $time = &now();
    for (split(/\n/,$msg))
    {
        chomp;
        print $time."\t".$$."\t$_\n";
    }
}

sub now
{
    my @now = localtime;
    return sprintf("%d-%02d-%02d %02d:%02d:%02d",$now[5]+1900,$now[4]+1,$now[3],$now[2],$now[1],$now[0]);
}

sub rotate_backups
{
    ###########################################################################
    ### base settings #########################################################
    my $bdir = shift;
    my $current = shift;

    ###########################################################################
    ### check 4 free space ####################################################
    my $CHECK_HDMINFREE=1;
    my $HDMINFREE=98;
    my $GETPERCENTAGE='s/.* \([0-9]\{1,3\}\)%.*/\1/';
    if ($CHECK_HDMINFREE) {
        chomp (my $KBISFREE=`df $bdir | tail -n1 | sed -e "$GETPERCENTAGE"`);
        if ( $KBISFREE > $HDMINFREE ) {
            &alert("Not enough space left for rotating backups!\n\nKBytes used:\t$KBISFREE\%",$alertlevel,1);
        }
	&logmsg("Space used on $bdir: $KBISFREE\%");
    }

    ###########################################################################
    ### remove to old snapshots ###############################################
    &logmsg("Rotating snapshots ...");
    opendir (DIR, "$bdir") or &alert("cannot open directory $bdir: $!",$alertlevel,1);
    my @dirs = sort grep (/^\d\d\d\d-\d\d-\d\d_\d\d\d\d\d\d$/,readdir(DIR));
    closedir DIR;
    
    while (scalar @dirs >= $config{"GLOBAL"}{"snapshots"}) {
        my $dir = shift(@dirs);
        &syscmd ("rm -rf $bdir/$dir") or &alert("cannot remove directory $bdir/$dir: $!",$alertlevel,1);
    }

    ###########################################################################
    ### remove temporary snapshot directory ###################################
    if (-d "$bdir/.backup-snapshot" ) {
        &syscmd("rm -rf $bdir/.backup-snapshot") or &alert("cannot remove directory $bdir/.backup-snapshot: $!",$alertlevel,1);
    }
    
    ###########################################################################
    ### create the directory for the backup if necessary ######################
    if (! -d "$bdir/.backup-snapshot" ) {
        &syscmd("mkdir -p $bdir/.backup-snapshot") or &alert("cannot create directory $bdir/.backup-snapshot: $!",$alertlevel,1);
    }
    
    ###########################################################################
    ### create hard link copy of last backup ##################################
    if (scalar @dirs) {
        my $dir = pop(@dirs);
	opendir (DIR, "$bdir/$dir") or &alert("cannot open directory $bdir/$dir: $!",$alertlevel,1);
	my @list = readdir DIR;
	for my $entry (sort @list) {
            next if $entry eq ".";
            next if $entry eq "..";

            &syscmd("cp -al $bdir/$dir/$entry $bdir/.backup-snapshot/") or &alert("cannot create snapshot for $entry in $bdir/.backup-snapshot/: $!",$alertlevel,1);
	}
	closedir DIR;
    }


    ###########################################################################
    ### remove the future snapshot directory if exists ########################
    if (-d "$bdir/$current" ) {
        &logmsg("directory $bdir/$current allready exists (removing it): $!");
        &syscmd("rm -rf $bdir/$current") or &alert("cannot remove directory $bdir/$current: $!",$alertlevel,1);
    }

    ###########################################################################
    ### rename the temporary snapshot directory ###############################
    &syscmd("mv $bdir/.backup-snapshot $bdir/$current") or &alert("cannot mv $bdir/.backup-snapshot $bdir/$current: $!",$alertlevel,1);

    

    return $current;
}

sub read_config {
    ##############################################################################
    ### at first we evaluate the main config file ################################
    &logmsg("Reading configuration $configfile");
    my $ini = Config::IniFiles->new( -file => $configfile);
    &alert("cannot evaluate config file",$alertlevel,1) unless defined $ini;
    my @sections=$ini->Sections;

    my %config = ();
    for my $section (@sections) {
        if ($section eq "GLOBAL") {

	    for my $param ("log_dir","lock_file","max_processes","max_exectime","snapshots","src_dir","dest_dir","rsync_options","remote_user","exclude","relative","backup_dir") {
	        $config{"GLOBAL"}{$param} = $ini->val($section,$param);
	        &alert("global parameter $param is missing or not well formed, please check config",$alertlevel,1) if (!defined $config{"GLOBAL"}{$param} or !length $config{"GLOBAL"}{$param});
	    }
	    last;
	}
    }
    $config{"GLOBAL"}{"log_dir"} =~ s/\/+$//;
    $config{"GLOBAL"}{"backup_dir"} =~ s/\/+$// if defined $config{"GLOBAL"}{"backup_dir"};

    $config{"GLOBAL"}{"dest_dir"} = "/".$config{"GLOBAL"}{"dest_dir"};
    $config{"GLOBAL"}{"dest_dir"} =~ s/^\/+/\//;

    &alert("global parameter relative must be 'yes' or 'no'",$alertlevel,1) if $config{"GLOBAL"}{"relative"} !~ /^(yes|no)$/i;

    $config{"GLOBAL"}{"weekdays"} = "SMTWTFS"; ### default is to run on (S)unday, (M)onday, (T)uesday, ..., (S)aturday
    $config{"GLOBAL"}{"weekdays"} = $ini->val("GLOBAL","weekdays") if ( defined($ini->val("GLOBAL","weekdays")) );
    &alert("global parameter weekdays is not wellformed",$alertlevel,1) if ($config{"GLOBAL"}{"weekdays"} !~ /^SMTWTFS$/i);
    
    my @tmplist = ();
    @tmplist = split(/\n/, $ini->val("GLOBAL","excludes_allowed_fs_types") ) if (defined $ini->val("GLOBAL","excludes_allowed_fs_types") and length $ini->val("GLOBAL","excludes_allowed_fs_types"));
    $config{"GLOBAL"}{"excludes_allowed_fs_types"} = [ @tmplist ];
    undef @tmplist;
    ##############################################################################

    ##############################################################################
    ### now we evaluate the server config settings ###############################
    my @servers = ();
    my @global_excludes = split(/\n/,$config{"GLOBAL"}{"exclude"});
    for my $section (@sections){
        next if ($section eq "GLOBAL");

        # checking if section is disabled
	if ($section =~ /^!/) {
	    &logmsg("Backup $section is marked as disabled");
	    $section =~ s/^!//;
            my $msg = new MIME::Lite (
                From    =>  'root@neutral-zone.de',
                To      =>  'root@neutral-zone.de',
                Subject	=>  "$hostname: Backup $section is marked as disabled",
                Type    =>  'TEXT',
                Data    =>  "Backup $section will not be created.");

            $msg -> send();
            
            next;
	}
	
        # checking the server_name parameter
	my $tmpservername = $ini->val($section,"servername");
	$tmpservername = $config{"GLOBAL"}{"servername"} if (!defined $tmpservername or !length $tmpservername);

        # checking the backup_dir parameter
	my $tmpbackupdir = $ini->val($section,"backup_dir");
        $tmpbackupdir = $config{"GLOBAL"}{"backup_dir"} if (!defined $tmpbackupdir or !length $tmpbackupdir);
        $tmpbackupdir =~ s/\/+$// if defined $tmpbackupdir;
	&alert("no backup_dir defined for $section",$alertlevel,1) if (!defined $tmpbackupdir or !length $tmpbackupdir);

        # checking the src_dir parameter
	my $tmpsrcdir = $ini->val($section,"src_dir");
	$tmpsrcdir = $config{"GLOBAL"}{"src_dir"} if (!defined $tmpsrcdir or !length $tmpsrcdir);
	$tmpsrcdir = &parse_dir($tmpsrcdir);

        # checking the dest_dir parameter
	my $tmpdestdir = $ini->val($section,"dest_dir");
	$tmpdestdir = $config{"GLOBAL"}{"dest_dir"} if (!defined $tmpdestdir or !length $tmpdestdir);
	$tmpdestdir = "/".$tmpdestdir;
	$tmpdestdir =~ s/^\/+/\//;
	$tmpdestdir = &parse_dir($tmpdestdir);

        # checking the value for relative parameter
	my $tmprelative = $ini->val($section,"relative");
	$tmprelative = lc($tmprelative) if defined $tmprelative;
	$tmprelative = lc($config{"GLOBAL"}{"relative"}) if (!defined $tmprelative or !length $tmprelative);
	&alert("parameter relative must be 'yes' or 'no' for $section",$alertlevel,1) if $tmprelative !~ /^(yes|no)$/;

	# check if the server excludes should replace the default excludes or added to
	my $overwriteexcludes = $ini->val($section,"overwrite_default_excludes");
        $overwriteexcludes = $config{"GLOBAL"}{"overwrite_default_excludes"} if (!defined $overwriteexcludes or !length $overwriteexcludes);
	$overwriteexcludes = "no" if (!defined $overwriteexcludes or !length $overwriteexcludes);

	# check if there are any additional excludes for that server
        my @tmpexcludes = @global_excludes;
        my $tmpexcludes = $ini->val($section,"exclude");
	if ($overwriteexcludes eq "no") {
	    push @tmpexcludes, split(/\n/,$tmpexcludes) if (defined $tmpexcludes and length $tmpexcludes);
	} elsif ($overwriteexcludes eq "yes") {
	    @tmpexcludes = ();
	    @tmpexcludes = split(/\n/,$tmpexcludes) if (defined $tmpexcludes and length $tmpexcludes);
	} else {
	    &alert("overwrite_default_excludes must be one of 'yes' or 'no'",$alertlevel,1);
	}

        for my $exclude(@tmpexcludes) {
            $exclude = &parse_dir($exclude);
	}

	# check if directory structure inside of excluded areas should be saved
	my $save_dirstruct = $ini->val($section,"save_excludes_dir_structure");
        $save_dirstruct = lc($save_dirstruct) if defined $save_dirstruct;
	&alert("save_excludes_dir_structure must be one of 'yes' or 'no'",$alertlevel,1) if (defined $save_dirstruct and length($save_dirstruct) and $save_dirstruct !~ /^(yes|no)$/);
	$save_dirstruct = "no" if (!defined $save_dirstruct or $save_dirstruct ne "yes" );

	# check if the default remote user should not be used
	my $tmpremoteuser = $ini->val($section,"remote_user");
	$tmpremoteuser = $config{"GLOBAL"}{"remote_user"} if (!defined $tmpremoteuser or !length $tmpremoteuser);

	# check if the default rsync options should not be used
	my $tmprsyncoptions = $ini->val($section,"rsync_options");
	$tmprsyncoptions = $config{"GLOBAL"}{"rsync_options"} if (!defined $tmprsyncoptions or !length $tmprsyncoptions);
	
	# check if there is a definition for weekdays option
	my $tmpweekdaysoptions = $ini->val($section,"weekdays");
	$tmpweekdaysoptions = $config{"GLOBAL"}{"weekdays"} if (!defined $tmpweekdaysoptions);
        &alert("parameter weekdays is not wellformed for $section",$alertlevel,1) if ($tmpweekdaysoptions !~ /^SMTWTFS$/i);
	my $weekday = (localtime())[6];
	if (substr($tmpweekdaysoptions,$weekday,1) ne substr("SMTWTFS",$weekday,1)) {
	    &logmsg("backup for host $section is disabled for today");
	    next;
	}
	
	my %hash = (	servername => $tmpservername,
			backup_dir => $tmpbackupdir,
			dest_dir => $tmpdestdir,
			src_dir => $tmpsrcdir,
			exclude => \@tmpexcludes,
			save_excludes_dir_structure => $save_dirstruct,
			remote_user => $tmpremoteuser,
			rsync_options => $tmprsyncoptions,
			weekdays => $tmpweekdaysoptions,
			relative => $tmprelative);
#	print "CONFIG------------------------\n".Dumper(%hash)."\nCONFIG------------------------------\n";
	$config{$section} = \%hash;
    }
    ##############################################################################

#	print "CONFIG------------------------\n".Dumper(%config)."\nCONFIG------------------------------\n";
    return (\%config);
}

sub disk_usage {
    my ($dirs,$snapshot) = @_;
    my @dirs = @$dirs;
    
    &logmsg("generating disk usage report");
    my $text = "";
    for my $dir(@dirs) {
        $text .= "$dir/$snapshot/:\n\n";
        my $cmd = "du -sm $dir/$snapshot/*|sort -nk 1|";
        open (PIPE,$cmd) || &alert("cannot open pipe '$cmd': $!",$alertlevel,1);
        while (my $line = <PIPE>) {
            chomp($line);
            $text .= "$line\n";
	}
        close PIPE;

	$text .= "\n\n";
    }

    my $msg = new MIME::Lite (
        From    =>  'root@neutral-zone.de',
        To      =>  'root@neutral-zone.de',
        Subject	=>  "$hostname BACKUP SIZE in MByte(".&now().")",
        Type    =>  'TEXT',
        Data    =>  $text);

    $msg -> send();
}

sub disk_free {
    my @dirs = @_;
    
    my $cmd = "df -m ".join(" ",@dirs)."|";
    &logmsg("generating disk free report");
    open (PIPE,$cmd) || &alert("cannot open pipe '$cmd': $!",$alertlevel,1);
    my $line = <PIPE>;
    chomp($line);
    my $text = "$line\n";
    while ($line = <PIPE>) {
        chomp($line);
	if ($line =~ /\s+(\S+)\s*$/) {
            my $d = $1;
	    #if ("$dir/" =~ /^$d\//) {
	    if (grep (/^$d$/,@dirs)) {
                $text .= "$line\n";
	    }
	}
    }
    close PIPE;

    my $msg = new MIME::Lite (
        From    =>  'root@neutral-zone.de',
        To      =>  'root@neutral-zone.de',
        Subject	=>  "$hostname DISK USAGE in MByte(".&now().")",
        Type    =>  'TEXT',
        Data    =>  $text);

    $msg -> send();
}

sub parse_dir {
    my $dir = shift();


    while ( $dir =~ /##DATE:'(.+)'##/ ) {
        my ($date,$format,$calc) = split(/','/,$1,3);
	my $dtg = "";
	if ( defined ($calc) && length ($calc) ) {
	    $dtg = &UnixDate( &DateCalc($date,$calc) , $format );
	} else {
	    $dtg = &UnixDate( $date , $format );
	}
	&alert("error while parsing DATE tag in config",$alertlevel,1) if (!defined($dtg) or !length($dtg));

	$dir =~ s/##DATE:'.+'##/$dtg/;
    }

    return $dir;
}




## begin pod
#
=head1 NAME 

backup_hosts.pl - create backups of different hosts using rsync and keep snapshots of earlier runs

=head1 SYNOPSIS 

backup_hosts.pl --cfg <configfile>

=head1 DESCRIPTION

This program takes backups of different hosts using rsync. All definitions are stored in a configfile,
which allows you to configure source directories, multiple explude pathes, different destination pathes
to write backups into an existing data structure and many other. See section B<CONFIGURATION> for more
information.

The program creates a copy of hardlinks of an existing backup - in case there is one - and uses rsync
to write only the changes on the host into this copy. Files not existing anymore are removed,
new ones are created and existing unchanged files keep untouched. So only the changed data are transfered
to reduce system and network load, as well as the time until completition. By creating hardlinks of all
files when taking the copy from the last backup, the disc usage on the backup device will increase straight
forward to size of changed files. The structure of the target backup area is equal to the structure of the
source host system. So access and recover of a single file is quite easy.

When all backups are finished the program creates a disc usage and disk free report of the backup storages.

=head1 PARAMETERS

=over 12

=item --cfg    Takes a filename as mandatory argument where all details of backup are defined.

=back

=head1 CONFIGURATION

First thing to say is that the config file is writen in Config::IniFiles syntax. There is a global section
named [GLOBAL] and a section for every backup source you want to add to your config. The section names for
the backups can be chosen as you want but they have to fit the requirements of Config::IniFiles and need to
be unique.

There are different types of config options.

=over 12

=item B<G>       This option is mandatory and valid only in global context.

=item B<g>       This option is not mandatory but valid only in global context.

=item B<B>       This option must be defined in at least one of global or per target context.

=item B<b>       This option can be defined in global and/or per target context, but can also be undefined.

=item B<T>       This option is mandatory per target context.

=item B<t>       This option can be defined in per target context, but can also be undefined.

=back

Normally settings defined for a target overrides the settings defined in global context. This is not
generally true for the 'exclude' option. See 'exclude' and 'overwrite_default_excludes' options for details.


=over 12

=item B<log_dir (G)>

The directory to write log informations to.

=item B<lock_file (G)>

The lockfile.

=item B<max_processes (G)>

How many child processes can the script create for doing the different backups.

=item B<max_exectime (G)>

Time in minutes how long the program is allowed to run. On startup this script checks if a backup job
runs too long and kills it if true.

=item B<snapshots (G)>

This defines how many older backups are kept. Snapshot rotation is done by creating a hardlink copy of the
last/newest snapshot. A snapshot is a directory inside 'backup_dir' in 'YYYY-mm-dd_HHMMSS' format
(e.g. '/backup/2005-07-24_163002/').

=item B<excludes_allowed_fs_types (g)>

For saving the directory structure of an excluded area (see option B<save_excludes_dir_structure>) a L<find(1)>
is performed on the source host inside each exclude area. excludes_allowed_fs_types defines a list of allowed
filesystem types for this L<find(1)> command. As soon as a filesystem type not listed here is detected L<find(1)>
will not descend deeper into that directory.

This option is useful to allow B<save_excludes_dir_structure> but prevent L<find(1)> of searching e.g. mounted NFS or AFS
areas.

=item B<backup_dir (B)>

This is the root directory where the backup is located.

=item B<src_dir (B)>

This is the backup source directory of the remote backup source host.

=item B<dest_dir (B)>

Defines the destination subirectory inside of 'backup_dir/SNAPSHOT/servername/'. Should be absolute
and default for most cases should be /. dest_dir will be created if needed.

=item B<remote_user (B)>

The remote user on the source host.

=item B<rsync_options (B)>

Here you have to set all rsync options to use for all targets or the current target.

=item B<relative (B)>

Here you define whether you want rsync to use the -R (relative) option when taking backups. This is useful when you
have a B<src_dir> with wildcards. The reason why you should not add -R to B<rsync_options> parameter is, that this program
has to handle some things in other way when taking backups in that way. Allowed values are 'yes' or 'no'.

Setting this option to 'yes' changes the interpretation of some options in the same way L<rsync(1)> does. These
are B<dest_dir> and B<exclude>. Note also that unlike L<rsync(1)> this program cannot handle wildcards in B<dest_dir>
correctly. So using B<relative> can help you to work around this problem.

        src_dir  = /usr/
        dest_dir = /usr/
        exclude  = /usr/share/

When B<relative> is set to 'no' then this config would sync all data below /usr/ into /usr/ on the backup host and
everything below /usr/share/ would be excluded.

Setting B<relative> to 'yes' then the data structure of B<dest_dir> would look like this:

        /usr/usr/....

So the complete B<src_dir> tree would be copied into B<dest_dir> and since /usr/share doesn't exist below /usr/, the exlude
wouldn't match and the content of share/ would be synced too.

The correct config when setting B<relative> to 'yes' would be:

        src_dir  = /usr/
        dest_dir = /
        exclude  = /usr/share/

=item B<exclude (b)>

This option defines a directory or file on source host to exclude from backup.
Can be defined zero or more time. This option takes the same values as the rsync --exclude option.

=item B<weekdays (b)>

Here you set on which days of the week a backup should run. The syntax must match the
following regexp: /^SMTWTFS$/i . E.g: SMtwTFs or SMTWtfs or ... Default setting is SMTWTFS.
Each of these characters stands for a weekday from sunday to saturday. Upper case letter
indicate that the backup for this weekday is enabled. Lower case indicate a disabled state.

=item B<servername (T)>

The source hostname to backup from.

=item B<overwrite_default_excludes (b)>

Override the 'exclude' options defined in global context for this target.

=item B<save_excludes_dir_structure (t)>

This option defaults to 'no'. Enable it by setting it to 'yes' if you want to save the directory structure inside
of the defined exclude areas. This is useful e.g. when you have areas with daily changing files but the directory
structure keeps as it is. Without that you would probably miss these directories after a crash and a subsequent
recovery from your backups.

In detail this option will not only save the directory tree inside your excludes but also the symbolic links
pointing to existing directories.

Note that B<save_excludes_dir_structure> affects all defined excludes for a target, but /proc and /sys. 

=back

=head1 CONFIGURATION (Date evaluation)

For src_dir, dest_dir and exclude it is possible to define a date field which is evaluated while parsing the
string values. The syntax for that special field is

        ##DATE:'<date>','<format>','<time_offset>'##

where the <date> and <format> are mandatory. These fields also have to be enclosed by single quotes <'>.
For evaluation L<Date::Manip(3pm)> in english language is used,
so <date>, <format> and <time_offset> can have any values valid for the L<Date::Manip/DateCalc> and
L<Date::Manip/Unixdate> methods. See L</CONFIGURATION EXAMPLES> for details on configuration.

=head1 CONFIGURATION EXAMPLES

Here you can see some examples for your configuration.

At first the mandatory [GLOBAL] section.

        [GLOBAL]
        log_dir = /var/log/backup/
        lock_file = /var/lock/backup_hosts.lock
        backup_dir = /backup_hosts/
        max_processes = 1
        max_exectime = 1200
        snapshots = 9
        src_dir = /
        dest_dir = /
        rsync_options = -av --delete --numeric-ids -e "ssh -oStrictHostKeyChecking=no -oBatchMode=yes -2 -i /root/.ssh/id_dsa"
        remote_user = root
        relative = no
        exclude = <<EOT
        /proc/*
	/sys/*
        EOT
        excludes_allowed_fs_types = <<EOT
        ext2
        ext3
        reiserfs
        xfs
        jfs
        vfat
        ntfs
        EOT

The first host to backup. All default values are used as defined in global context. Only a few more excludes are added.

        [host1]
        servername = host1.domain.tld
        exclude = /data/*
        exclude = /media/*

Same here but only the default excludes.

        [host2]
        servername = host2.domain.tld

The following two section are useful when doing backups off large data areas. Since rsync creates a file list before starting
the sync, the deeper and wider the treei, the larger the list will grow and the longer the backup will take to start. So
dividing the data area into many smaller ones, will save resources of the source host and will speed up the backup itself.

The backup itself is stored in a differend location (probaly a different storage) as in global section defined. Second thing to
mention is that not the complete host will be backuped but only a subtree. The default excludes are ignored and another is defined.

        [host3_data01]
        servername = host3.domain.tld
        backup_dir = /backup_data/
        src_dir = /var/lib/data01/
        dest_dir = /
        overwrite_default_excludes = yes
        exclude = /var/lib/data01/archiv/*

This backup is taken from the same host and will destinate in a subdirectory of the backup destination defined above. Only files
excluded before will be backuped. No excludes will be used. One thing to notice is that the backup is defined to run only on monday,
thursday and friday.

Another thing to notice the usage of the special date parameter for src_dir and dest_dir option. The directory structure below 
...../archiv/ includes a lot of directories while these are organized in a year/month structure. The backup is taken only for
the current and the last month. This config assumes that the files in the older directories will not change, otherwise it
wouldn't make much sence. Since wildcards are used to represent the directories below .../archiv/ we need to enable
the B<relative> option. Note also that B<dest_dir> is set to "/" since it is taken from GLOBAL section.

        [host3_data02]
        servername = host3.domain.tld
        backup_dir = /backup_data/
        src_dir = /var/lib/data01/archiv/*/##DATE:'today','%Y/%m'##/
        weekdays = sMtwTFs
	relative = yes
        overwrite_default_excludes = yes

        [host3_data03]
        servername = host3.domain.tld
        backup_dir = /backup_data/
        src_dir = /var/lib/data01/archiv/*/##DATE:'today','%Y/%m','1 month ago'##/
        weekdays = sMtwTFs
	relative = yes
        overwrite_default_excludes = yes


The next example describes a quite normal setup with a lot of defaults and an additional exclude
for /data/*. B<save_excludes_dir_structure> is enabled, so the directory tree inside of /data/
will be backuped too. Note that this is also true for all other excludes for this target but
/proc and /sys.

Take also a look at B<excludes_allowed_fs_types> in the GLOBAL section example.

        [host4]
        servername = host4.domain.tld
        exclude = /data/*
        save_excludes_dir_structure = yes


=head1 AUTHOR

Thomas Boehme - L<t.boehme@mc-wetter.de>

=head1 SEE ALSO

L<rsync(1)>

L<find(1)>

L<Config::IniFiles(3pm)>

L<Date::Manip(3pm)>

=cut
