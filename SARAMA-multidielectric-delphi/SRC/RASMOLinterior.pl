#!/usr/bin/perl

$surffile = $ARGV[0];
chomp $surffile;

$compcbfile = $ARGV[1];
chomp $compcbfile;

open (INP2,"<$compcbfile");
@dat2 = <INP2>;

open (OUT,">ras.spt");

print OUT "load $surffile\n";
print OUT "wireframe off\n";
print OUT "spacefill 10\n";
print OUT "color blue\n";

foreach $a (@dat2)
{
chomp $a;
$ires = int(substr($a,0,3));
print OUT "select $ires\n";
print OUT "color white\n";
}



