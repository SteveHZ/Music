use strict;
use warnings;
use Win32::File qw(GetAttributes SetAttributes HIDDEN ARCHIVE);

die "Please enter episode number" if scalar @ARGV == 0;

my $filename = "C:/Mine/Music/Podcasts/Sequences/Sequences $ARGV[0].mp3";
my $attrs;

GetAttributes ($filename, $attrs) or die $^E;
print "\nattrs = $attrs";

$attrs |= Win32::File::HIDDEN;
SetAttributes ($filename, $attrs) or die $^E;
print "\nattrs = $attrs";

=pod

=head1 NAME

 hide.pl

=head1 SYNOPSIS

 perl hide.pl [episode number]
 
=head1 DESCRIPTION

 Set Sequences mp3 file to HIDDEN
 
=head1 AUTHOR

 Steve Hope 2021

=head1 LICENSE

 This library is free software. You can redistribute it and/or modify
 it under the same terms as Perl itself.

=cut
