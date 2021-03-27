# tagstest.pl 04-05/01/14, 22/11/15

use strict;
use warnings;

use File::Find;
use Audio::FLAC::Header;
use MP3::Tag;

getflactags ();
#getmp3tags();

sub getflactags {
	my $flacfile = "C:\\Music\\Phone\\test\\03 Soldier.flac";
#	my $flacfile = "C:\\Music\\Mine\\test\\103 Time Stand Still.flac";

	my $flac = Audio::FLAC::Header->new($flacfile);

    my $info = $flac->info();

	print "\n\nINFO :\n";
    foreach (keys %$info) {
	    print "$_: $info->{$_}\n";
    }

    my $tags = $flac->tags();

	print "\n\nTAGS :\n";
    foreach (keys %$tags) {
	    print "$_: $tags->{$_}\n";
    }

	print "\n\nAMENDED :";

#	my ($track,$title) = split (/ /,$tags->{title});
#	$tags->{TRACKNUMBER} = $track;
#	$tags->{title} = $title;
	$tags->{Album} = " I Am Anonymous";
	$tags->{Genre} = "Prog Rock";
	$tags->{DATE} = 2064;

	print "\n\n\n";
    foreach (keys %$tags) {
	    print "$_: $tags->{$_}\n";
    }

	my $m = $flac->{trackLengthMinutes};
	my $s = $flac->{trackLengthSeconds};
	print "\ntime = $m.$s";

	$flac->write ();
}

sub getmp3tags {
	my $mp3file = "C:\\Music\\Waves\\04 Shadows.mp3";
#	my $mp3file = "C:\\Music\\Mine\\test\\04 Rococo.mp3";
#	my $mp3file = "C:\\Music\\Phone\\test\\03 Soldier.flac";

	my $mp3 = MP3::Tag->new($mp3file);
	my $info = $mp3->autoinfo();
#	my ($title, $track, $artist, $album, $comment, $year, $genre) = $mp3->autoinfo();

	print "\n\nIn getmp3tags...";
	print "\n\n\ntitle = $info->{title}";
	print "\ntrack = $info->{track}";
	print "\nartist = $info->{artist}";
	print "\nalbum = $info->{album}";
	print "\ncomment = $info->{comment}";
	print "\nyear = $info->{year}";
	print "\ngenre = $info->{genre}\n\n";

	$mp3->update_tags({ track => '12',
						comment => 'Jazz',
						year => '1999'});

	print "\n\nUpdated >";

	print "\ntrack = ".$mp3->track();
	print "\ntitle = ".$mp3->title();
	print "\nartist = ".$mp3->artist();
	print "\nalbum = ".$mp3->album();
	print "\nyear = ".$mp3->year();
	print "\ncomment = ".$mp3->comment();
	print "\n\n";

#	my ($key,$value);
#	while (($key, $value) = each %$mp3) {
#	  	print "\n$key = $value";
#      	delete $mp3->{$key};   # This is safe
#   }
#  	print "\n\n Here";
#   foreach (@{%{$mp3}{gottags}}) {
#	   print "\n",$_;
#   }
}
