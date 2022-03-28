# backup_vinyl.pl 27-30/12/21

use strict;
use warnings;

use Audio::FLAC::Header;
use MP3::Tag;
use Path::Tiny; # path
use File::Copy; # copy
use Scalar::Util qw(reftype);

sub check_tags {
	my ($src_tags, $dest_tags) = @_;

	return $src_tags->{title} eq $dest_tags->{title}
	&& $src_tags->{artist} eq $dest_tags->{artist}
	&& $src_tags->{album} eq $dest_tags->{album}
	&& $src_tags->{genre} eq $dest_tags->{genre};
}

sub get_flac_genre {
	my $tags = shift;
	return "" unless defined $tags->{GENRE};
	my $type = reftype ($tags->{GENRE});
	if (defined $type && $type eq 'ARRAY') {
		return join (';', $tags->{GENRE}->@*);
	} else {
		return $tags->{GENRE};
	}
}

sub get_flac_tags {
	my $filename = shift;
	my $flac = Audio::FLAC::Header->new ($filename);
	my $tags = $flac->tags ();

	return {
		title => $tags->{title} // "",
		artist => $tags->{ARTIST} // "",
		album => $tags->{ALBUM} // "",
		genre => get_flac_genre ($tags),
	};
}

sub get_mp3_tags {
	my $filename = shift;
	my $mp3 = MP3::Tag->new ($filename);
	my $tags = $mp3->autoinfo();

	return {
		title => $tags->{song} // "",
		artist => $tags->{artist} // "",
		album => $tags->{album} // "",
		genre => $tags->{genre} // "",
	};
}

sub print_tags {
	my $tags = shift;

	print "\nTitle  : $tags->{title}";
	print "\nArtist : $tags->{artist}";
	print "\nAlbum  : $tags->{album}";
	print "\nGenre  : $tags->{genre}";
}

=begin comment
sub compare {
	my ($tags_fn, $source_dir, $dest_dir, $file) = @_;
	my $dest_tags;
	
	my $src_tags = $tags_fn->("$source_dir/$file");
	if (-e "$dest_dir/$file") {
		$dest_tags = $tags_fn->("$dest_dir/$file");
		if (check_tags ($src_tags, $dest_tags)) {
			print "\nOK : $source_dir/$file";
			return 0;
		} else {
			print "\nFAIL : $source_dir/$file";
			return 1;
		}
	} else {
		print "\n**ERROR** Unable to find $dest_dir/$file";
		return 0;
	}
}
=end comment
=cut

sub compare {
	my ($tags_fn, $source_dir, $dest_dir, $file) = @_;
	
	unless (-e "$dest_dir/$file") {
		print "\n**ERROR** Unable to find $dest_dir/$file";
		return 0;
	}
	my $src_tags = $tags_fn->("$source_dir/$file");
	my $dest_tags = $tags_fn->("$dest_dir/$file");
	if (check_tags ($src_tags, $dest_tags)) {
		print "\nOK : $source_dir/$file";
		return 0;
	} else {
		print "\nFAIL : $source_dir/$file";
		return 1;
	}
}

my $coderef = sub {
	my $source_dir = shift;

	if (-d $source_dir) {
		opendir my $dh, $source_dir or die "Can't open directory $source_dir: $!";
		my @files = readdir $dh;

		for my $file (@files) {
			my $dest_dir = $source_dir;
			$dest_dir =~ s/C:\/\/Mine\/Music/F:\/\/Mine/;
			
			if ($file =~ /\.flac/) {
				if (compare (\&get_flac_tags, $source_dir, $dest_dir, $file)) {
					copy ("$source_dir/$file", "$dest_dir/$file");
				}
			} elsif ($file =~ /\.mp3/) {
				if (compare (\&get_mp3_tags, $source_dir, $dest_dir, $file)) {
					copy ("$source_dir/$file", "$dest_dir/$file");
				}
			} elsif ($file =~ /\.jpg/) {
				unless (-e "$dest_dir/$file") {
					print "\nFound $source_dir/$file";
					copy ("source_dir/$file", "$dest_dir/$file");
				}
			}
		}
		closedir $dh;
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

#=begin comment

my $src_folder = "C://Mine/Music/Vinyl";
#my $src_folder = "C://Mine/Music/Bandcamp";
die "Please supply directory folder or band name" unless @ARGV == 1;

my $dir = $ARGV[0];
my $folder = "$src_folder/$dir";
dir_walk ($coderef, $folder);

#=end comment
#=cut

=pod

=head1 NAME

 backup_vinyl.pl

=head1 SYNOPSIS

 perl backup_vinyl.pl

=head1 DESCRIPTION
 
 Create backups for all files with changed tags

=head1 AUTHOR

 Steve Hope 2021

=head1 LICENSE

 This library is free software. You can redistribute it and/or modify
 it under the same terms as Perl itself.

=cut
