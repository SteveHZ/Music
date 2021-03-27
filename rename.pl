
# rename.pl 22/09/13

# From the command line, perl rename.pl test
# where test is the folder in 'MyMusic/Vinyl' containing the flac files
# and a setlist file named "setlist.txt"

use strict;
use File::Find;
use File::Copy qw(move);

my (@flacs);
my (@dirs) = ( "C:\\Mine\\Music\\Vinyl",
	       		"F:\\Mine\\Temp" );
my ($txtfile) = "setlist.txt";

main ();

sub main {
	my (@sorted,@presorted,$drive,$fh);
	my ($title,$flacfile,$junk);
	my ($line, $count, @titles);
	my ($newfilename, $filetype, $i);

	$drive = 0;
	foreach my $arg (@ARGV) {
#		if ($arg eq "help") {
#			help ();
#			exit (0);
#		} else {
			$drive = 1 if $arg eq "-f";
#		}
	}

	chdir $dirs[$drive] or die "\n\n Unable to find folder !!!";

	find ( sub { push @flacs, $_ if $_ =~ /.flac$/ }, $ARGV[0] );

	chdir $ARGV[0] or die "can't change directory";

	open (FILE,"$txtfile") or die "Can't find $txtfile";
	while ($line = <FILE>) {
		chomp ($line);
		push @titles, $line;
	}

	@presorted = sort @flacs;
	for ($i = 0;$i <= $#presorted; $i++) {
		($title, $filetype) = split ('\.',$presorted [$i]);
		$newfilename = sprintf ("%02d %s.%s", $i+1, $titles[$i], $filetype);
		move $presorted [$i], $newfilename;
		print "\n".$presorted [$i], " renamed to ".$newfilename."\n";
	}
}
