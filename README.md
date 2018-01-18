## Phylogenetic and Molecular Evolution (PhaME) analysis tool

[![Build Status](https://travis-ci.org/mshakya/PhaME-1.svg?branch=master)](https://travis-ci.org/mshakya/PhaME-1)

Given a reference, PhaME extracts SNPs from complete genomes, draft genomes and/or reads. 
Uses SNP multiple sequence alignment to construct a phylogenetic tree. 
Provides evolutionary analyses (genes under positive selection) using CDS SNPs.


--------------------------------------------------------------
## Version
1.0

--------------------------------------------------------------
## SYSTEM REQUIREMENTS

* Perl version > 5.16

* MUMmer version 3.23 - Pairwise alignment using NUCmer 

* Bowtie2 version >=2.2.8 - Mapping of reads

* SAMtools version 1.3.1 and vcftools - Convert BAM files created by Bowtie

* FastTree version >=2.1.9 - Construction of phylogenetic tree

* RAxML version >=8.2.9 - Maximum likelihood construction of phylogenetic tree

* mafft version >=7.305 - For optional evolutionary analyses

* pal2nal version >=14 - For optional evolutionary analyses

* paml version >=4.8 - For optional evolutionary analyses

* HyPhy version >=2.2 - For optional evolutionary analyses

* bwa VER >= 0.7.15

* cmake VER >= 3.0.1

* bcftools VER >= 1.6

* samtools VER >= 1.6

--------------------------------------------------------------
## PERL PACKAGES

* File::Basename = 2.85
* File::Path = 2.09
* Getopt::Long = 2.45
* IO::Handle = 1.28
* Parllel::ForkManager = 1.17
* Statistics::Distributions = 1.02
* Time::BaseName = 2.85
* Time::HiRes = 1.9726

The C/C++ compiling enviroNment might be required for installing dependencies. Systems may vary. Please assure that your system has the essential software building packages (e.g. build-essential for Ubuntu, XCODE for Mac...etc) installed properly before running the installing script.

--------------------------------------------------------------
### Obtaining PhaME

You can use "git" to obtain the package:

    $ git clone https://github.com/mshakya/PhaME-1.git

### Installing PhaME

    $ cd PhaME
    $ ./INSTALL.sh
    
--------------------------------------------------------------
### Running PhaME

#### Input files

Please avoid filenames that have multiple `.`.

* A directory with reference files (complete genomes) which have the following file suffixes
  - *.fasta
  - *.fna
  - *.fa
  - *.gff  (optional: to analyze Coding region SNPs of a selected reference file)
    
* A working directory 
  - Contig files with the following file suffixes
     - *.contig
     - *.contigs
     
  - Reads files with the following file suffixes
     - *_R1.fastq *_R2.fastq
     - *_R1.fq *_R2.fq
     
  - A control file (e.g. [phame.ctl](https://raw.githubusercontent.com/mshakya/PhaME-1/master/test/phame.ctl))

#### Test run

* BEFORE RUNNING TEST: Please modify the values of `refdir` and `workdir` in the `test/phame.ctl` file to corresponding **absolute path**.

* From the PhaME directory 

```
    src/runPhaME.pl test/phame.ctl

```
--------------------------------------------------------------
#### OUTPUT files

* Summary files
  - SNP alignment files
    - all detected SNPs
      - `project`_all_snp_alignment.fna
    - SNPs in CDS (coding sequence)
      - `project`_cds_snp_alignment.fna* 
    - intergenic SNPs
      - `project`_int_snp_alignment.fna*

          *only when a gff file is given

  - Newick tree file
    - RAxML tree using all SNPs
      - bootstrap mapped Maximum Likelihood trees
        - RAxML_bipartitionsBranchLabels.`project`_all_best
        - RAxML_bipartitions.`project`_all_best 
      - bootstraps
        - RAxML_bootstrap.`project`_all_b
      - best ML tree
        - RAxML_bestTree.`project`_all
    - RAxML tree using only CDS SNPs
      - best ML tree
        - RAxML_bestTree.`project`_all
    - FastTree using all SNPs
      - `project`_all.fasttree
    - FastTree using SNPs from coding sequence
      - `project`_cds.fasttree
  - Text file containing:
    - the size of gaps between `reference` and other genomes.
      - `project`_all_gaps.txt
    - A tab delimited summary file containing information on the core genome size, total SNPs, etc.
      - `project`_summaryStatistics.txt 
        - Most rows are genome name (first column), attribute name (second column), and corresponding value (third column)
          - `Total_length` for genome size (total base pair) of the corresponding genome (first column)
          - `Gap_legnth` for total gaps in the corresponding genome (first column)
        - One row labeled `REPEAT` (first column) and `Gap_length`(second column) actually correspond to repeat size (third column) of reference genome.
        - `Reference used` shows the name of the reference genome used.
        - `Total gap length:` shows the length of total gaps in the alignment.
        - `Core genome length:` shows the length of genomes that were aligned.
        - `Total SNPs:` shows the length of SNPs.
        - `CDS SNPs:` shows the subset of SNPs from Total SNPs that fall within coding regions.
    - the average genome size
    - number of whole genome SNPs
    - and coding region SNPs
  - A pairwise list of all compared position with coordinates between references and samples
    - `project`_comparison.txt
    - `project`_stats.txt (also contains if SNPs are in coding or non-coding regions)
  - A matrix file that lists the number of SNPs present between genomes
    - all core regions
      - `project`_snp_coreMatrix.txt
    - CDS only
      - `project`_snp_CDSmatrix.txt
    - intergenic only
      - `project`_snp_intergenicMatrix.txt
* Log file
  - `project`_PhaME.log
* Error file
  - `project`.error 

* Directories structure
  - `working directory`/files
      - permuted versions of references (concatenated chromosomes)
  - `working directory`/results
      - All output files
  - `working directory`/results/snps
      - SNP coordinate files generated from NUCmer and bowtie
  - `working directory`/results/gaps
      - Gap coordinate files generated from NUCmer and bowtie
  - `working directory`/results/stats
      - Intermediate stat files generated when parsing NUCmer and Bowtie results
  - `working directory`/results/temp
      - Temporary files generated
  - `working directory`/results/PSgenes
      - All gene fasta files  that contain at least 1 SNP
  - `working directory`/results/paml
      - PAML results
  - `working directory`/results/hyphy
      - HyPhy results


## Parameters

### reference
`reference = 1  # 0:pick a random reference; 1:use given reference; 2: use ANI based reference`
  0, picks a random genome to be reference from the reference folder.
  1, user specified reference
  2, uses the genome that has the best ANI among all genomes. Calculated using mash implementation in bbmap.


### code
`code = 1  # 0:Bacteria; 1:Virus`

`Virus` sets option for nucmer alignment that is not default.

`Bacteria` aligns using default option with `maxmatch` for nucmer.


### cutoff

`cutoff = `X

Option to remove genomes that aligned with less than X proportion (0-1) of the reference genome. 

--------------------------------------------------------------
## CITATION

From raw reads to trees: Whole genome SNP phylogenetics across the tree of life.

Sanaa Afroz Ahmed, Chien-Chi Lo, Po-E Li, Karen W Davenport, Patrick S.G. Chain

bioRxiv doi: http://dx.doi.org/10.1101/032250

--------------------------------------------------------------
## Contact

[Migun Shakya](mailto:migun@lanl.gov)

--------------------------------------------------------------
## ACKNOWLEDGEMENTS
This project is funded by U.S. Defense Threat Reduction Agency [R-00059-12-0 and R-00332-13-0 to P.S.G.C.].

--------------------------------------------------------------
## Copyright

Los Alamos National Security, LLC (LANS) owns the copyright to PhaME, which it identifies internally as LA-CC-xx-xxxx.  The license is GPLv3.  See [LICENSE](https://github.com/losalamos/PhaME/blob/master/LICENSE) for the full text.

