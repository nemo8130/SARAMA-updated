#!/usr/bin/perl

open (R1,"<res1.out");
open (TAR,"<sres.res");
open (MTAR,">smres.res");

$r1 = <R1>;
$target = <TAR>;

chomp $r1;
chomp $target;

$tarrn = int(substr($target,0,3));
$tarrt = substr($target,4,3);
$maptar = $tarrn - ($r1-1);
printf MTAR "%3d%1s%3s\n",$maptar,'-',$tarrt;
