
#   perl track_times.pl 03/02/21
#   Calculate track start times in an album-length WAV file
#   from an entered list of track lengths

use MyHeader;
use MyLib qw(prompt);

my @times = ();
my $total_time = 0;
my $count = 1;

print "\nPlease enter lengths of ALL tracks";
print "\nEnsure that all tracks are entered with 2-digit second lengths";
print "\nEnter 'x' to finish\n";

while (1) {
    my $len = prompt "Enter track length $count";
    last if lc($len) eq 'x';
    push @times, $len;
    $count ++;
}

for my $track (0..$#times) {
    my ($mins, $secs) = to_minutes ($total_time);
    printf "\nTrack %2d begins at %2d.%02d", ($track + 1), $mins, $secs;
    $total_time += to_seconds ($times[$track]);
}

sub to_seconds {
    my $time = shift;
    my ($minutes, $seconds) = ($time =~ /(\d\d?).(\d\d)/ );
    return ($minutes * 60) + $seconds;
}

sub to_minutes {
    my $time = shift;
    my $secs = $time % 60;
    my $mins = ($time - $secs) / 60;
    return ($mins, sprintf "%2d", $secs);
}

=pod

=head1 NAME

track_times.pl

=head1 SYNOPSIS

 perl track_times.pl

=head1 DESCRIPTION

 Calculate track start times in an album-length WAV file
 from an entered list of track lengths

 Please enter lengths of ALL tracks
 Ensure that all tracks are entered with 2-digit second lengths
 Enter 'x' to finish

=head1 AUTHOR

Steve Hope 03/02/2021

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
