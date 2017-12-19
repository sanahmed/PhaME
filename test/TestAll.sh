#! /bin/sh

# PHAME = "src/runPhaME.pl" 

#1 test with just paired reads
mkdir -p test/workdirs/ebola_preads
cp test/data/ebola_reads/*R[1-2]*.fastq test/workdirs/ebola_preads
perl src/runPhaME.pl test/ctl_files/ebola_preads.ctl
cmp test/workdirs/ebola_preads/results/ebola_preads_all_snp_alignment.fna test/truth/ebola_preads_all_snp_alignment.fna

#2 test with just single reads
mkdir -p test/workdirs/ebola_sreads
cp test/data/ebola_reads/*R1.fastq test/workdirs/ebola_sreads/
perl src/runPhaME.pl test/ctl_files/ebola_sreads.ctl
cmp test/workdirs/ebola_preads/results/ebola_single_reads_all_snp_alignment.fna test/truth/ebola_single_reads_all_snp_alignment.fna

#3 test with just contigs
mkdir -p test/workdirs/ebola_contigs
cp test/data/ebola_contigs/*.contigs test/workdirs/ebola_contigs/
perl src/runPhaME.pl test/ctl_files/ebola_contigs.ctl
cmp test/workdirs/ebola_contigs/results/ebola_ctg_all_snp_alignment.fna test/truth/ebola_ctg_all_snp_alignment.fna

#4 test with just complete
mkdir -p test/workdirs/ebola_complete
perl src/runPhaME.pl test/ctl_files/ebola_complete.ctl
cmp test/workdirs/ebola_complete/results/ebola_complete_all_snp_alignment.fna test/truth/ebola_complete_all_snp_alignment.fna

#5 test with complete and contigs
mkdir -p test/workdirs/ebola_complete_contigs
cp test/data/ebola_contigs/*.contigs test/workdirs/ebola_complete_contigs/
perl src/runPhaME.pl test/ctl_files/ebola_cmp_ctgs.ctl
cmp test/workdirs/ebola_complete_contigs/results/ebola_cmp_ctg_all_snp_alignment.fna test/truth/ebola_cmp_ctg_all_snp_alignment.fna

#6 test with complete and sread
mkdir -p test/workdirs/ebola_complete_sread
cp test/data/ebola_reads/*R1.fastq test/workdirs/ebola_complete_sread/
perl src/runPhaME.pl test/ctl_files/ebola_psreads.ctl

#7 test with complete and pread
mkdir -p test/workdirs/ebola_complete_pread
cp test/data/ebola_reads/*R[1-2].fastq test/workdirs/ebola_complete_pread/
perl src/runPhaME.pl test/ctl_files/ebola_psreads.ctl

#8 test with contigs and sread
mkdir -p test/workdirs/ebola_contigs_sread
cp test/data/ebola_reads/*R1.fastq test/workdirs/ebola_contigs_sread/
cp test/data/ebola_contigs/*.contigs test/workdirs/ebola_contigs_sread/

#9 test with contigs and pread
mkdir -p test/workdirs/ebola_contigs_pread
cp test/data/ebola_reads/*R[1-2].fastq test/workdirs/ebola_contigs_pread/
cp test/data/ebola_contigs/*.contigs test/workdirs/ebola_contigs_pread/

#10 test with sread and pread
mkdir -p test/workdirs/ebola_sread_pread
cp test/data/ebola_reads/*R1.fastq test/workdirs/ebola_sread_pread/
cp test/data/ebola_reads/*R[1-2].fastq test/workdirs/ebola_sread_pread/


#11 test with complete, contigs, and sread 
mkdir -p test/workdirs/ebola_comp_contigs_sread
cp test/data/ebola_contigs/*.contigs test/workdirs/ebola_comp_contigs_sread/
cp test/data/ebola_reads/*R1.fastq test/workdirs/ebola_contigs_sread/


#12 test with complete, contigs, and pread 
mkdir -p test/workdirs/ebola_comp_contigs_pread
cp test/data/ebola_contigs/*.contigs test/workdirs/ebola_comp_contigs_pread/
cp test/data/ebola_reads/*R[1-2].fastq test/workdirs/ebola_comp_contigs_pread/

#13 test with complete, sread, and pread 
mkdir -p test/workdirs/ebola_comp_sread_pread
cp test/data/ebola_reads/*R[1-2].fastq test/workdirs/ebola_comp_sread_pread/
cp test/data/ebola_reads/*R1.fastq test/workdirs/ebola_comp_sread_pread/


#14 test with contigs, sread, and pread 
mkdir -p test/workdirs/ebola_contigs_sread_pread
cp test/data/ebola_reads/*R[1-2].fastq test/workdirs/ebola_contigs_sread_pread/
cp test/data/ebola_reads/*R1.fastq test/workdirs/ebola_contigs_sread_pread/
cp test/data/ebola_contigs/*.contigs test/workdirs/ebola_contigs_sread_pread/



#15 test with complete, contigs, sread, and pread 
mkdir -p test/workdirs/ebola_complete_contigs_sread_pread
cp test/data/ebola_reads/*R[1-2].fastq test/workdirs/ebola_contigs_sread_pread/
cp test/data/ebola_reads/*R1.fastq test/workdirs/ebola_contigs_sread_pread/
cp test/data/ebola_contigs/*.contigs test/workdirs/ebola_contigs_sread_pread/
