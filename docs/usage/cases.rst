Use Cases
#########

With only complete genomes
===========================
-  Download complete genomes (with extension .fasta, .fna) into a folder. For example *ref*
   
   .. code-block:: console
   
       mkdir -p ref 

-  Create a control file. Specify path to *ref* in *refdir* option.
	sHere is a typical control file setup for running PhaME with only complete genomes. The most important option here is *data = 0*, which specifies that the dataset only consist of complete genomes and those are in *ref* folder.
   
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


Save the above file in the same directory where *ref* is, for example as *complete_phame.ctl*

- To run the PhaME using specified control file, one can do
  
  .. code-block:: console
  
		$ phame complete_phame.ctl


With complete genomes and contigs
==================================
-  Download complete genomes (with extension .fasta, .fna) into a folder *ref*. Download incomplete genomes or contigs into a folder *workdir*. If the contigs file do not have the extension *.contig*, then rename all the files to have this extension. One can quickly change the extension using `rename fa contig *.fa`.
   
   .. code-block:: console
   
       $ mkdir -p ref
       $ mkdir -p workdirs
       $ cd workdirs
       $ rename fna contig *.fna

-  Create a control file. Specify path to *ref* in *refdir* option and path to *workdirs* in *workdir* option.
	Here is a typical control file setup for running PhaME with complete genomes and contigs. The most important option here is *data = 3*, which specifies that the dataset consist of complete genomes and contigs.

::

	   refdir = ref  # directory where reference (Complete) files are located
	  workdir = workdirs # directory where contigs/reads files are located and output is stored

	reference = 2  # 0:pick a random reference from refdir; 1:use given reference; 2: use ANI based reference
	  reffile = KJ660347.fasta  # reference filename when option 1 is chosen

	  project = only_ref  # main alignment file name

	  cdsSNPS = 1  # 0:no cds SNPS; 1:cds SNPs, divides SNPs into coding and non-coding sequences, gff file is required

	  buildSNPdb = 0 # 0: only align to reference 1: build SNP database of all complete genomes from refdir

	FirstTime = 1  # 1:yes; 2:update existing SNP alignment, only works when buildSNPdb is used first time to build DB

		 data = 3  # *See below 0:only complete(F); 1:only contig(C); 2:only reads(R); 
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


Save the above control file in the same directory where *ref* is, for example as *contig_and_complete_phame.ctl*

- To run the PhaME using specified control file, one can do
  
  .. code-block:: console
  
    	$ phame contig_and_complete_phame.ctl


With raw reads, complete genomes, and contigs
=============================================

-  Download complete genomes (with extension .fasta, .fna) into a folder *ref*. Download incomplete genomes or contigs into a folder *workdir*. And, download fastq files in *workdirs* as well. If the contigs file do not have the extension *.contig*, then rename all the files to have this extension. Paired fastq files must have R1.fastq and R2.fastq as suffixes in their filename.
   
   .. code-block:: console
   
       $ mkdir -p ref
       $ mkdir -p workdirs
       $ cd workdirs
       $ rename fna contig *.fna

-  Create a control file. Specify path to *ref* in *refdir* option and path to *workdirs* in *workdir* option.
	Here is a typical control file setup for running PhaME with complete genomes and contigs. The most important option here is *data = 6*, which specifies that the dataset consist of complete genomes and contigs.

::

	   refdir = ref  # directory where reference (Complete) files are located
	  workdir = workdirs # directory where contigs/reads files are located and output is stored

	reference = 2  # 0:pick a random reference from refdir; 1:use given reference; 2: use ANI based reference
	  reffile = KJ660347.fasta  # reference filename when option 1 is chosen

	  project = only_ref  # main alignment file name

	  cdsSNPS = 1  # 0:no cds SNPS; 1:cds SNPs, divides SNPs into coding and non-coding sequences, gff file is required

	  buildSNPdb = 0 # 0: only align to reference 1: build SNP database of all complete genomes from refdir

	FirstTime = 1  # 1:yes; 2:update existing SNP alignment, only works when buildSNPdb is used first time to build DB

		 data = 6  # *See below 0:only complete(F); 1:only contig(C); 2:only reads(R); 
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


Save the above control file in the same directory where *ref* is, for example as *read_contig_and_complete_phame.ctl*

- To run the PhaME using specified control file, one can do
  
  .. code-block:: console
  
    	$ phame read_contig_and_complete_phame.ctl



Zoom-in analysis
================

PhaME has a unique feature that allows subsetting genomes from a PhaME analysis. 

1. One can select genomes of interest by creating a copy of *working_list.txt*, a text file generated during the first run that contains list of all genomes then deleting lines containing names of genomes that are not of interest. For example, 

.. code-block:: console

    $ cat working_list.txt
    SRR1610032_pread
	SRR1610033_pread
	GCF_000703365_1_Ec2011C_3609_genomic
	SRR1609871_pread
	SRR1609862_pread
	SRR160986_pread
	SRR1610031_pread
	SRR1610034_pread
	SRR1610028_pread
	SRR1610029_pread

2. Remove lines with genomes that are not of interest.

.. code-block:: console

        $ cat working_list.txt
    SRR1610032_pread
	SRR1610033_pread
	GCF_000703365_1_Ec2011C_3609_genomic
	SRR1609871_pread

3. Change the *data* option in control file to *data = 7*, maybe also change the `project` name, and save as zoom_in.ctl
   
4. Then rerun the PhaME as

.. code-block:: console

    $ phame zoom_in.ctl