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

PhaME is a reference genome based tool where all input genomes and metagenomes are first aligned against a reference genome. As a first step in the PhaME pipeline, given a set of reference genomes in path set in parameter `refdir` `phame.ctl` file, one genome is picked as the reference genome. PhaME provides multiple options to pick the most appropriate reference genome. Reference genome can be picked randomly from the set, users can select the reference genome, or can use our MinHash option to pick a refeference genome that has 

PhaME is built on alignment tool nucmer for genome alignment. All genomes in fasta format that are complete and included as set of reference genomes are first aligned with self, called self-nucmerization, using `nucmer` to remove repeats within a genome. Following `nucmer` command is used for the self-nucmerization step:


::

    nucmer --maxmatch --nosimplify --prefix=seq_seq$$ ref_genomeA.fasta ref_genomeA.fasta

::

The identified repeat regions are then removed from downstream analyses. Among the reference 

