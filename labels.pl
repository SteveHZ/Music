#	labels.pl 15/04/21

use strict;
use warnings;

use MyLib qw(prompt);
use File::Find;
use Audio::FLAC::Header;

my $base_path = "c:/mine/music/vinyl/";
my $dir = get_directory ($base_path);
my $album_title = get_last_dir ($dir);

my $path = $base_path.$dir;
chdir ($path) or die "\nUnable to find folder '$path'";

my $files = get_files ($path);
my $info = get_info ($path, $files);
write_file ($album_title, $info);

sub get_directory {
	my $base_path = shift;
	return prompt ("Directory ($base_path) ",':');
}

sub get_last_dir {
	my ($path, $n) = @_;
	$n //= 1;
	my @dirs = split '/', $path;
	return (@dirs > 1) ? $dirs [@dirs - $n]
					   : '/';
}

sub get_files {
	my $path = shift;
	my @files = ();
	find ( sub {
		push @files, $_ if $_ =~ /\.flac$/
	}, $path);
	return [ sort @files ];
}

sub get_info {
	my ($path, $files) = @_;
	my @tracks = ();
	for my $song (@$files) {
		my $flac = Audio::FLAC::Header->new ("$path/$song");
		my $tags = $flac->tags ();

		push @tracks, {
			track => "$tags->{TRACKNUMBER} $tags->{title}",
			length => $flac->{trackTotalLengthSeconds},
		};
	}
	return \@tracks;
}

sub write_file {
	my ($album_title, $info) = @_;
	my $labels_dir = "c:/mine/music/waves/projects/labels";
	my $time = 0;
	
	print "\nWriting $labels_dir/$album_title.txt\n\n";

	open my $fh, '>', "$labels_dir/$album_title.txt";
	for my $song (@$info) {
		my $secs = sprintf ("%.6f", $time);
		my $line = "$secs\t$secs\t$song->{track}";
		
		print "$line\n";
		print $fh "$line\n";
		$time += $song->{length};
	}
	close $fh;	
}

=pod

=head1 NAME

labels.pl

=head1 SYNOPSIS

perl labels.pl

=head1 DESCRIPTION

Read metadata info from a folder of flac files to produce a label track to be used in an Audacity project.

=head1 AUTHOR

Steve Hope 2021

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

=begin comment
#=head
use MP3::Tag;

my $path = "C:/Mine/Music/Vinyl";
my $file = "$path/Dio Heaven and Hell/Holy Diver/03 Gypsy.flac";
print "\n file = $file\n";
my $flac = Audio::FLAC::Header->new ($file);
my $info = $flac->info ();
for my $key (keys $info->%*) {
	print "\nINFO : $key = $info->{$key}";
}
print "\n\n";
my $tags = $flac->tags ();
for my $key (keys $tags->%*) {
	print "\nTAGS : $key = $tags->{$key}";
}
#print "\n Minutes = ".$flac->info->{trackLengthMinutes};
#print "\n Minutes = ".$flac->info (qw(trackLengthFrames));
my $stuff = [qw (fileSize)];
print "\nMinutes = ".$flac->{trackLengthMinutes};
print "\nSeconds = ".$flac->{trackLengthSeconds};
print "\nLen Secs = ".$flac->{trackTotalLengthSeconds};
print "\nFrames = ".$flac->{trackLengthFrames};

die;

sub get_info {
	my ($path, $files) = @_;
	for my $song (@$files) {
		my $flac = Audio::FLAC::Header->new ("$path/$song");
#		my $info = $flac->info ();
#		for my $key (keys $info->%*) {
#			print "\nINFO : $key = $info->{$key}";
#		}
#		print "\n\n";
		my $tags = $flac->tags ();
#		for my $key (keys $tags->%*) {
#			print "\nTAGS : $key = $tags->{$key}";
#		}
		print "\nSong = $tags->{TRACKNUMBER} $tags->{title}";
		print "\nMinutes = ".$flac->{trackLengthMinutes};
		print " Seconds = ".$flac->{trackLengthSeconds};
		print " Len Secs = ".$flac->{trackTotalLengthSeconds};
#		print "\nFrames = ".$flac->{trackLengthFrames};
	}
}

=end comment
=cut
