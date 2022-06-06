
#	audio_join.pl 15-22/03/18
#	https://trac.ffmpeg.org/wiki/Concatenate

# To dither from 24 to 16 bit
# cd C:\Mine\Music\Dime\Haken\Haken - 2022-05-04 - Pool Stage Cruise to the Edge
# > ffmpeg -i "01 Introduction.flac" -sample_fmt s16 -ar 44100 "01 Intro-16bit.flac"

use strict;
use warnings;

use MyLib qw(prompt);
use File::Find;

die "Usage : perl audio_join.pl input_folder output_folder/file.wav"
	if @ARGV != 2;

my $in_path = $ARGV[0];
my $out_file = $ARGV[1];

my $out_path = get_parent_dir ($out_file);
mkdir $out_path unless -e $out_path;

my $files_list = "$in_path/files_list.txt";
build_file_list ($in_path, $files_list);

system "ffmpeg -f concat -safe 0 -i $files_list -c copy $out_file";
unlink $files_list;

sub build_file_list {
	my ($in_path, $files_list) = @_;
	chdir $in_path or die "\nUnable to find folder $in_path";

	my @flacs = ();
	find ( sub {
	    push @flacs, $_ if $_ =~ /\.flac$/
	}, $in_path );
	die "\nNo files found" unless @flacs > 0;

	my @sorted = sort @flacs;
	print "\nFiles found at $in_path :\n";
	print "\n  $_" for @sorted;

	exit (0) if prompt ("\nContinue ? (y/n)") eq 'n';
	write_file_list ($files_list, \@sorted);
}

sub write_file_list {
	my ($filename, $files) = @_;

	open my $fh, '>', $filename or die "Unable to open $filename";
	for my $file (@$files) {
		print $fh "file '$file'\n";
	}
	close $fh;
}

sub get_parent_dir {
	my $filename = shift;
	$filename =~ s/^(.+)
				\/\w+\.wav
				/$1/x; # strip trailing /filename.wav
	return $filename;
}

=pod

=head1 NAME

 audio_join.pl

=head1 SYNOPSIS

 perl audio_join.pl input_folder output_folder/filename.wav

 Arguments :

  full path of folder to read FLAC files from
  full path and filename of WAV file to write

 Ensure that neither filenames or folder names have spaces

=head1 DESCRIPTION

 Script to join All FLAC files in a folder into a single WAV file

=head1 AUTHOR

Steve Hope 15/03/2018

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
