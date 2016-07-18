#!/usr/bin/perl

$fn = $ARGV[0];     # pdb file
chomp $fn;

open (INP,"<$fn");
@dat = <INP>;
close INP;

@data = grep(/^ATOM\s+/,@dat);

$of = $fn;
$of =~ s/.pdb/.res/g;
open (OUT,">$of");

%unq = ();

foreach $k (@data)
{
chomp $k;
$r = int(substr($k,23,3)).'-'.substr($k,17,3);
$unq{$r}++;
}

@ures = sort {$a <=> $b} keys %unq;

$l = @ures;

foreach $k (@ures)
{
printf OUT "%7s\n",$k;
}

#=================== CHECK REDUNDANCY ========================

@chm = grep(/^HETATM\s/,@dat);
$lm = @chm;

if ($lm == 0)
{
goto NOMET;
}
elsif ($lm >= 1)
{
goto MET;
}

MET:

@data = grep(/^ATOM\s+/ || /^HETATM\s/,@dat);
%unq = ();

foreach $k (@data)
{
chomp $k;
$r = int(substr($k,23,3)).'-'.substr($k,17,3);
$unq{$r}++;
}

@ures = sort {$a <=> $b} keys %unq;

NOMET:

%redun = ();

foreach $k (@ures)
{
$rn = int(substr($k,0,3));
$redun{$rn}++;		# Check redundant residue identities for same position
}

@urn = keys %redun;
@frq = values %redun;

$rrn = 0;
@rdn = ();

for $n (0..scalar(@frq)-1)
{
	if ($frq[$n] > 1)
	{
	$rrn++;
	@rdn = (@rdn,$urn[$n])
	}
}

open (REDUN,">redun.out");

open (LOGR,">rdn.log");

if ($rrn > 0)
{
print LOGR "redundant residue identities for same position found in $rrn cases\n";
print LOGR "for residue position(s):\n";
	foreach $a (@rdn)
	{
	print LOGR "$a\n";
	}
print REDUN "redundant\n";
}

#printf "%10s  %3d\n",$fn,$l;
