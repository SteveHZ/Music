# 	my_dime.pl 26/11/22-10/12/22
# 	Script to parse my-dime.org into a csv file

use strict;
use warnings;
use MyLib qw(read_file);

my @levels = qw(A B C D);
my $level = 0;
my $prev_level = 0;

my $artist;
my $in_file = "C:/Mine/lisp/org/my-dime.org";
my $out_file = "C:/Mine/My Dime List.csv";

# Regexes
# maybe put these in a seperate module ?

# first org level
my $org1 = sub { qr /^\*/ }->();
# second org level
my $org2 = sub { qr/^\*\*/ }->();

# end maybe

# Nothing by this artist on laptop - go straight to level B
my $levelB_rx = sub {
	qr /^\+/x
}->();

my $mp3_folder_rx = sub {
	qr /^MP3/x
}->();

# end Regexes

my $lines = read_file ($in_file);

open my $fh_out, '>', $out_file or die "Can't open $out_file"; 
print $fh_out "DRIVE,BAND,TITLE,NOTES\n";

for my $line (@$lines) {
	$line =~ s/,//g;
	$line =~ s/ #/,/g; # To add additional notes eg #Millard

	if ($line =~ $org2) { # Artist
		$artist = substr $line, 3;
		chomp $artist;
		$level = 0;
	} elsif ($line eq "\n") {
		if ($level  == 3) { # Some MP3s may be on laptop so need to cope with this
			$level = $prev_level + 1;
		} else {
			$level ++;
		}
	} elsif ($line =~ $org1) { # Headers
		next;
	} else {
		if ($line =~ $levelB_rx) { # Nothing by this artist on laptop - go stright to level B
			$line =~ s/\+ //;
			$level = 1;
		} elsif ($line =~ $mp3_folder_rx) {
			$prev_level = $level; # Ensure we know where we are if MP3 are on laptop
			$level = 3;
			$line =~ s/MP3\//MP3 - /;
		}
		print "$levels[$level],$artist,$line";
		print $fh_out "$levels[$level],$artist,$line";
	}
}
close $fh_out;
print 'Done';
