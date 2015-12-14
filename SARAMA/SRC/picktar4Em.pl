#!/usr/bin/perl

$mresf = $ARGV[0];	# modified res file
open (MRES,"<$mresf");
@mres = <MRES>;

open (SMRES2,">smresE.res");

open (SR1,"<sres.res");
$tar = <SR1>;
chomp $tar;

$rntar = int(substr($tar,0,3));

for $i (0..scalar(@mres)-1)
{
chomp $mres[$i];
$rn = int(substr($mres[$i],0,3));
	if ($rntar == $rn)
	{
	print SMRES2 $mres[$i],"\n";
	}
}


