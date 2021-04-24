
#	backup.pl 27-29/09/15
#	v1.1 03/01/16

use strict;
use warnings;
use MP3::Tag;
use MyLib qw(prompt);

#my $top_dir = "This PC//Galaxy J5/Card/Music/Albums";
my $top_dir = "C:/Mine/Music/Vinyl/Bandcamp mp3/Megadeth";

my $coderef = sub {
	my $dir = shift;
	if (-d $dir) {
		print "\nIn here";
		opendir my $dh, $dir or die "Can't open directory $dir: $!";
		my $my_genre = prompt ("\n$dir ",'>');
		
		unless ($my_genre eq 'x') {
			my @files = readdir $dh;
		
			for my $file (@files) {
				if ($file =~ /\.mp3$/) {
					my $mp3 = MP3::Tag->new ("$dir/$file");
					my ($title, $track, $artist, $album, $comment, $year, $genre) = $mp3->autoinfo();
					$mp3->update_tags ({
						title => $title,
						track => $track,
						artist => $artist,
						album => $album,
						year => $year,
						genre => $my_genre,
					});

#					print $mp3->genre();;
				}
			}
			closedir $dh;
		}
	}
};

sub dir_walk {
	my ($code, $top) = @_;
	my $dh;

	$code->($top);

	if (-d $top) {
		my $file;
		unless (opendir $dh, $top) {
			warn "Couldn’t open directory $top: $!; skipping.\n";
			return;
		}
		while ($file = readdir $dh) {
			next if $file =~ /^\./;
			dir_walk ($code, "$top/$file");
		}
	}
}

dir_walk ($coderef, $top_dir);


=pod

=head1 NAME

backup.pl

=head1 SYNOPSIS

perl backup.pl

=head1 DESCRIPTION

Back up all files

=head1 AUTHOR

Steve Hope 2015

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
