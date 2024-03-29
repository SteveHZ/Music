# hyp.pl 17/11/21, 30/11/21, 5/12/21

# Read Hypnagogue podcast playlist from hypnagogue.com to turn it
# into a cue file which can be read in foobar and poweramp

use strict;
use warnings;
use MyLib qw(read_file prompt);

my $path = "C:/Mine/Music/Podcasts/Hypnagogue";
chdir $path or die "\nUnable to find folder $path";

my $episode = $ARGV[0] // prompt ("Episode number ",":");
die "Can't find Hypnagogue $episode text file !!"
	unless -e "$path/Hypnagogue $episode.txt";

my $filename = "hyp$episode.mp3";
my $cuefile = "$path/Hypnagogue $episode.cue";

my $lines = read_file "$path/Hypnagogue $episode.txt";
my @tracks = ();

for my $line (@$lines) {
	my ($time, $info) = split ' ', $line, 2; # split only once (produce two fields)
	chomp $info;

	push @tracks, {
		time => to_mins_secs ($time),
		info => $info,
	};
}

open my $fh, '>', $cuefile or die "\n\n Can't open new cue file !!!";
write_cue_file ($fh, $filename, $episode, \@tracks);
close $fh;

# Write to screen

open my $outh,'>-'; # opens STDOUT
write_cue_file ($outh, $filename, $episode, \@tracks);
close $outh;
print "\n\nCue file completed.\n";

# amend time to correct format
# INDEX 01 00:30:00 is mins/secs/frames
sub to_mins_secs {
    my $time = shift;
	if ($time =~ /(\d\d?)\.(\d\d?)\.(\d\d)$/) {
		my $mins = ($1 * 60) + $2;
		return "$mins:$3:00";
	} elsif ($time =~ /(\d\d?)\.(\d\d)$/) {
		return "$1:$2:00";
	} else {
		die "\nError computing time for $time";
	}
}

sub write_cue_file {
	my ($fh, $filename, $episode, $tracks) = @_;
	my $filenum = 0;

	print $fh "REM GENRE Podcasts; Synth; Sequencer";
	print $fh "\nPERFORMER \"Hypnagogue\"";
	print $fh "\nTITLE \"$episode\"";
	print $fh "\nFILE \"$filename\" MP3";

	for my $track (@$tracks) {
		printf $fh "\n  TRACK %02d AUDIO", ++$filenum;
		print  $fh "\n    TITLE \"$track->{info}\"";
		print  $fh "\n    INDEX 01 $track->{time}";
	}
}

=pod

=head1 NAME

 hyp.pl

=head1 SYNOPSIS

 perl hyp.pl [episode number]
 OR
 perl hyp.pl
 Episode number : [episode number]
 
=head1 DESCRIPTION

 Create a cue file from a text file copied from Hypnagogue webpage
 
=head1 AUTHOR

 Steve Hope 2021

=head1 LICENSE

 This library is free software. You can redistribute it and/or modify
 it under the same terms as Perl itself.

=cut
