Use Cases
#########

Running PhaME with only complete genomes
========================================
-  Download complete genomes (with extension .fasta, .fna) into a folder. For example *ref*
   
   .. code-block:: console
   
       mkdir -p ref 

-  Create a control file. Specify path to *ref* in *refdir* option.

-  Here is a typical control file setup for running PhaME with only complete genomes. The most important option here is *data = 0*, which specifies that the dataset only consist of complete genomes and those are in *ref* folder.
   
   ::

	   refdir = ref  # directory where reference (Complete) files are located
	  workdir = workdirs # directory where contigs/reads files are located and output is stored

	reference = 2  # 0:pick a random reference from refdir; 1:use given reference; 2: use ANI based reference
	  reffile = KJ660347.fasta  # reference filename when option 1 is chosen

	  project = only_ref  # main alignment file name

	  cdsSNPS = 1  # 0:no cds SNPS; 1:cds SNPs, divides SNPs into coding and non-coding sequences, gff file is required

	  buildSNPdb = 0 # 0: only align to reference 1: build SNP database of all complete genomes from refdir

	FirstTime = 1  # 1:yes; 2:update existing SNP alignment, only works when buildSNPdb is used first time to build DB

		 data = 0  # *See below 0:only complete(F); 1:only contig(C); 2:only reads(R); 
				   # 3:combination F+C; 4:combination F+R; 5:combination C+R; 
				   # 6:combination F+C+R; 7:realignment  *See below 
		reads = 2  # 1: single reads; 2: paired reads; 3: both types present;

		 tree = 1  # 0:no tree; 1:use FastTree; 2:use RAxML; 3:use both;
	bootstrap = 0  # 0:no; 1:yes;  # Run bootstrapping  *See below
			N = 100  # Number of bootstraps to run *See below    
  
	PosSelect = 0  # 0:No; 1:use PAML; 2:use HyPhy; 3:use both # these analysis need gff file to parse genomes to genes

		 code = 0  # 0:Bacteria; 1:Virus; 2: Eukarya # Bacteria and Virus sets ploidy to haploid

		clean = 0  # 0:no clean; 1:clean # remove intermediate and temp files after analysis is complete

	  threads = 2  # Number of threads to use

	   cutoff = 0.1  # Linear alignment (LA) coverage against reference - ignores SNPs from organism that have lower cutoff.


Save the above file, for example as *complete_phame.ctl*

- To run the PhaME using specified control file, one can do
  
  .. code-block:: console
  
    	runPhaME complete_phame.ctl


Running PhaME with complete genomes and contigs
================================================



Running PhaME with raw reads, complete genomes, and contigs
============================================================



Running PhaME with Molecular Evolutionary Analysis
==================================================

