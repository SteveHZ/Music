#	makecue.pl
#	06/02/10, 28/03/10, 05/04/10, 16/04/12, 08/07/12
# 	19/01/15 - 08/02/15, 31/05/15, 04/12/15, 18-21/03/18
#	24/03/21

use strict;
use warnings;

use MyLib qw(prompt);
use File::Find;

my $cuefile = "makecue.cue";
my ($postgap, $pregap, $mp3) = (0,0,0);

for my $arg (@ARGV) {
	$postgap = 1 if $arg eq "-p";
	$pregap = 1 if $arg eq "-r";
	$mp3 = 1 if $arg eq "-m";
}

my $base_path = "C:/Mine/Music/";
my $dir = prompt ("Directory ($base_path) ",":");
my $path = $base_path.$dir;
chdir $path or die "\nUnable to find folder $path";

my @wavs = ();
find ( sub {
	if ($mp3) 	{ push @wavs, $_ if $_ =~ /\.mp3$/ }
	else 		{ push @wavs, $_ if $_ =~ /\.wav$/ }
}, $path );

my @sorted = sort @wavs;

# Write to disc

open my $fh, '>', $cuefile or die "\n\n Can't open new cue file !!!";
write_cue_file ($fh, \@sorted);
close $fh;

# Write to screen

open my $stdout,'>-'; # opens STDOUT
write_cue_file ($stdout, \@sorted);
close $stdout;
print "\n\nCue file completed.\n";

sub write_cue_file {
	my ($fh, $sortedref) = @_;
	my $files = scalar @$sortedref;
	my $filenum = 0;
	my $str;

	print $fh "REM Cue Sheet generated by makecue.pl";

	for my $filename (@$sortedref) {
		if ($mp3) {
			print $fh "\nFILE \"$filename\" MP3";
		} else {
			print $fh "\nFILE \"$filename\" WAVE";
		}
		$str = sprintf "  TRACK %02d AUDIO", ++$filenum;
		print $fh "\n$str";
		if ($pregap && ($filenum > 1)) {
			print $fh "\n  PREGAP 00:02:00";
		}
		print $fh "\n  INDEX 01 00:00:00";
		if ($postgap && ($filenum < $files)) {
			print $fh "\n  POSTGAP 00:02:00";
		}
	}
}

=pod

=head1 NAME

 makecue.pl [-p-r-m]

=head1 SYNOPSIS

 perl makecue.pl

=head1 DESCRIPTION

 Create cue files from a folder of WAV files
 From the command line, perl makecue.pl test
 where test is the folder in 'C:/Mine/Music/' containing the wav files
 or the folder in 'F:/Mine/Temp' containing the wav files

 If the folder name is more than one word, enter in quotes
 If WAV files are in a sub-folder, perl makecue.pl test/disc1

 Add -p to add postgap lines
 Add -r to add pregap lines
 Add -m for mp3 files
 ## Add -f to use external F drive

=head1 AUTHOR

 Steve Hope 2010 2015

=head1 LICENSE

 This library is free software. You can redistribute it and/or modify
 it under the same terms as Perl itself.

=cut
