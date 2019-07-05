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

The identified repeat regions are then removed from downstream analyses.

3. Genome Alignments
--------------------
All genomes that are in `refidir` are first aligned against the reference genome (see section 1) that have had its repeats removed. Likewise, incomplete genomes or contigs, the ones that are listed in the `workdir` with extension `.contig` are also aligned against the reference genome. Raw reads if included in the analyses are mapped to the reference genome using either `bowtie2` or `BWA`. For aligning genomes in fasta format against each other, following commands are used:

::

    nucmer --maxmatch refgenome.fasta genome.fasta
    delta-filter -1 0 refgenome_genome.delta > workdir/refgenome_genome.snpfilter
::

