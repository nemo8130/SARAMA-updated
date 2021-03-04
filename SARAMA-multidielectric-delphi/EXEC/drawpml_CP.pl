#!/usr/bin/perl
#

$basename=$ARGV[0] || die "Enter basename\n";
chomp $basename;
$file1=$basename.'-comp.cb';
$file2=$basename.'-comp.pb';
$file3=$basename.'-comp.pe';

$outfile=$basename.'_CP.pml';
open (OUT,">$outfile");

open (INP1,"<$file1") || print "$file1 not found\n";
open (INP2,"<$file2") || print "$file2 not found\n";
open (INP3,"<$file3") || print "$file3 not found\n";

@dat1=<INP1>;
@dat2=<INP2>;
@dat3=<INP3>;

@cp11=grep (/  probable/,@dat1);
@cp12=grep (/less probable/,@dat1);
@cp13=grep (/improbable/,@dat1);

@cp21=grep (/  probable/,@dat2);
@cp22=grep (/less probable/,@dat2);
@cp23=grep (/improbable/,@dat2);

@cp31=grep (/  probable/,@dat3);
@cp32=grep (/less probable/,@dat3);
@cp33=grep (/improbable/,@dat3);

@r11=();@r12=();@r13=();
@r21=();@r22=();@r23=();
@r31=();@r32=();@r33=();

foreach (@cp11)
{
	chomp $_;
	@r11=(@r11,int(substr($_,0,3)));
}

foreach (@cp12)
{
	chomp $_;
	@r12=(@r12,int(substr($_,0,3)));
}

foreach (@cp13)
{
	chomp $_;
	@r13=(@r13,int(substr($_,0,3)));
}

foreach (@cp21)
{
	chomp $_;
	@r21=(@r21,int(substr($_,0,3)));
}

foreach (@cp22)
{
	chomp $_;
	@r22=(@r22,int(substr($_,0,3)));
}

foreach (@cp23)
{
	chomp $_;
	@r23=(@r23,int(substr($_,0,3)));
}

foreach (@cp31)
{
	chomp $_;
	@r31=(@r31,int(substr($_,0,3)));
}

foreach (@cp32)
{
	chomp $_;
	@r32=(@r32,int(substr($_,0,3)));
}

foreach (@cp33)
{
	chomp $_;
	@r33=(@r33,int(substr($_,0,3)));
}

print "------------------------\n";
print "CP1:  probable\n";
print "------------------------\n";

foreach $a (@r11)
{
	print $a,"\n";
}

print "------------------------\n";
print "CP1:  less probable\n";
print "------------------------\n";

foreach $a (@r12)
{
	print $a,"\n";
}

print "------------------------\n";
print "CP1:  improbable\n";
print "------------------------\n";

foreach $a (@r13)
{
	print $a,"\n";
}

print "------------------------\n";
print "CP2:  probable\n";
print "------------------------\n";

foreach $a (@r21)
{
	print $a,"\n";
}

print "------------------------\n";
print "CP2:  less probable\n";
print "------------------------\n";

foreach $a (@r22)
{
	print $a,"\n";
}

print "------------------------\n";
print "CP2:  improbable\n";
print "------------------------\n";

foreach $a (@r23)
{
	print $a,"\n";
}


print "------------------------\n";
print "CP3:  probable\n";
print "------------------------\n";

foreach $a (@r31)
{
	print $a,"\n";
}

print "------------------------\n";
print "CP3:  less probable\n";
print "------------------------\n";

foreach $a (@r32)
{
	print $a,"\n";
}

print "------------------------\n";
print "CP3:  improbable\n";
print "------------------------\n";

foreach $a (@r33)
{
	print $a,"\n";
}

@resNE=(@r11,@r12,@r13,@r21,@r22,@r23,@r31,@r32,@r33);
@resP=(@r11,@r21,@r31);
@resLP=(@r12,@r22,@r32);
@resIP=(@r13,@r23,@r33);

foreach $a (@resNE)
{
	print $a,"\n";
}

print OUT "load $basename.pdb\n";
print OUT "hide all\n";
print OUT "show cartoon\n";
print OUT "set cartoon_transparency, 0.25\n";
print OUT "set cartoon_side_chain_helper, off\n";
print OUT "set depth_cue=0\n";
print OUT "set ray_trace_fog=0\n";
print OUT "set cartoon_side_chain_helper, off\n";
print OUT "set dash_gap, 0.3\n";
print OUT "set dash_width, 4.0\n";
print OUT "set dash_radius, 0.06\n";
print OUT "util.cbc\n";
print OUT "bg_color black\n";

print OUT "select nexp, ";
foreach $a (@resNE)
{
print OUT "resi $a ";
}
print OUT "\n";

print OUT "select prob, ";
foreach $a (@resP)
{
print OUT "resi $a ";
}
print OUT "\n";

print OUT "select lprob, ";
foreach $a (@resLP)
{
print OUT "resi $a ";
}
print OUT "\n";

print OUT "select iprob, ";
foreach $a (@resIP)
{
print OUT "resi $a ";
}
print OUT "\n";

print OUT "select met, het\n";
print OUT "show spheres, met\n";

print OUT "\n";
print OUT "set stick_radius, 0.25\n";
print OUT "set stick_ball, on\n";
print OUT "set stick_ball_ratio, 1.5\n";
print OUT "set_bond stick_transparency, 0.50, nexp\n";
print OUT "label n. CA and nexp, \"%s-%s\" %(resi,resn)\n";
print OUT "set label_font_id, 10\n";
print OUT "set label_color, white, nexp\n";
print OUT "set label_size, 15\n";
print OUT "set label_shadow_mode, 1\n";

print OUT "color warmpink, $basename\n";
print OUT "color greencyan, nexp\n";
print OUT "color yellow, prob\n";
print OUT "color orange, lprob\n";
print OUT "color red, iprob\n";
print OUT "color blue, met\n";

print OUT "orient\n";
print OUT "center met\n";

