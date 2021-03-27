
# trim.pl 30/12/13 - 18/01/14
# v2 29/10/15 - 01/11/15, 04-12/12/15, 01/04/18

use strict;
use warnings;

use MyLib qw(prompt);
use File::Find;
use Text::ParseWords qw(parse_line);

my (@presort, @flacs, @renamed, @temp);

main ();

sub main {
	my (@argv, $drive, $line, $action);

	my $dispatch = {
		trim 		=>	sub { trim ($_[0], $_[1]); update (); },
		trimtoend 	=> 	sub { trim ($_[0], 0); update (); },
		insert 		=> 	sub { insert ($_[0], $_[1]); update (); },
		setlist 	=> 	sub { setlist ($_[0]); update (); },
		save 		=> 	sub { save (); },
		help 		=> 	sub { help (); },
		exit 		=> 	sub { exit (1); },
		_DEFAULT_	=>	sub { print "Unknown command !!"; help (); },
	};

	my $filetype = get_filetype ();
	my $dir = prompt "Directory (c:/mine/music/) ";
	my $path = "c:/mine/music/".$dir;
	chdir ($path) or die "\nUnable to find folder $path";

	find ( sub { push @presort, $_ if $_ =~ /.$filetype$/}, $path);
	@flacs = sort @presort;
	push @renamed, $_ for @flacs;

	while (1) {
		clear_array (\@temp);
		print "\n$_" for @renamed;

		$line = prompt "\n\ntrim ";
		get_cmd_line ($line, \@argv);

		$action = $dispatch->{$argv[0]} || $dispatch->{_DEFAULT_};
		$action->(splice (@argv, 1));
	}
}

sub get_filetype {
	while (1) {
		my $ftype = prompt ('Enter filetype (flac/mp3)',':');
		return $ftype if $ftype eq "flac" || $ftype eq "mp3";
	}
}

sub clear_array {
	my $ref = shift;

	my $elements = scalar @$ref;
	pop @$ref while ($elements-- > 0);
}

sub get_cmd_line {
	my ($line, $args) = @_;

	@$args = parse_line ('\s+', 0, $line);
}

sub trim {
	my ($startpos, $count) = @_;
	my $newfile;

	for (@renamed) {
		$newfile = ($count > 0) ?
			trim_file_name ($_, $startpos, $count):
			trim_to_end ($_, $startpos);
		print "\n$newfile";
		push @temp, $newfile;
	}
}

sub trim_file_name {
	my ($file, $startpos, $count) = @_;

	my $len = length ($file);
	my $idx = index ($file, ".");
	my $mid = $len - $idx;

	return substr ($file, 0, $startpos).
		   substr ($file, $startpos + $count, $len - $count);
}

sub trim_to_end {
	my ($file, $startpos) = @_;
	my ($len, $idx, $mid);

	$len = length ($file);
	$idx = index ($file, ".");
	$mid = $len - $idx;

	return substr ($file, 0, $startpos).
		   substr ($file, $idx - $len);  # add file extension
}

sub insert {
	my ($startpos, $str) = @_;
	my ($newfile, $len);

	for (@renamed) {
		$len = length ($_);
		$str = " " if $str eq "space";
		$newfile = substr ($_, 0, $startpos). $str.
	     		   substr ($_, $startpos, $len);
		print "\n$newfile";
		push @temp, $newfile;
	}
}

sub update {
	my $key = prompt "Accept ? (Y/N)  ";

	if (lc ($key) eq "y") {
		print "\nUpdating ...";
		for my $i (0...$#flacs) {
			$renamed[$i] = $temp[$i];
			print "\nRenamed $flacs[$i] to $renamed[$i]";
		}
	} else {
		print "\nOK, Whatever ...";
	}
	print "\n";
}

sub help {
	print "\n\ntrim <startpos> <count>";
	print "\ntrimtoend <startpos>";
	print "\ninsert <startpos> <string>";
	print "\ninsert <startpos> space";
	print "\nsetlist - <filename without extension>";
	print "\nsave - save";
	print "\nexit - exit without saving";
	print "\n";
}

sub save {
	print "\nRenaming files ...";
	for my $i (0...$#flacs) {
		rename $flacs[$i], $renamed[$i];
	}
	print "Done\n";
}

sub setlist {
	my $fname = shift;
	my (@tracks);
	my ($len, $idx);

	my $filename = $fname.".txt";
	open (my $fh, '<', $filename) or die "Can't find $fname";
	while (my $line = <$fh>) {
		chomp ($line);
		print "\n$line";
		push @tracks, $line;
	}
	die "\n\nWrong number of tracks !!!" unless $#tracks == $#renamed;

	print "\n";
	for my $i (0...$#tracks) {
		# get initial numbers and following space
		die "\n\nWrong filename format !!!" unless ($renamed [$i] =~ /(?<track_no>\d+[ ])/);

		$len = length ($renamed [$i]) - 1;
		$idx = index ($renamed [$i], ".");
		$temp [$i] =
		 	$+{track_no}.
			$tracks [$i].
			substr ($renamed [$i], $idx, $len); # add file extension

		print "\n".$renamed [$i]."  ->  ".$temp[$i];
	}
}
