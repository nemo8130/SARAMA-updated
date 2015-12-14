#!/bin/csh -f

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
rm -f inp.saa*
rm -f sphere.dot 
rm -f bury.scrt
rm -f bury.out
rm -f saa.out
rm -f sucal1.out
rm -f out.satv
rm -f ccp.out
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

#echo
#echo "================================================="
#echo "CLEARING LIBRARY FILES FROM THE CURRENT DIRECTORY"
#echo "================================================="
#echo

#foreach i (`cat LIBR/librf.list`)
#ls $i > dump
#	if ($? == 0 && $status == 0)then
#	rm -f $i
#	endif
#end

#rm -f EXEC/*
#rm -f dump

#echo
#echo
#echo "================================================================="
#echo "ENSURE TO RUN install.csh PRIOR TO THE NEXT RUN OF surfNelcomp.csh"
#echo "================================================================="
#echo
#echo


