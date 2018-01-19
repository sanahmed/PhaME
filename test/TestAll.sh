#! /bin/sh

# PHAME = "src/runPhaME.pl" 

rm -rf test/workdirs

#1 test with just paired reads
mkdir -p test/workdirs/ebola_preads
cp test/data/ebola_reads/*R[1-2]*.fastq test/workdirs/ebola_preads
perl src/runPhaME.pl test/ctl_files/t1_ebola_preads.ctl
cmp test/workdirs/ebola_preads/results/t1_all_snp_alignment.fna test/truth/t1_all_snp_alignment.fna

#2 test with just single reads
mkdir -p test/workdirs/ebola_sreads
cp test/data/ebola_reads/*R1.fastq test/workdirs/ebola_sreads/
perl src/runPhaME.pl test/ctl_files/t2_ebola_sreads.ctl
cmp test/workdirs/ebola_preads/results/t2_all_snp_alignment.fna test/truth/t2_all_snp_alignment.fna

#3 test with just contigs
mkdir -p test/workdirs/ebola_contigs
cp test/data/ebola_contigs/*.contigs test/workdirs/ebola_contigs/
perl src/runPhaME.pl test/ctl_files/t3_ebola_contigs.ctl
cmp test/workdirs/ebola_contigs/results/t3_all_snp_alignment.fna test/truth/t3_all_snp_alignment.fna

#4 test with just complete
mkdir -p test/workdirs/ebola_complete
perl src/runPhaME.pl test/ctl_files/t4_ebola_complete.ctl
cmp test/workdirs/ebola_complete/results/t4_all_snp_alignment.fna test/truth/t4_all_snp_alignment.fna

#5 test with complete and contigs
mkdir -p test/workdirs/ebola_complete_contigs
cp test/data/ebola_contigs/*.contigs test/workdirs/ebola_complete_contigs/
perl src/runPhaME.pl test/ctl_files/t5_ebola_cmp_ctgs.ctl
cmp test/workdirs/ebola_complete_contigs/results/t5_all_snp_alignment.fna test/truth/t5_all_snp_alignment.fna

#6 test with complete and sread
mkdir -p test/workdirs/ebola_complete_sread
cp test/data/ebola_reads/*R1.fastq test/workdirs/ebola_complete_sread/
perl src/runPhaME.pl test/ctl_files/t6_ebola_cmp_sreads.ctl
cmp test/workdirs/ebola_complete_sread/results/t6_all_snp_alignment.fna test/truth/t6_all_snp_alignment.fna

#7 test with complete and pread
mkdir -p test/workdirs/ebola_complete_pread
cp test/data/ebola_reads/*R[1-2].fastq test/workdirs/ebola_complete_pread/
perl src/runPhaME.pl test/ctl_files/t7_ebola_cmp_preads.ctl
cmp test/workdirs/ebola_complete_pread/results/t7_all_snp_alignment.fna test/truth/t7_all_snp_alignment.fna

#8 test with contigs and sread
mkdir -p test/workdirs/ebola_contigs_sread
cp test/data/ebola_reads/*R1.fastq test/workdirs/ebola_contigs_sread/
cp test/data/ebola_contigs/*.contigs test/workdirs/ebola_contigs_sread/
perl src/runPhaME.pl test/ctl_files/t8_ebola_ctg_sreads.ctl
cmp test/workdirs/ebola_contigs_sread/results/t8_all_snp_alignment.fna test/truth/t8_all_snp_alignment.fna

#9 test with contigs and pread
mkdir -p test/workdirs/ebola_contigs_pread
cp test/data/ebola_reads/*R[1-2].fastq test/workdirs/ebola_contigs_pread/
cp test/data/ebola_contigs/*.contigs test/workdirs/ebola_contigs_pread/
perl src/runPhaME.pl test/ctl_files/t9_ebola_ctg_preads.ctl
cmp test/workdirs/ebola_contigs_sread/results/t8_all_snp_alignment.fna test/truth/t8_all_snp_alignment.fna

#10 test with sread and pread
mkdir -p test/workdirs/ebola_sread_pread
cp test/data/ebola_reads/*R1.fastq test/workdirs/ebola_sread_pread/
cp test/data/ebola_reads/*R[1-2].fastq test/workdirs/ebola_sread_pread/
perl src/runPhaME.pl test/ctl_files/t10_ebola_sreads_preads.ctl


#11 test with complete, contigs, and sread 
mkdir -p test/workdirs/ebola_comp_contigs_sread
cp test/data/ebola_contigs/*.contigs test/workdirs/ebola_comp_contigs_sread/
cp test/data/ebola_reads/*R1.fastq test/workdirs/ebola_contigs_sread/
perl src/runPhaME.pl test/ctl_files/t11_ebola_comp_contigs_sread.ctl

#12 test with complete, contigs, and pread 
mkdir -p test/workdirs/ebola_comp_contigs_pread
cp test/data/ebola_contigs/*.contigs test/workdirs/ebola_comp_contigs_pread/
cp test/data/ebola_reads/*R[1-2].fastq test/workdirs/ebola_comp_contigs_pread/
perl src/runPhaME.pl test/ctl_files/t12_ebola_comp_contigs_pread.ctl

#13 test with complete, sread, and pread 
mkdir -p test/workdirs/ebola_comp_sread_pread
cp test/data/ebola_reads/*R[1-2].fastq test/workdirs/ebola_comp_sread_pread/
cp test/data/ebola_reads/*R1.fastq test/workdirs/ebola_comp_sread_pread/
perl src/runPhaME.pl test/ctl_files/t13_ebola_comp_sread_pread.ctl


#14 test with contigs, sread, and pread 
mkdir -p test/workdirs/ebola_contigs_sread_pread
cp test/data/ebola_reads/*R[1-2].fastq test/workdirs/ebola_contigs_sread_pread/
cp test/data/ebola_reads/*R1.fastq test/workdirs/ebola_contigs_sread_pread/
cp test/data/ebola_contigs/*.contigs test/workdirs/ebola_contigs_sread_pread/
perl src/runPhaME.pl test/ctl_files/t14_ebola_contigs_sread_pread.ctl

#15 test with complete, contigs, sread, and pread 
mkdir -p test/workdirs/ebola_complete_contigs_sread_pread
cp test/data/ebola_reads/*R[1-2].fastq test/workdirs/ebola_contigs_sread_pread/
cp test/data/ebola_reads/*R1.fastq test/workdirs/ebola_contigs_sread_pread/
cp test/data/ebola_contigs/*.contigs test/workdirs/ebola_contigs_sread_pread/
perl src/runPhaME.pl test/ctl_files/t15_ebola_complete_contigs_sread_pread.ctl
