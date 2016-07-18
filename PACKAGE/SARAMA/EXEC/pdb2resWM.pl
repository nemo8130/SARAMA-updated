#!/usr/bin/perl

$fn = $ARGV[0];     # pdb file
chomp $fn;

open (INP,"<$fn");
@dat = <INP>;
close INP;

open (NUM,">numM.res");

@data = grep(/^ATOM\s+/ || /^HETATM\s/,@dat);

$of = $fn;
$of =~ s/.pdb/.res/g;
open (OUT,">$of");

@res = ();
%unq = ();

foreach $k (@data)
{
chomp $k;
$r = int(substr($k,23,3)).'-'.substr($k,17,3);
$unq{$r}++;
}

@ures = sort {$a <=> $b} keys %unq;

$l = @ures;

printf NUM "%3d\n", $l;

foreach $k (@ures)
{
printf OUT "%7s\n",$k;
}

#printf "%10s  %3d\n",$fn,$l;
