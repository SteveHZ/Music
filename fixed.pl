#	fixed.pl 22-23/03/21

use strict;
use warnings;

use MyLib qw(prompt);
use File::Copy qw(move);

my $dir = prompt ("Directory (C:/Mine/Music/Vinyl/) ",":");
my $path = "C:/Mine/Music/Vinyl/$dir";

opendir my $dh, $path or die "Couldn't open $path : $!\n";
my @files = readdir $dh;
close $dh;

my @files_to_remove = ();
my @files_to_keep = ();
my $ext = "flac";

for my $file (@files) {
	if ($file =~ /.*fixed\.$ext/) {
		push @files_to_keep, $file;
	} elsif ($file =~ /.*\.$ext/) {
		push @files_to_remove, $file;
	}
}

unlink "$path/$_" for @files_to_remove;
for my $file (@files_to_keep) {
	my $new_name = $file;
	$new_name =~ s/-fixed//;
	print "\nWriting $path/$new_name...";
	move "$path/$file", "$path/$new_name";
}
print "\nDone\n";

=pod

=head1 NAME

 fixed.pl

=head1 SYNOPSIS

 perl fixed.pl

=head1 DESCRIPTION

 Remove unwanted files after fixing SBEs in TLH
 and rename the fixed files appropriately

=head1 AUTHOR

 Steve Hope 2021

=head1 LICENSE

 This library is free software. You can redistribute it and/or modify
 it under the same terms as Perl itself.

=cut
