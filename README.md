# SARAMA

A standalone suite of programs to plot the distribution of residues embedded at a globular protein interior in the Complementarity Plots [CPs] (for Linux)

# &
# SARAMAint

The same for residues buried upon complexation embedded at a Protein-Protein Interface (Linux)

Requires PERL (v.5.8 or higher), and a fortran90 compiler (prefered: ifort)
and two additional packages to be pre-installed

1. delphi v.6.2 (http://compbio.clemson.edu/delphi/) [executable_name: delphi95]
3. EDTSurf (http://zhanglab.ccmb.med.umich.edu/EDTSurf/) [executable_name: EDTSurf]

### Installation

```sh
$ git clone https://github.com/nemo8130/SARAMA-updated
$ cd SARAMA
$ chmod +x install
$ ./install <fortran90-compiler>  (Default: ifort)
```

## The program has just one mandetory input :

        1. The coordinate (PDB) file for the model

## The other optional input is a specification of a target residue (executes the program on a single residue alone)

        2. -tar NNN-XXX   (e.g., 100-TYR, 67-PHE etc.)

- The specified target residue must map consistant to the residue sequence number of the input PDB file. 
- PDB file MUST contain corrdinates of geometrically fixed Hydrogen atoms 
- preferably fixed by REDUCE v.2 or atleast compatible with the REDUCE format 
  (http://kinemage.biochem.duke.edu/downloads/software/reduce/)


##### Preparatory Step: 

Add Hydrogen atoms

You can generate the fasta sequence by using:
```sh
$ reduce -trim inp.pdb > input.pdb 
$ reduce -build -DB ~/lib/reduce_het_dict.txt <input.pdb> | awk '$1=="ATOM" || $1=="HETATM"'  >  inputH.pdb
```

##### Run Step: 
```sh
$ ./CompPlot -inp <inputH.PDB> 
$ ./CompPlot -inp <inputH.pdb> -tar <45-THR>
```
where,
- inputH.pdb: The input pdb (coordinate file in Brrokheaven format; http://www.ccp4.ac.uk/html/procheck_man/manappb.html) file

> EXAMPLE OUTPUT: 
```sh 
$ cat OUT1psr/1psr.CS
```
> 
          CS_l: 1.53895, rGb: 0.06081, Pcount:  8.333, Psm:  -0.844, Pem:  -1.288
> 

For Detail output features: see: SARAMA/README.output

> Example Output for a single PDB file: 

** In Correct Models 

### Reference

      Self-Complementarity within Proteins: Bridging the Gap between Binding and Folding
      Sankar Basu, Dhananjay Bhattacharyya, and Rahul Banerjee*
      Biophysical Journal, 2012, 102 (11) : 2605-2614 
      doi:  http://dx.doi.org/10.1016/j.bpj.2012.04.029

The article is avialable online here: http://www.cell.com/biophysj/abstract/S0006-3495%2812%2900503-6









