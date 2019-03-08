#!/usr/bin/perl

# FOR A GIVEN SINGLE RESIDUE

$resfile = $ARGV[0];	# modified res file
chomp $resfile;

open (INP,"<$resfile") || die "res file not found\n";
open (SRES,"<smresE.res") || die "sres.res not found\n";

$targetres = <SRES>;
chomp $targetres;

@resf = <INP>;

$ln = @resf;

foreach (@resf) {chomp $_;}

@aa3 = ('GLY','ALA','VAL','LEU','ILE','PHE','TYR','TRP','SER','THR','CYS','CYX','MET','ASP','GLU','ASN','GLN','LYS','ARG','PRO','HID','HIE','HIP','GNN','ANN','VNN','LNN','INN','FNN','YNN','WNN','SNN','TNN','CSN','CXN','MNN','DNN','ENN','NNN','QNN','KNN','RNN','PNN','HDN','HEN','HPN','GCC','ACC','VCC','LCC','ICC','FCC','YCC','WCC','SCC','TCC','CSC','CXC','MCC','DCC','ECC','NCC','QCC','KCC','RCC','PCC','HDC','HEC','HPC');

@aa1 = ('G','A','V','L','I','F','Y','W','S','T','C','C','M','D','E','N','Q','K','R','P','H','H','H','G','A','V','L','I','F','Y','W','S','T','C','C','M','D','E','N','Q','K','R','P','H','H','H','G','A','V','L','I','F','Y','W','S','T','C','C','M','D','E','N','Q','K','R','P','H','H','H');

for $i (0..$ln-1)
{
$candres = $resf[$i];			# candidate residue
#print "$candres  $targetres\n";
	if ($candres eq $targetres)
	{
	goto CALCULATE
	}
	else
	{
	goto SKIP
	}
CALCULATE:
$rn = int(substr($resf[$i],0,3));
$rt = substr($resf[$i],4,3);
$flagR = 0;
	if ($rt ne "GLY")
	{
	$flagR = 0;
	$cnt = 0;
		for $t (0..scalar(@aa3)-1)
		{
			if ($rt eq $aa3[$t])
			{
			$rt1 = $aa1[$t];			
			$flagR = 1;
			}			
		}
#	print "$rn $rt $rt1 $flagR\n";
		if ($flagR == 1)		# naturally occuring amino-acid residues
		{
#===================================================================
# outfile name : e.g., Y30sf.pdb, Y30cf.pdb
#===================================================================
		$self_field = $rt1.$rn.'sf.pdb';	# field due to the residue itself
		$comp_field = $rt1.$rn.'cf.pdb';	# field due to rest of the protein
#printf "%7s     %10s     %10s\n",$candres,$self_field,$comp_field;

#================================
# Create res.replace file
#================================

#===========================================================================
# for self field : rest of the protein would be replaced by with dummy atoms
#===========================================================================

		@rest = ();

			foreach (@resf)
			{
				if ($_ ne $candres)
				{
				@rest = (@rest,$_);
				}
			}
		open (OUT,">res.replace");
			foreach (@rest)
			{
			print OUT $_,"\n";
			}
		close OUT;
		do './EXEC/dum2pdbNC.pl'; # out : dumm.pdb

		`mv dumm.pdb $self_field`;	# linux
#`move dumm.pdb $self_field`; (MS-DOS)

#=======================================================================
# For complimentary field : the residue would be replaced by dummy atoms
#=======================================================================

		open (OUT,">res.replace");
		print OUT $candres,"\n";
		close OUT;

		do './EXEC/dum2pdbNC.pl'; # out : dumm.pdb

		`mv dumm.pdb $comp_field`;	# linux
		# `move dumm.pdb $comp_field`; (MS-DOS)
		}
	}
SKIP:
}

