#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my $ret;

sub save_df_status {
        my $pct_limit_warn  = "7";
        my $pct_limit_crit  = "5";
        my $mb_limit_warn  = "2500";
        my $mb_limit_crit = "2000";

	open(F, "df -Pl|");
	my (@return, $warn, $crit);
	while(<F>) {
		next if(/^Filesystem/);
		my ($dev, $size, $used, $avail, $capacity, $mountpoint) = split /\s+/;
		$capacity =~ s/\%//;
		$avail = int($avail / 1024);
		my $pcnt = 100-$capacity;
		if(($mountpoint =~ /data/) && not($mountpoint =~ /rrd/)){
			if( $avail < $mb_limit_crit ) {
				$crit = 1;
				push @return, qq|$mountpoint $avail MB ($pcnt\%);| ;
			} elsif ( $avail < $mb_limit_warn ) {
				$warn = 1;	
				push @return, qq|$mountpoint $avail MB ($pcnt\%);| ;
			}
		} else {
                        if ($pcnt < $pct_limit_crit) {
                                $crit = 1;
                                push @return, qq|$mountpoint $avail MB ($pcnt\%);| ;
                        } elsif ($pcnt < $pct_limit_warn) {
                                $warn = 1;
                                push @return, qq|$mountpoint $avail MB ($pcnt\%);| ;
                        }
		}
	}


        ## check free inodes
        $pct_limit_warn  = "10";
        $pct_limit_crit  = "5";

	open(F, "df -Pli|");
	while(<F>) {
		next if(/^Filesystem/);
		my ($dev, $size, $used, $avail, $capacity, $mountpoint) = split /\s+/;
		$capacity =~ s/\%//;
		my $pcnt = 100-$capacity;
                if ($pcnt < $pct_limit_crit) {
                        $crit = 1;
                        push @return, qq|$mountpoint $avail inodes ($pcnt\%);| ;
                } elsif ($pcnt < $pct_limit_warn) {
                        $warn = 1;
                        push @return, qq|$mountpoint $avail inodes ($pcnt\%);| ;
                }
	}

	if($warn || $crit) {
		if($crit) {
			print "DISK CRITICAL - free space/inodes: ";
			$ret = 2;
		} elsif ($warn) {
			print "DISK WARNING - free space/inodes: ";
			$ret = 1;
		}
		foreach my $val (@return) {
			print "$val";
		}
	} else {
		$ret = 0;
		print "DISK OK";
	}
	print "\n";
	close F;
}

&save_df_status();

exit $ret;
