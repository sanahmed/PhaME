Introduction
#############

What is PhaME?
==============

PhaME or Phylogenetic and Molecular Evolution (PhaME) is an analysis tool that performs phylogenetic and molecular evolutionary analysis.

Given a reference, PhaME extracts SNPs from complete genomes, draft genomes and/or reads, uses SNP multiple sequence alignment to construct a phylogenetic tree, and provides evolutionary analyses (genes under positive selection) using CDS SNPs.


PhaME: Under the hood.
======================

Here, We have explained in detail how PhaME works in detail.

Selecting Reference genome:
-----------------------------
PhaME is a reference genome based tool where all input genomes and metagenomes are first aligned against a reference genome. As a first step in the PhaME pipeline, given a set of reference genomes in path set in parameter `refdir` `phame.ctl` file, one genome is picked as the reference genome. PhaME provides multiple options to pick the most appropriate reference genome. First, reference genome can be picked randomly from the set. Second, users can select reference genome from the list. Lastly, users can use MinHash option, which will calculate the MinHash distance between all reference genomes with each other and with input contigs and raw reads to pick a genome that has the shortest average distance with each other. MinHash distances are calculated using BBMap [Bushnell]_.

Self-nucmerization to remove repeats from reference genomes:
---------------------------------------------------------------
PhaME is built on alignment tool nucmer [Kurtz 2004]_ for genome alignment. All genomes in fasta format that are complete and included as set of reference genomes are first aligned with self, called `self-nucmerization`, using `nucmer` to remove repeats within a genome. Following `nucmer` command is used for the self-nucmerization step:

::

    nucmer --maxmatch --nosimplify --prefix=seq_seq$$ ref_genomeA.fasta ref_genomeA.fasta

::

The option `--maxmatch`  reports all matches is used to ensure all possible alignments are reported for maximal removal of repeats. The identified repeat regions are then removed from downstream analyses.

Genome Alignments
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

Also, `nucmer` only aligns `"A"` `"T"` `"C"` `"G"`, all other characters are ignored. So, if there are `"N"`s in the provided genomes, thse positions are not included in the alignment.

*Note*: If an analysis requires running multiple iterations of PhaME on a same set of dataset or a subset of dataset, one doesn't need to perform the alignment over and over again. PhaME provides an option where it can keep all possible pairwise alignment of genomes from `refdir` for future analyses. All the steps mentioned in this section are the same, except that all vs. all alignment is performed compared to just one reference. By doing all vs. all alignment one can also test the effect on their analyses with different reference genomes.

Mapping of raw reads to reference genome
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


Filtering genome alignments
------------------------------
Genome alignment produced using `nucmer` are filtered using `delta-filter` to only keep 1 to 1 alignments allowing for rearrangements. This filtering step is produced for all `nucmer` alignments.

::

    delta-filter -1 genome.delta > genome.snpfilter

::


Calling SNPs from genome alignments
--------------------------------------
The pairwise `nucmer` alignments are then parsed to produce a SNP table using `show-snps`.

::

    show-snps -CT genome.snpfilter > genome.snps

::

Here, option C and T specifies not to report SNPs from ambiguous alignments and report the output in tab delimited file respectively.

Reporting nucmer alignments
------------------------------

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

Calling SNPs from read mapping
---------------------------------
`bcftools mpileup` is used for calling SNPs from read mapping results (bam file) of every genomes represented by raw reads. Maximum depth is set to 1000000 for both SNP and indel calling and minimum gaps for calling an indel is set to 3. The output vcf file is then used to call SNPs using `bcftools call` where ploidy is specified as `1` if its a haploid or bacterial genome, else it is called using default parameter. Furthermore, based on the user specified parameter in the control file, SNPs are further filtered based on percentage of SNPs. Here are the snippets of commmand that are run as part of this. All of them result in a vcf file.

::

    bcftools mpileup -d 1000000 -L 1000000 -m 3 -Ov -f $refgenome $bam_output | bcftools call --ploidy 1 -cO b > $bcf_output;
    bcftools view -v snps,indels,mnps,ref,bnd,other -Ov $bcf_output | vcfutils.pl varFilter -a$min_alt_bases -d$min_depth -D$max_depth > $vcf_output`;
    bcftools filter -i '(DP4[0]+DP4[1])==0 || (DP4[2]+DP4[3])/(DP4[0]+DP4[1]+DP4[2]+DP4[3]) > $snp_filter' $vcf_output > $vcf_filtered`

::


Calculating core genome alignments
----------------------------------
As a first step in calculating the core genome, all alignments to reference are checked for linear coverage to assure the proportion of reference genome that was used in the alignment. If its lower than the threshold cutoff (default = 0.6) set in control file, that genome will be removed from further analyses. Then rest of the pairwise alignments that are either in vcf format or nucmer formats are then collated to calculate a core genome. Only the alignment position that are 100% conserved are kept, all other positions are removed from the final core genome alignment. PhaME produces multiple alignment files corresponding to core genome such as the one that has only the variant sites (`_all_snp_alignment.fna`), has variant and invariant sites (`all_alignment.fna`), and the ones that have SNPs from only the coding region (`_cds_snp_alignment.fna`). The coding region SNP alignment requires a GFF formatted annotation file.


Reconstructing core genome phylogeny
-------------------------------------
PhaME provides multiple tools (RAxML [Stamatakis 2014]_, FastTree [Price 2010]_, and IQ-Tree [Nguyen 2015]_) to reconstruct phylogeny from one core genome alignments that have invariant sites. If RAxML or FastTree option is chosen, users cannot modify the models as they are pre-selected. RAxML trees are reconstructed using GTRGAMMAI models that "GTR + Optimization of substitution rates + GAMMA model of rate heterogeneity (alpha parameter will be estimated)" with `I` but with estimate for invariable sites. FastTree uses GTR model only. IQ-TREE is run using option `-m TEST` that searches for the best model that fits the data before reconstructing the phylogeny. RAxML is the only option that is currently available that can also calculate the bootstraps.

Selecting genes for molecular evolutionary analyses
-------------------------------------------------------
To perform selection analyses using PAML or HyPhy, codon alignments of genes are required. Based on the position of SNPs in the reference genome, if a SNP is within a coding region and if that coding region does not have a gap, they are extracted from the core genome alignment. The nucleotide sequences of the genes are then translated to protein sequences, aligned using the program `mafft`, and then reverse translated back to nucleotide using the perl code `pal2nal.pl` from http://www.bork.embl.de/pal2nal/.

Molecular Evoluationary analyses
------------------------------------
The set of gene alignments are then used for molecular evolutionary analyses using either PAML [Yang 2007]_ or HyPhy [Pond 2005]_. PAML is run twice for the same gene using two differnt models (`model=0` and `model=2`), first that sets one omega ratio for all branches and another that sets different omega ratios for all lineages. For the first model, additional parameter variation model that specifies, neutral (1), selection (2), beta and omega ratio between 0 and 1 (7), and beta, omega and an additional omega is run. For the Model 2 with variable omega ratios across all branches, the model with one omega across all sites are used. If HyPhy is selected, it uses the aBSREL (adaptive Branch-Site Random Effects Likelihood) model.

References
--------------
.. [Yang 2007] Yang Z: PAML 4: phylogenetic analysis by maximum likelihood. Mol Biol Evol 2007, 24:1586-1591.
.. [Pond 2005] Pond SL, Frost SD, Muse SV: HyPhy: hypothesis testing using phylogenies. Bioinformatics 2005, 21:676-679.
.. [Kurtz 2004] Kurtz S, Phillippy A, Delcher AL, Smoot M, Shumway M, Antonescu C, Salzberg SL: Versatile and open software for comparing large genomes. Genome Biol 2004, 5:R12.
.. [Bushnell] Bushnell B: BBMap. 37.66 edition. sourceforge.net/projects/bbmap/.
.. [Stamatakis 2014] Stamatakis A: RAxML version 8: a tool for phylogenetic analysis and post- analysis of large phylogenies. Bioinformatics 2014, 30:1312-1313.
.. [Price 2010] Price MN, Dehal PS, Arkin AP: FastTree 2--approximately maximum- likelihood trees for large alignments. PLoS One 2010, 5:e9490.
.. [Nguyen 2015] Nguyen LT, Schmidt HA, von Haeseler A, Minh BQ: IQ-TREE: a fast and effective stochastic algorithm for estimating maximum-likelihood phylogenies. Mol Biol Evol 2015, 32:268-274.