#!/usr/bin/perl

$bfile = $ARGV[0];
chomp $bfile;

open (INP1,"<sres.res");
open (INP2,"<$bfile");

$sres = <INP1>;
chomp $sres;

@bur = <INP2>;

$srn = int(substr($sres,0,3));
$srt = substr($sres,4,3);


foreach $b (@bur)
{
chomp $b;
$rn = int(substr($b,7,3));
$rt = substr($b,15,3);
$br = substr($b,42,4);
	if ($srn == $rn && $srt eq $rt)
	{
	$sbur = $br;
	}
}

if ($srt eq 'GLY' || $sbur > 0.30)
{
print "EXPOSEDorGLYCINE\n";
}


