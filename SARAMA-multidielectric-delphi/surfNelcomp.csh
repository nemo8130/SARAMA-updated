#!/bin/csh -f 

echo off

set delphip = `delphi95`

	if ($status == 0)then
	echo 
	echo '==========================================================================================================='
	echo 'Delphi (v.6.2) is running under the command : delphi95'
	echo 'Program will run'
	echo '==========================================================================================================='
	echo
	else
	echo
	echo '==========================================================================================================='
	echo 'Delphi is not running under the command : delphi95'
	echo 'Program will exit'
	echo '==========================================================================================================='
	echo
	goto comment
	endif

if ($#argv == 0) then
comment:
	echo '==========================================================================================================='
	echo "  "
	echo "  "
	echo "  "
	echo "  "
	echo "Missing input file in the command line!"
	echo "  "
	echo "  "
	echo "  "
	echo "Sarama:"
	echo "A program to calculate the surface and electrostatic complementarities of buried / partially buried residues"
        echo "in a (single polypeptide chain) globular protein and plot them in Complementarity Plots"
	echo "  "
	echo "  "
	echo "  "
	echo "usage                      : ./surfNelcomp.csh -inp  [PDB_filename]"
	echo "For a single residue       : ./surfNelcomp.csh -inp  [PDB_filename] target [residue_number-residue_identity]"
	echo "example                    : ./surfNelcomp.csh -inp  2HAQ.pdb"
	echo "example                    : ./surfNelcomp.csh -inp  2HAQ.pdb target 51-PHE"
	echo "For help                   : ./surfNelcomp.csh -help "
	echo "  "
	echo "  "
	echo "  "
	echo "The filename can have any number of characters but must not contain any '.' (or space ' ')"
	echo "other than that in the extension '.pdb' (in lowercase);"
	echo "e.g., 2haq.pdb, deca.pdb, 1234.pdb, x1c3.pdb 1abc-wc.pdb 2haq-00001.pdb etc."
	echo " "
	echo "PDB file must not contain more than 990 amino acid residues" 
	echo "And only a single polypeptide chain"
	echo "  "
	echo "Atoms must not have multiple occupancies"
	echo "For list of isolated metal ions considered in the calculations (and their appropreate format), view 'DOC/metal.list'"
	echo "  "
	echo "Water coordinates will be trimmed if present in the input pdb file"
	echo "Since water and surface bound ligands are modeled as bulk solvent"
	echo "The pdb file must not contain any ligand/cofactors or else these would also be trimmed prior to the calculations"
	echo "  "
	echo "In case of missing atoms / patches of residues in the input pdb, the (Sm, Em) values may not be authentic!"
	echo "  "
	echo "PDB file should definitely be Hydrogen-fitted by Reduce (v.2)"
	echo "(available at: http://kinemage.biochem.duke.edu/downloads/software/reduce/)"
	echo "Atom and residue types will have to be consistent with brookhaven (PDB) format (see brookhaven.format)"
	echo "Residue (Sequence) Number must not exceed 3 digit (999)"
	echo "Hydrogen atom types provided in the input pdb will have to be consistent with REDUCE, vesrion 2"
	echo "For Molecular visualisation RASMOL should be running and for displaying the plots (postscripts: .ps) ghostview (gv) must be installed"
	echo "  "
	echo "  "
	echo "Main Reference: Self-Complementarity within Proteins: Bridging the Gap between Binding and Folding"
	echo "                         Sankar Basu,  Dhananjay Bhattacharyya, and  Rahul Banerjee*"
	echo "                    Biophysical Journal, Volume 102, Issue 11, June 2012, pp. 2605-2614"
	echo "  "
	echo "  "
	echo "  "
	echo '==========================================================================================================='
	exit
else if ($#argv == 1)then
	set field1 = $argv[1]
	set delim = `echo $field1 | cut -c1`
	echo $delim
	goto pause
else if ($#argv == 2)then
goto start
else if ($#argv > 2)then
	if ($#argv == 4 && $argv[3] == 'target')then
	set residen = $argv[4]
	set resno = `echo $residen | cut -f1 -d'-'`
	set restype = `echo $residen | cut -f2 -d'-'`
	echo
	echo "============================================================================"
	echo "============================================================================"
	echo 'You have opted for single residue calculation for target residue :' $residen
	echo "============================================================================"
	echo "============================================================================"
	echo
	goto start
	else
	goto comment
	endif
endif

#===================================================================
pause:
	if ($field1 == '-help')then
	cat HELP/help.doc
#	firefox HELP/README.html &
	exit
	else if ($field1 != '-help')then
	goto comment
	endif
#===================================================================
start:
	if ($argv[1] == '-inp')then
	set pdb = $argv[2]
	echo
	echo 'Filename you entered:' $pdb
	rm -f chfn.inp
	echo $pdb > chfn.inp
	set fnch = `./EXEC/chfn.pl`
	echo 
	set presence = `ls $pdb`
		if ($presence == $pdb && $status == 0 && $fnch == 'OK')then
		echo
		echo $pdb 'found in the current directory, proceeding' 
		echo
		goto proceed
		else
		echo
		echo $pdb 'not found in the current directory'
		echo 'or' 
		echo 'Incorrect filename (uppercase extension .PDB / presence of more than one dots ".")'
		echo
		exit
		endif	
	else if ($argv[1] != '-inp')then
	goto pause
	endif
proceed:
set num = `echo $#argv`
echo $num
        if ($#argv == 4)then
	set sresflag = 1
	goto run
	else if ($#argv == 2)then
	set sresflag = 0
	goto run
	endif
#===================================================================
run:

echo "sresflag:" $sresflag

echo "  "
echo "  "
echo "  "
echo "Sarama:"
echo "A program to calculate the surface and electrostatic complementarities of buried / partially buried residues"
echo "in a (single polypeptide chain) globular protein and plot them in Complementarity Plots"
echo "  "
echo "  "
echo "  "
	
echo 'You entered:' $pdb
set code = `echo $pdb | cut -f1 -d"."`
#echo $code

#=======================================================================
#  CHECK INPUT PDB FORMAT AND OTHER REQUIREMENTS 
#  ACCEPT OR REJECT
#=======================================================================

rm -f formp.pdb
rm -f fch.log
rm -f fpp.status
set errorlog = LOG_`echo $code`
rm -rf $errorlog/

#=======================================================================
# Convert to original Reduce format (e.g., "HG12" -> "2HG1")  if necessary (otherwise skip)
# The 13th column should be either blank or a numeric and never the atom type "H" 
# Rather the 14th column should contain the atom type "H" 
#=======================================================================

./EXEC/reducemap.pl $pdb > temp.pdb
mv temp.pdb $pdb

#=======================================================================

./EXEC/formcheck.pl $pdb > fch.log
set chf = `head -1 formch.out`
        if ($chf == 'stop')then
        echo ""
        echo ""
        echo ""
	echo "===================================================================================================="
        echo "Input pdb file does not satisfy all conditions for the program to run and the program will thus exit"
	echo "===================================================================================================="
        echo ""
        echo ""
        echo ""
	mkdir $errorlog
	cp $pdb $errorlog/
	mv fch.log $errorlog/
	echo "==========================================================================================="
        echo "Detailed reasons for incompatibility can be found in the log file: $errorlog/fch.log"
	echo "==========================================================================================="
        echo ""
        echo ""
	echo "==========================================================================================================================="
	echo "Users reporting results using this software, should cite the following articles: (Preferably 1 & 3) "
	echo "==========================================================================================================================="
	echo "1.        Self-Complementarity within Proteins: Bridging the Gap between Binding and Folding"
	echo "                         Sankar Basu,  Dhananjay Bhattacharyya, and  Rahul Banerjee*"
	echo "                              Biophysical Journal, 2012, 102 (11), pp. 2605-2614"
	echo "==========================================================================================================================="
	echo "2. SARAMA: A Standalone Suite of Programs for the Complementarity Plot - A Graphical Structure Validation Tool for Proteins"
	echo "                         Sankar Basu*, Dhananjay Bhattacharyya, and Rahul Banerjee*"
	echo "                  Journal of Bioinformatics and Intelligent Control, 2013, 2 (4) pp. 321-323"
	echo "==========================================================================================================================="
	echo "3.  Applications of the complementarity plot in error detection and structure validation of proteins"
	echo "                         Sankar Basu, Dhananjay Bhattacharyya, and Rahul Banerjee*"
	echo "                    Indian Journal of Biochemistry and Biophysics, 2014, 51 (June) pp. 188-200"
	echo "==========================================================================================================================="
	goto END
        endif

#=======================================================================
#=============== Extract atoms, remove headerlines if any ==============
#=============== HETATM for metals =====================================
#=======================================================================
#=======================================================================

set commls = `head -1 fpp.status`

if ($commls == 'formp.pdb_created')then
goto runcont
else
goto clean
endif

runcont:

awk '$1=="ATOM" || $1=="HETATM"' formp.pdb > temp.pdb
./EXEC/metRrename.csh temp.pdb
mv temp.pdb $pdb

#=========================================
# REFRESH DIRECTORY (remove old files if present) 
#=========================================
rm -f alter.inp
rm -f surf_dot
rm -f surf_out
rm -f surf.pdb
rm -f check
rm -f sg.out
rm -f sg.con
rm -f icon.out
rm -f num.out
rm -f remove.out
rm -f inp.pdb
rm -f sphere.dot
rm -f bury.scrt
rm -f bury.out
rm -f sucal1.out
rm -f out.satv
rm -f dsl.out
rm -f dsl.num
rm -f *.log
rm -f *.pot
rm -f *cout.pdb
rm -f *sout.pdb
rm -f inp*
rm -f dsl.num
rm -f dsl.out
rm -f ARCDAT
rm -f core
rm -f ARCDAT
rm -f fort*
rm -f outhiscysO.pdb
rm -f outhisO.pdb
rm -f hiscysNC.pdb
rm -f msph.dot
rm -f numM.res
rm -f met.cores
rm -f fpp.status
rm -f formp.pdb
rm -f formch.out
rm -f redun.out
rm -f res1.out
rm -f temp*
rm -f target.res
rm -f res.replace
rm -f script1.prm
rm -f script2.prm
rm -f chfn.inp
rm -f sres.res
rm -f smres.res
rm -f smresE.res
#=========================================

rm -f redun.out
rm -f rdn.log

./EXEC/pdb2res.pl $pdb

set res = `echo $code`.res
#==================== output : $pdb.res goes to Em calculation =========
set length = `wc -l $res | cut -f1 -d" "`
echo 'Your pdb file contains:' $length 'residues (which must be <= 990 residues)'
	if ($length > 990)then
	echo "Your PDB file contains "$length" residues"
	echo "Program will exit"
	echo "PDB file should contain not more than 990 residues"
	exit
	endif
#==================redundant residue identities for same position==============
set redn = `cat redun.out`
	if ($redn == 'redundant')then
	echo "=================================================="
	echo 'redundant residue identities for same position(s)'
	set errorlog = LOG_`echo $code`
	rm -rf $errorlog
	mkdir $errorlog
	cat rdn.log
	mv rdn.log $errorlog/
	echo "Look into the " $errorlog/"redn.pdb file and" $errorlog/"rdn.log"
	echo ''
	rm -f redn.pdb
	cp $pdb redn.pdb
	mv redn.pdb $errorlog/
	echo 'Program will exit'
	echo ''
	echo "=================================================="
	goto clean
	endif
#================================================
# DETECT METAL COORDINATING RESIDUES
#================================================
./EXEC/mcoord.exe $pdb
set nm = `wc met.cores | cut -f1 -d' '`
	if ($nm != 0)then
	mv met.cores $code.mcores
	echo "Metal coordinating residues and the number of coordinating heavy atoms in each case:"
	cat $code.mcores
	endif

#=======================================================================
#=======================================================================
#=======================================================================
#=======================================================================
#============= Surface Complementarity calculations ====================
#=======================================================================
#=======================================================================
#=======================================================================

rm -f res1.out
./EXEC/mapresno1to1.pl $pdb > inp.pdb	# map rn1 -> 1 (for alter2m), 1st residue is written to res1.out
./EXEC/pdb2res.pl inp.pdb			# map-out: inp.res

#================ PROVISION FOR SINGLE RESIDUE ===================

	if ($sresflag == 1)then
	echo $residen > temp.res
	awk '{printf "%7s\n",$1}' temp.res > sres.res
	./EXEC/mapsres.pl
	# outfile: smres.res
	set checksingres = `cat $code.res | grep $residen`
		if ($checksingres == $residen)then
		echo '============================================'
		echo '============================================'
		echo $residen 'found in the input pdb'
		echo 'proceeding'
		echo '============================================'
		echo '============================================'
		goto CONT;
		else
			if ($sresflag == 0)then
			goto CONT;
			endif
		echo '=================================================================================='
		echo '=================================================================================='
		echo $residen 'not found in the input pdb'
		echo 'Therefore exiting'
		set errorlog = LOG_`echo $code`
		rm -rf $errorlog/
		mkdir $errorlog/
		mv $code.pdb $errorlog/
		mv $code.res $errorlog/
		echo 'Check the presence of the target residue in' $code.res 'stored at ' $errorlog
		echo '=================================================================================='
		echo '=================================================================================='
		goto clean
		endif
	endif

CONT:

#=================================================================


#==========================================================================
# SOLVENT ACCESSIBILITY (Lee & Richards)
# Ref: Lee, B., and F. M. Richards. 1971. The interpretation of protein
# structures: estimation of static accessibility. J. Mol. Biol. 55:379–400.
#==========================================================================
./EXEC/naccess.bash inp.pdb

echo    
echo '========================================================================'
echo 'SOLVENT ACCESSIBLE AREAS (ASA) CALCULATED USING PROB RADII 1.4 Angstrom'
echo '========================================================================'
echo    

#===============================================
#  BURIAL 
#===============================================
./EXEC/buryasa.exe inp.asa
./EXEC/remapbury.pl $code.res > $code.bury 	# bury.out -> $code.bury



set hydbur = `./EXEC/rGb.exe $code.bury`

echo    
echo '================================================================='
echo 'BURIAL PROFILE CALCULATED; bur(residue X): ASA(X)/ASA(Gly-X-Gly)'
echo 'You may look into :' $code.bury
echo '================================================================='
echo    

#==================== FOR EXPOSED SINGLE RESIDUES OR GLYCINES, EXIT ==================

if ($sresflag == 1)then
set chbgs = `./EXEC/chburSRES.pl $code.bury`
#echo $chbgs
	if ($chbgs == 'EXPOSEDorGLYCINE')then
	echo
	echo '================================================================='
	echo
	echo 'THE SINGLE RESIDUE ('$residen') YOU ENTERED IS EITHER SOLVENT EXPOSED (bur > 0.30) OR GLYCINE'
	echo 'Therefore exiting'
	echo 'CHECK BURIAL PROFILE OF YOUR INPUT PDB:' $code.bury 'in the directory' $errorlog 
	set errorlog = LOG_`echo $code`
	rm -rf $errorlog/
	mkdir $errorlog/
	mv $code.pdb $errorlog/
	mv $code.bury $errorlog/
	echo
	goto clean
	echo '================================================================='
	echo
	endif
endif


#==================== output : bury.out goes to Em calculation =========
./EXEC/dot1.exe
./EXEC/msph.exe
./EXEC/conn4.exe
./EXEC/remapsurf.pl $code.res > $code-surf.pdb	# surf.pdb -> $code-surf.pdb


echo    
echo '=============================================================='
echo 'Van der Waals surface sampled at 10 dots/Angstrom^2'
echo 'You may look into :' $code-surf.pdb
echo '=============================================================='
echo    

#==================== output : surf.pdb goes to Em calculation =========
./EXEC/alter2m.exe

echo    
echo '========================================================================================'
echo 'Format alteration (Atoms to Residues) performed for Surface Complementarity calculations'
echo '========================================================================================'
echo    


echo    
echo '====================================================================='
echo 'NOW CALCULATING SURFACE COMPLEMENTARITIES OF ALL NON-GLYCINE TARGET RESIDUES'
echo 'Sm(all) : sidechain(target) vs all nearest neighboring dot points'
echo 'Sm(sc)  : sidechain(target) vs nearest neighboring dot points coming from sidechain'
echo 'Sm(mc)  : sidechain(target) vs nearest neighboring dot points coming from mainchain'
echo '====================================================================='
echo    

echo
echo "==================================================================="
echo "THIS MAY TAKE A WHILE"
echo "You may check the progress by viewing (cat) the out.satv file"
echo "with Residue numbers temporarily remapped starting from 1"
echo "==================================================================="
echo

./EXEC/pdb2resWM.pl $pdb
# output: numM.res
	if ($sresflag == 0)then
	./EXEC/runsatv.pl inp.res
	else if ($sresflag == 1)then
	./EXEC/runsatv.pl smres.res
	endif
./EXEC/remapSm.pl $code.res > $code.Sm               # out.satv -> $code.Sm

echo    
echo '========================================================================================'
echo 'Surface Complementarity calculations completed'
echo 'You may look into :' $code.Sm
echo 'OUTPUT FORMAT: col1: residue, col2: burial, col3: Sm(all), col4: Sm(sc), col5: Sm(mc)'
echo '========================================================================================'
echo    

#=======================================================================
#=======================================================================
#=======================================================================
#============= Electrostatic Complementarity calculations ==============
#=======================================================================
#=======================================================================
#=======================================================================

# Electrostatic complementarity of all buried / partially buried residues of a protein
# all atoms (residue) vs all atoms (rest of the protein) and then split into mainchain/sidechain surface points


set dir = dir`echo $code`
echo $dir

rm -rf $dir/		# if pre-existing

mkdir $dir/
echo $status			# should return zero if directory created successfully
echo $?				# should return zero if directory created successfully

echo '   '
echo '==================================================================='
echo 'TEMP directory' $dir 'created'
echo '==================================================================='
echo '   '

./EXEC/glbN.exe $pdb $code.bury			# INDEX OF GLOBULARITY / ASSYMETRY
mv fort.3 $code.glbl
set gindex = `head -1 $code.glbl | cut -c1-8`
echo $gindex

echo '   '
echo '=============================================================================='
echo 'Index of globularity (rms deviation of atoms from protein-centroid) :' $gindex
echo '=============================================================================='
echo '   '

# calculate disulphide bridges prior to surface generation
# store dsl.out
# precompiled executable (dsl)
# source: dsl.f

echo '   '
echo '================================================'
echo 'Disulphide bridges recognized and remembered :' 
echo '================================================'
echo '   '

rm -f dsl.out
rm -f dsl.num
./EXEC/dsl.exe $pdb
mv dsl.out $code.dsl	

# Split surfaces into residue patches and the complementary patches (rest of the whole protein)
# precompiled executable : spl
# source code: splitsurf.f
# large output (*s.pdb) 

echo '   '
echo '========================================================================================'
echo 'Spliting the surface file : extracting dot-points for individual non-glycine target residues' 
echo '========================================================================================'
echo '   '

	if ($sresflag == 0)then
	./EXEC/spl.exe $code-surf.pdb $code.res
	else if ($sresflag == 1)then
	./EXEC/spl.exe $code-surf.pdb sres.res
	endif	

# Store these surface (*s.pdb) files in a separate directory named after the pdb code
# rename res type in the surface files as dummy so that the atoms are not assigned charges by delphi
# during iteration (Overruled : for total energy calculation : E = sum(q(i)*phi(i)) (in kT)
# Surface point on the vdW surface of atom X will be assigned the partial charge of atom X

mv *s.pdb $dir/
mv $dir/$code.pdb .

echo '   '
echo '================================================='
echo 'Individual residue-surface files stored at' $dir
echo '================================================='
echo '   '


# Modify the pdb file to make compatable with DelPhi
# 1. HIS -> HID/HIE/HIP
# 2. CYS (in disulphide bridges) -> CYX
# 3. blank col. 13 i.e., blank before 3 letter atom codes
# 4. Rename N'terminal & C'terminal residues

echo '   '
echo '==========================================================================='
echo 'RENAMING RESIDUES ACCORDING TO AMBER FORCEFIELD PARAMETERS       '
echo 'You may Look in amber.crg (partial charge) and amber_dummy.siz (vdw radii)'
echo 'Renaming CYS (in disulphide bridges) -> CYX'
echo 'Renaming HIS -> HID/HIE/HIP according to Hydrogens assigned in the pdb file'
echo 'Renaming N-terminal & C-terminal residues'
echo '==========================================================================='
echo '   '

cp $code.dsl inp.dsl
./EXEC/his2hidep.pl $pdb # internally calls cys2cyxs.pl
./EXEC/ntrename.pl 
cp hiscysNC.pdb $code-m.pdb

# Create pdb files of residue patches (all atoms) filled with dummy for the rest of the protein
# Also create the complementary pdb file (the candidate residue being filled up with dummy
# Dummy refers to assigned for vdW radii but unassigned for partial charges
# so that the dielectric boundary is characterized properly but the dummy atoms don't contribute to the electric field

echo ''
echo '==========================================================================================================='
echo 'Generating coordinate files with dummy atoms (assigned only radii with zero charge) to create delphi inputs'
echo 'Details of dummy atom-name listed in amber_dummy.siz and amber.siz'
echo 'Electrostatic Potentials will be calculated twice:' 
echo '1. Due to Electric fields generated by the atoms of a selected target residue'
echo '2. Due to Electric fields generated by the atoms of the rest of the chain excluding the selected target residue'
echo 'For both cases, the atoms not contributing to the potential will be treated as dummy atoms'
echo '==========================================================================================================='
echo ''


./EXEC/pdb2resWM.pl $code-m.pdb
cp $code-m.pdb inp-m.pdb
	if ($sresflag == 0)then
	./EXEC/genfieldpdb.pl $code-m.res
	else if ($sresflag == 1)then
	./EXEC/picktar4Em.pl $code-m.res
	./EXEC/genfieldpdbSRES.pl $code-m.res
	endif
mv *sf.pdb $dir/
mv *cf.pdb $dir/
mv $dir/$code.pdb .

echo ''
echo '================================================================================'
echo 'All delphi input coordinate files (padded with dummy atoms) are stored at:' $dir
echo '================================================================================'
echo ''


echo ''
echo '========================================================================='
echo 'delphi95 running: Calculating linearized Poison-Boltzmaan Potentials'
echo 'internal dielectric : 2, external dielectric: 80'
echo 'For other parameters look into script_default.prm'
echo 'To change any parameters modify the appropreate fields in generateprm.pl'
echo 'NOW CALCULATING ELECTROSTATIC COMPLEMENTARITIES OF ALL NON-GLYCINE TARGET RESIDUES'
echo 'Em(all) : from all dot points of the selected target-residue'
echo 'Em(sc)  : from sidechain dot points of the target alone'
echo 'Em(mc)  : from mainchain dot points of the target alone'
echo '========================================================================='
echo ''

echo
echo "==================================================================="
echo "THIS MAY TAKE A WHILE"
echo "You may check the progress by viewing (cat) the ccp.out file"
echo "with residue types temporarily converted to run delphi"
echo "You may find 'NaN' values for exposed or terminal residues which will be taken care off later"
echo "==================================================================="
echo
	if ($sresflag == 0)then
	./EXEC/rungenprm.pl $code-m.res  $dir $gindex # internally creates script*.prm (by calling generateprm.pl) and runs delphi
	else if ($sresflag == 1)then
	./EXEC/rungenprm.pl smresE.res  $dir $gindex
	endif

# also internally calls (corrcoefPspl.f -> ./ccps) to compute Preason cross correlation
# Main outfile : ccp.out

echo ''
echo '===================='
echo 'CLEANING WORKSPACE'
echo '===================='
echo ''

rm -f *.log
rm -f *.pot
rm -f *cout.pdb
rm -f *sout.pdb
mv *.pot $dir/
mv $dir/$pdb .
rm -rf $dir/
rm -f inp*
rm -f dsl.num
rm -f dsl.out
rm -f ARCDAT


echo ''
echo '=========================================='
echo 'Renaming residues to their original names'
echo '=========================================='
echo ''

./EXEC/renameRT.csh ccp.out
./EXEC/rmgly.pl ccp.out > temp
mv temp ccp.out

mv ccp.out $code.Em

echo ''
echo '==============================================='
echo 'Distributing residues according to their burial'
echo 'bin1: 0.0 <= burial <= 0.05'
echo 'bin2: 0.05 < burial <= 0.15'
echo 'bin3: 0.15 < burial <= 0.30'
echo '==============================================='
echo ''

rm -f fort.512
rm -f fort.513
rm -f fort.514
rm -f fort.515

./EXEC/bdist.exe $code.Sm $code.Em
set cmp1 = `ls fort.512`

	if (`echo $cmp1` == 'fort.512' && $status == 0)then
	mv fort.512 $code.CSplot
	else
	echo '====================================================================='
	echo 'fort.512 not generated : i.e., No buried or partially buried residues'
	echo '====================================================================='
	endif

	if ($sresflag == 1)then
	cat $code.CSplot
	endif

set cb1 = `ls fort.513`
set pb1 = `ls fort.514`
set pe1 = `ls fort.515`

rm -f lod.inp

set fcb2 = 0
set fpb2 = 0
set fpe2 = 0

	if (`echo $cb1` == 'fort.513')then
	mv fort.513 $code.cb
	cp $code.cb inpp.cb
	./EXEC/cmp.exe inpp.cb
	mv fort.167 $code-comp.cb
	./EXEC/tlod.pl
	./EXEC/treal.exe $code.cb 
	mv fort.9 $code.rcb
	set fcb2 = 1
	./EXEC/conv2.pl cb.inc cb.outc cb.trsq $code.rcb > $code-cb.ps
	else
	echo '====================================================================='
	echo 'fort.513 not generated : i.e., No residues falling in burial bin: 1'
	echo '====================================================================='
	endif

	if (`echo $pb1` == 'fort.514')then
	mv fort.514 $code.pb
	cp $code.pb inpp.pb
	./EXEC/cmp.exe inpp.pb
	mv fort.167 $code-comp.pb
	./EXEC/tlod.pl
	./EXEC/treal.exe $code.pb
	mv fort.9 $code.rpb
	set fpb2 = 1
	./EXEC/conv2.pl pb.inc pb.outc pb.trsq $code.rpb > $code-pb.ps
	else
	echo '====================================================================='
	echo 'fort.514 not generated : i.e., No residues falling in burial bin: 2'
	echo '====================================================================='
	endif

	if (`echo $pe1` == 'fort.515')then
	mv fort.515 $code.pe
	cp $code.pe inpp.pe
	./EXEC/cmp.exe inpp.pe
	mv fort.167 $code-comp.pe
	./EXEC/tlod.pl
	./EXEC/treal.exe $code.pe
	mv fort.9 $code.rpe
	set fpe2 = 1
	./EXEC/conv2.pl pe.inc pe.outc pe.trsq $code.rpe > $code-pe.ps
	else
	echo '====================================================================='
	echo 'fort.515 not generated : i.e., No residues falling in burial bin: 3'
	echo '====================================================================='
	endif

#echo "============internal burial status================="

#echo "burial bin 1:" $fcb2
#echo "burial bin 2:" $fpb2
#echo "burial bin 3:" $fpe2

#echo "==================================================="


rm -f bury.out
rm -f icon.out
rm -f num.out
rm -f remove.out
rm -f sg.out
rm -f sucal1.out


set outdir = OUT`echo $code`
echo 'Creating OUTPUT Directory : ' $outdir/
echo 'Find all relevant outfiles along with the input pdb stored in ' $outdir/
rm -rf $outdir			# if pre-existing
mkdir $outdir

	if ($fcb2 == 0 && $fpb2 == 0 && $fpe2 == 0)then
	echo '=========================================================================='
	echo
	echo 'ALL RESIDUES ARE SOLVENT EXPOSED (burial > 0.30) IN THE INPUT PDB:' $pdb
	echo 'Only the Accessibility score will be calculated'
	echo 'rGb = ' $hydbur
	echo "CS_l: N/A", "rGb:" $hydbur, "Pcount: N/A" > $code.CS
	echo
	echo '=========================================================================='
	goto refresh
	endif
	


echo "OUTPUTS"
echo "======="

echo "MAIN OUTPUTS: Sm:" $code.Sm "Em:" $code.Em

echo "PLOT INPUTS:" $code.CSplot 
echo "(Sm,Em) as a function of burial:" 
echo "Completely buried, burial <= 0.05:" $code.SEcb
echo "Partially buried, 0.05 < burial <= 0.15:" $code.SEpb
echo "Partially exposed, 0.15 < burial <= 0.30:" $code.SEpe

echo ' '
echo '========================================================================'
echo 'STATUS OF THE BURIED / PARTIALLY BURUIED RESIDUES IN THE COMPLEMENTARITY PLOTS'
echo '========================================================================'
echo ' '

	if ($fcb2 == 1)then
	echo '======================='
	echo '0.0 <= burial <= 0.05'
	echo '======================='	
	cat $code-comp.cb
	echo '======================='	
	gv $code-cb.ps
	#==================================================================================================
	#==================================================================================================
	#====================== GENERATE RASMOL SCRIPT TO VIEW THE INTERIOR VDW SURFACE ===================
	#====================== INTERIOR RESIDUES ARE CONSIDERED TO BE COMPLETELY BURIED (bur <= 0.05) ====
	#====================== FALLING IN CP1 ============================================================
	#==================================================================================================
	#==================================================================================================
	./EXEC/RASMOLinterior.pl $code-surf.pdb $code-comp.cb 
	rasmol -script ras.spt &
	cp ras.spt $code-rasint.spt
	#==================================================================================================
	#==================================================================================================
	#==================================================================================================
	endif

	if ($fpb2 == 1)then
	echo '======================='
	echo '0.05 <= burial <= 0.15'
	echo '======================='
	cat $code-comp.pb
	echo '======================='	
	gv $code-pb.ps
	endif

	if ($fpe2 == 1)then
	echo '======================='
	echo '0.15 <= burial <= 0.30'
	echo '======================='
	cat $code-comp.pe
	echo '======================='	
	gv $code-pe.ps
	endif

	cat $code-comp.* > $code.cnt
	set count = `./EXEC/fracimp.pl $code.cnt`

	if ($sresflag == 0)then
	echo "======================="
	./EXEC/tlod2.exe > $code.lodd   # input : lod.inp
	./EXEC/calpack.pl $code.Sm > $code.pack
	./EXEC/calelectro.pl $code.Em > $code.elect
	set CSlod = `cat $code.lodd`
	set Psm = `cat $code.pack`
	set Pem = `cat $code.elect`
	echo
	echo
	echo "Complementarity Scores for the full chain:"
	echo "CS_l:" $CSlod
	echo "Accessibility Score: rGb:" $hydbur
	echo "Percentage Count of residues in the improbable region:" $count
	echo "========================================================"
	echo "========================================================"
	echo "Average Scores for correctly folded native proteins (DB2):"
	echo "           Standard deviations in parentheses"
	echo "CS_l: 2.24 (+-0.48), rGb: 0.055 (+-0.022)"
	echo "Psm:  -0.855 (+-0.054), Pem: -1.492 (+-0.099)"
	echo "========================================================"
	echo "Thresold values for CS_l: 0.80, rGb: 0.011"
	echo "Count of residues in the Improbable region should be less than 15.0%"
	echo "Structures registering less than threshold values "
	echo "in any of the two (global) scores (CSl, rGb)"
        echo "or the local count (Pcount) needs re-investigation !"
	echo "========================================================"
	echo "========================================================"
	echo "CS_l:" $CSlod, "rGb:" $hydbur, "Pcount: " $count, "Psm: " $Psm, "Pem: " $Pem > $code.CS
	echo "Psm: " $Psm "(should be above -1.017)" 
	echo "Pem: " $Pem "(should be above -1.789)"
	echo
	echo
	echo "======================="
	goto refresh
	endif

refresh:

cp README.output $outdir/
mv $pdb $outdir/
mv $code.res $outdir/
mv $code.mcores $outdir/
mv $code.bury $outdir/
mv $code-surf.pdb $outdir/
mv $code.Sm $outdir/
mv $code.Em $outdir/
mv $code-comp.cb $outdir/
mv $code-comp.pb $outdir/
mv $code-comp.pe $outdir/
mv $code.CSplot $outdir/
mv $code-cb.ps $outdir/
mv $code-pb.ps $outdir/
mv $code-pe.ps $outdir/
mv $code.CS $outdir/
mv $code.pack $outdir/
mv $code.elect $outdir/
mv $code.cnt $outdir/
mv $code-rasint.spt $outdir/

#=================================
# REFRESH
#=================================

clean:

echo
echo
echo "===================================================="
echo "CLEANING WORKSPACE"
echo "===================================================="
echo
echo


#./clean.csh  #  ALSO REMOVE LIBRARY FILES FROM CURRENT DIRECTORY
./refresh.csh  #  DOES NOT REMOVE LIBRARY FILES FROM CURRENT DIRECTORY
#echo CLEANED
echo REFRESHED

rm -f core
rm -f ARCDAT
rm -f fort*
rm -f outhiscysO.pdb
rm -f outhisO.pdb
rm -f hiscysNC.pdb
rm -f inpp*
rm -f lod.inp

ls $code* > dump
	if ($status == 0)then
	rm -f $code*
	endif
rm -f dump

#=================================

echo "==========================================================================================================================="
echo "Users reporting results using this software, should cite the following articles: (Preferably 1 & 3) "
echo "==========================================================================================================================="
echo "1.        Self-Complementarity within Proteins: Bridging the Gap between Binding and Folding"
echo "                         Sankar Basu,  Dhananjay Bhattacharyya, and  Rahul Banerjee*"
echo "                              Biophysical Journal, 2012, 102 (11), pp. 2605-2614"
echo "==========================================================================================================================="
echo "2. SARAMA: A Standalone Suite of Programs for the Complementarity Plot - A Graphical Structure Validation Tool for Proteins"
echo "                         Sankar Basu*, Dhananjay Bhattacharyya, and Rahul Banerjee*"
echo "                  Journal of Bioinformatics and Intelligent Control, 2013, 2 (4) pp. 321-323"
echo "==========================================================================================================================="
echo "3.  Applications of the complementarity plot in error detection and structure validation of proteins"
echo "                         Sankar Basu, Dhananjay Bhattacharyya, and Rahul Banerjee*"
echo "                    Indian Journal of Biochemistry and Biophysics, 2014, 51 (June) pp. 188-200"
echo "==========================================================================================================================="

cat README.output

END:

#========================================== END OF SCRIPT ===========================================
