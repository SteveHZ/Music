
# 	tags.pl 04-05/01/14
# 	v1.01 22-24/11/15, 27/12/15
#	v1.02 using MyMP3::Tag 29/04/17
#	v1.03 MP3 Tag v1.14 fixed 23/08/17

use strict;
use warnings;

use MyLib qw(prompt);
use File::Find;
use Audio::FLAC::Header;
use MP3::Tag;

main ();

sub main {
	my $dispatch = {
		flac => sub { update_flac_tags (@_) },
		mp3	 => sub { update_mp3_tags  (@_) },
	};

	my $filetype = get_filetype ();
	my $dir = get_directory ();
	my $path = "c:/mine/music/".$dir;
	chdir ($path) or die "\nUnable to find folder '$path'";

	my @files = ();
	find ( sub {
		push @files, $_ if $_ =~ /\.$filetype$/
	}, $path);
	my @sorted = sort @files;
	print "\n$_" for @sorted;

	my $info = get_info ();

	$dispatch->{$filetype}->(\@sorted, $info);
	print "\n";
}

sub get_filetype {
	while (1) {
		my $ftype = prompt ('Enter filetype (flac/mp3)',':');
		return $ftype if $ftype eq "flac" || $ftype eq "mp3";
	}
}

sub get_directory {
	return prompt ('Directory (c:/mine/music/) ',':');
}

sub get_info {
	print "\n\nArtist : ";
	chomp (my $artist = <STDIN>);
	print "Album  : ";
	chomp (my $album = <STDIN>);
	print "Genre  : ";
	chomp (my $genre = <STDIN>);

	return {
		artist => $artist,
		album => $album,
		genre => $genre,
	};
}

sub update_flac_tags {
	my ($flacs, $info) = @_;

	for my $song (@$flacs) {
		my $flac = Audio::FLAC::Header->new ($song);
		my $tags = $flac->tags ();

		print "\nWriting tags for $song...";
		$tags->{Artist} = $info->{artist};
		$tags->{Album}  = $info->{album};
		$tags->{Genre}  = $info->{genre};

		$flac->write ();
	}
}

sub update_mp3_tags {
	my ($mp3s, $info) = @_;

	for my $song (@$mp3s) {
		my $mp3 = MP3::Tag->new ($song);
		my ($track, $title) = split (' ', $song);

		print "\nWriting tags for $song...";
		$mp3->update_tags ({
			artist 	=> $info->{artist},
			album 	=> $info->{album},
			genre 	=> $info->{genre},
			track	=> $track,
		});
	}
}

=pod

=head1 NAME

tags.pl

=head1 SYNOPSIS

perl tags.pl

=head1 DESCRIPTION

Update tags for FLAC or MP3 files

=head1 AUTHOR

Steve Hope 2014

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
