
# rename.pl 22/09/13

# From the command line, perl rename.pl test
# where test is the folder in 'MyMusic/Vinyl' containing the flac files
# and a setlist file named "setlist.txt"

use strict;
use File::Find;
use File::Copy qw(move);

my @titles = ();
my @flacs = ();
my @dirs = ( "C:\\Mine\\Music\\Vinyl",
			 "F:\\Mine\\Temp" );
my $txtfile = "setlist.txt";

my $drive = 0;
foreach my $arg (@ARGV) {
	$drive = 1 if $arg eq "-f";
}

chdir $dirs[$drive] or die "\n\n Unable to find folder !!!";

find ( sub { push @flacs, $_ if $_ =~ /.flac$/ }, $ARGV[0] );

chdir $ARGV[0] or die "can't change directory";

open my $fh, "$txtfile" or die "Can't find $txtfile";
while ($line = <$fh>) {
	chomp ($line);
	push @titles, $line;
}

my @sorted = sort @flacs;
for ($i = 0;$i <= $#sorted; $i++) {
	my ($title, $filetype) = split ('\.',$sorted [$i]);
	my $newfilename = sprintf ("%02d %s.%s", $i+1, $titles[$i], $filetype);
	move $sorted [$i], $newfilename;
	print "\n".$sorted [$i], " renamed to ".$newfilename."\n";
}
