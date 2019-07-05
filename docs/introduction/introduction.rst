Introduction
#############

What is PhaME?
==============

PhaME or Phylogenetic and Molecular Evolution (PhaME) analysis tool allows suite of analysis pertaining to phylogeny and moleuclar evolution.

Given a reference, PhaME extracts SNPs from complete genomes, draft genomes and/or reads, uses SNP multiple sequence alignment to construct a phylogenetic tree, and provides evolutionary analyses (genes under positive selection) using CDS SNPs.


Quick usage
===========
To quickly get started with PhaME, you can install using conda.

.. code-block:: console

    conda install phame

PhaME: Under the hood.
======================

1. Selecting Reference genome:
-----------------------------
PhaME is a reference genome based tool where all input genomes and metagenomes are first aligned against a reference genome. As a first step in the PhaME pipeline, given a set of reference genomes in path set in parameter `refdir` `phame.ctl` file, one genome is picked as the reference genome. PhaME provides multiple options to pick the most appropriate reference genome. First, reference genome can be picked randomly from the set. Second, users can select reference genome from the list. Lastly, users can use MinHash option, which will calculate the MinHash distance between all reference genomes with each other and with input contigs and raw reads to pick a genome that has the shortest average distance with each other. MinHash distances are calculated using BBMap.

2. Self-nucmerization to remove repeats from reference genomes:
---------------------------------------------------------------
PhaME is built on alignment tool nucmer for genome alignment. All genomes in fasta format that are complete and included as set of reference genomes are first aligned with self, called `self-nucmerization`, using `nucmer` to remove repeats within a genome. Following `nucmer` command is used for the self-nucmerization step:

::

    nucmer --maxmatch --nosimplify --prefix=seq_seq$$ ref_genomeA.fasta ref_genomeA.fasta

::

The option `--maxmatch`  reports all matches is used to ensure all possible alignments are reported for maximal removal of repeats. The identified repeat regions are then removed from downstream analyses.

3. Genome Alignments
--------------------------------
All genomes that are in `refdir` are first aligned against the reference genome (see section 1) that have had its repeats removed (section 2). Likewise, incomplete genomes or contigs, the ones that are listed in the `workdir` with extension `.contig` are also aligned against the reference genome using `nucmer`. For aligning genomes in fasta format against each other, following command, same as the previous step for nucmer alignment is used:

::

    nucmer --maxmatch refgenome.fasta genome.fasta

::

All other options in nucmer alignments are kept at default, some of the important ones are listed below:

::

   -b|breaklen     Set the distance an alignment extension will attempt to
                    extend poor scoring regions before giving up (default 200)
    -c|mincluster   Sets the minimum length of a cluster of matches (default 65)
    -D|diagdiff     Set the maximum diagonal difference between two adjacent
                    anchors in a cluster (default 5)
    -d|diagfactor   Set the maximum diagonal difference between two adjacent
                    anchors in a cluster as a differential fraction of the gap
                    length (default 0.12)
    --[no]extend    Toggle the cluster extension step (default --extend)
    -g|maxgap       Set the maximum gap between two adjacent matches in a
                    cluster (default 90)
    -l|minmatch     Set the minimum length of a single match (default 20)

::

Also, `nucmer` only aligns `A``T``C``G`, all other characters are ignored. So, if there are `N`s in the provided genomes, thse positions are not included in the alignment.

4. Mapping of raw reads to reference genome
-------------------------------------------
PhaME as of now only processes short raw reads from Illumina. If raw reads, single or paired end, are included in the analyses, they are mapped to the reference genome using either `bowtie2` or `BWA`. For reads mapping of reference genome, following commands are used:

First, it builds database from the reference genome.
::

    bowtie2-build refgenome refgenome

::
or, if BWA was chosen as the preferred aligner:

::

    bwa index refgenome

::

The raw reads are then mapped to the reference genomne using one of the following commands:

For bowtie2 and paired reads:

::

    bowtie2 -a -x $refgenome -1 read1 -2 read2 -S paired.sam`;

::
The option `-a` reports all possible alignments.

For bowtie2 and single end reads:

::

    bowtie2 -a -x $refgenome -U read -S single.sam`;

::

For BWA and paired reads:

::

    bwa mem refgenome read1 read2 | samtools view -ubS -| samtools sort -T tmp_folder -O BAM -o paired.bam

::

For BWA and single end reads:

::

    bwa mem refgenome read |samtools view -ubS - | samtools sort -T tmp_folder -O BAM -o single.bam

::


5. Filtering genome alignments
------------------------------
Genome alignment produced using `nucmer` are filtered using `delta-filter` to only keep 1 to 1 alignments allowing for rearrangements. This filtering step is produced for all `nucmer` alignments.

::

    delta-filter -1 genome.delta > genome.snpfilter

::


6. Calling SNPs from genome alignments
--------------------------------------
The pairwise `nucmer` alignments are then parsed to produce a SNP table using `show-snps`.

::

    show-snps -CT genome.snpfilter > genome.snps

::

Here, option C and T specifies not to report SNPs from ambiguous alignments and report the output in tab delimited file respectively.

7. Reporting nucmer alignments
----------------------------

Each alignments are further parse to produce a tab delimited file that has information on regions and %ID of their alignments.
::

    show-coords -clTr genome.snpfilter > genome.coords

::

The parameter flag -clTr implies different headers to be reported in the report.

::

-c          Include percent coverage information in the output
-l          Include the sequence length information in the output
-r          Sort output lines by reference IDs and coordinates
-T          Switch output to tab-delimited format

::

8. Calling SNPs from read mapping
---------------------------------
`bcftools mpileup` is used for calling SNPs from read mapping results (bam file). Maximum depth is set to 1000000 for both SNP and indel calling.  


runReadsToGenome.pl -snp_filter $snp_filter -ploidy $ploidy -p '$read1 $read2' -ref $reference -pre $prefix -d $outdir -aligner $aligner -cpu $thread -consensus 0

::


bcftools mpileup -d $max_depth -L $max_depth -m $min_indel_candidate_depth -Ov -f $ref_file $bam_output | bcftools call --ploidy 1 -cO b - > $bcf_output 2>/dev/null`;
                `bcftools view -v snps,indels,mnps,ref,bnd,other -Ov $bcf_output | vcfutils.pl varFilter -a$min_alt_bases -d$min_depth -D$max_depth > $vcf_output`;
            }
            else {
                print "SNPs/Indels call on $ref_file_name\n";
                `bcftools mpileup -d $max_depth -L $max_depth -m $min_indel_candidate_depth -Ov -f $ref_file $bam_output | bcftools call -cO b - > $bcf_output 2>/dev/null`;
                `bcftools view -v snps,indels,mnps,ref,bnd,other -Ov $bcf_output | vcfutils.pl varFilter -a$min_alt_bases -d$min_depth -D$max_depth > $vcf_output`;
            }
            print "Filtering SNPs\n";
            `bcftools filter -i '(DP4[0]+DP4[1])==0 || (DP4[2]+DP4[3])/(DP4[0]+DP4[1]+DP4[2]+DP4[3]) > $snp_filter' $vcf_output > $vcf_filtered`;

::

