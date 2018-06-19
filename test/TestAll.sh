#! /bin/bash

#rm -rf test/workdirs

if [[ $1 -eq 1 ]] || [[ -z $1 ]];then
	############# #1 Test with just paired reads and picked reference ##############
	mkdir -p test/workdirs/t1_ebola_preads
	cp test/data/ebola_reads/*R[1-2]*.fastq test/workdirs/t1_ebola_preads
	perl src/runPhaME.pl test/ctl_files/t1_ebola_preads.ctl
	a=$(grep -c ">" < test/workdirs/t1_ebola_preads/results/t1_all_snp_alignment.fna)
	b=2
	if [ "$a" -eq "$b" ];then
		echo "Test 1 finished without any errors";
	else
		echo "Test 1: There is something wrong!"
		echo "t1_all_snp_alignment.fna does not have 2 sequences."
		cat test/workdirs/t1_ebola_preads/results/t1_all_snp_alignment.fna
		cat test/workdirs/t1_ebola_preads/results/t1_PhaME.log
		cat test/workdirs/t1_ebola_preads/results/t1.error
		ls -lh test/workdirs/t1_ebola_preads/results/

		exit 1
	fi
	############################################################################
fi

if [[ $1 -eq 2 ]] || [[ -z $1 ]];
then
	############## #2 Test with just single reads and random reference #############
	mkdir -p test/workdirs/t2_ebola_sreads
	cp test/data/ebola_reads/*R1.fastq test/workdirs/t2_ebola_sreads/
	perl src/runPhaME.pl test/ctl_files/t2_ebola_sreads.ctl
	a=$(grep -c ">" test/workdirs/t2_ebola_sreads/results/t2_all_snp_alignment.fna)
	b=2
	if [ "$a" -eq "$b" ];then
		echo "Test 2 finished without any errors";
	else
		echo "Test 2: There is something wrong!"
		exit 1
	fi
	############################################################################
fi

if [[ $1 -eq 3 ]] || [[ -z  $1 ]];
then
	############## #3 Test with just contigs using ANI based reference ##############
	mkdir -p test/workdirs/t3_ebola_contigs
	cp test/data/ebola_contigs/*.contigs test/workdirs/t3_ebola_contigs/
	perl src/runPhaME.pl test/ctl_files/t3_ebola_contigs.ctl
	a=$(wc -l < test/workdirs/t3_ebola_contigs/results/t3_all_snp_alignment.fna)
	b=20
	if [ "$a" -eq "$b" ];then
		echo "Test 3 finished without any errors";
	else
		echo "Test 3: There is something wrong!"
		exit 1
	fi
	############################################################################
fi

if [[ $1 -eq 4 ]] || [[ -z $1 ]];
then
	######## #4 Test with just complete and uses given reference, tests PAML####
	mkdir -p test/workdirs/t4_ebola_complete
	perl src/runPhaME.pl test/ctl_files/t4_ebola_complete.ctl
	a=$(grep -c ">" < test/workdirs/t4_ebola_complete/results/t4_all_snp_alignment.fna)
	b=9
	if [ "$a" -eq "$b" ];then
		echo "Test 4 finished without any errors";
	else
		echo "Test 4: There is something wrong!"
		exit 1
	fi
	# Turning off test for PAML, taking too long, need a quicker dataset
	# a=$(wc -l < test/workdirs/t4_ebola_complete/results/paml/PAMLsitesResults.txt)
	# b=8
	# if [ "$a" -eq "$b" ];then
	# 	echo "Test 4 finished without any errors";
	# else
	# 	echo "Test 4: There is something wrong with PAML test!"
	# 	exit 1
	# fi
	############################################################################
fi

if [[ $1 -eq 5 ]] || [[ -z $1 ]];then

	### #5 Test with complete and contigs, uses given reference and tests HyPhy ####
	mkdir -p test/workdirs/t5_ebola_complete_contigs
	cp test/data/ebola_contigs/*.contigs test/workdirs/t5_ebola_complete_contigs/
	perl src/runPhaME.pl test/ctl_files/t5_ebola_cmp_ctgs.ctl
	a=$(grep -c ">" test/workdirs/t5_ebola_complete_contigs/results/t5_all_snp_alignment.fna)
	b=9
	a=$(grep -c "LRT" test/workdirs/t5_ebola_complete_contigs/results/PSgenes/cds0_470_2689.cdn.ABSREL.json)
	b=16
	if [ "$a" -eq "$b" ];then
		echo "Test 5 finished without any errors";
	else
		echo "Test 5: There is something wrong with HyPhy test!"
		exit 1
	fi
	################################################################################
fi

if [[ $1 -eq 6 ]] || [[ -z $1 ]];then
	########### #6 Test with complete and sread, picks a random reference ##########
	mkdir -p test/workdirs/t6_ebola_complete_sread
	cp test/data/ebola_reads/*R1.fastq test/workdirs/t6_ebola_complete_sread/
	perl src/runPhaME.pl test/ctl_files/t6_ebola_cmp_sreads.ctl
	a=$(grep -c ">" test/workdirs/t6_ebola_complete_sread/results/t6_all_snp_alignment.fna)
	b=11
	if [ "$a" -eq "$b" ];then
		echo "Test 6 finished without any errors";
	else
		echo "Test 6: There is something wrong!"
		exit 1
	fi
	################################################################################
fi

if [[ $1 -eq 7 ]] || [[ -z $1 ]] || [[ $1 -eq 13 ]];
then
	################ #7 Test with complete and pread, designated reference ########
	mkdir -p test/workdirs/t7_ebola_complete_pread
	cp test/data/ebola_reads/*R[1-2].fastq test/workdirs/t7_ebola_complete_pread/
	perl src/runPhaME.pl test/ctl_files/t7_ebola_cmp_preads.ctl
	a=$(grep -c ">" test/workdirs/t7_ebola_complete_pread/results/t7_cds_snp_alignment.fna)
	b=11
	if [ "$a" -eq "$b" ];then
		echo "Test 7 finished without any errors";
	else
		echo "Test 7: There is something wrong!"
		exit 1
	fi
	################################################################################
fi

if [[ $1 -eq 8 ]] || [[ -z $1 ]];
then
	######## #8 Test with contigs and sread, picks set reference ###################
	mkdir -p test/workdirs/t8_ebola_contigs_sread
	cp test/data/ebola_reads/*R1.fastq test/workdirs/t8_ebola_contigs_sread/
	cp test/data/ebola_contigs/*.contigs test/workdirs/t8_ebola_contigs_sread/
	perl src/runPhaME.pl test/ctl_files/t8_ebola_ctg_sreads.ctl
	a=$(grep -c ">" test/workdirs/t8_ebola_contigs_sread/results/t8_all_snp_alignment.fna)
	b=12
	if [ "$a" -eq "$b" ];then
		echo "Test 8 finished without any errors";
	else
		echo "Test 8: There is something wrong!"
		exit 1
	fi
	################################################################################
fi

if [[ $1 -eq 9 ]] || [[ -z $1 ]];
then
	################### #9 Test with contigs and pread #############################
	mkdir -p test/workdirs/t9_ebola_contigs_pread
	cp test/data/ebola_reads/*R[1-2].fastq test/workdirs/t9_ebola_contigs_pread/
	cp test/data/ebola_contigs/*.contigs test/workdirs/t9_ebola_contigs_pread/
	perl src/runPhaME.pl test/ctl_files/t9_ebola_ctg_preads.ctl
	a=$(grep -c ">" test/workdirs/t9_ebola_contigs_pread/results/t9_all_snp_alignment.fna)
	b=3
	if [ "$a" -eq "$b" ];then
		echo "Test 9 finished without any errors";
	else
		echo -e "Test 9: There is something wrong!"
		exit 1
	fi
	################################################################################
fi

if [[ $1 -eq 10 ]] || [[ -z $1 ]];
then
	################### #10 Test exit messages for incorrect ctl files #############
	mkdir -p test/workdirs/t10_error_messages
	perl src/runPhaME.pl test/ctl_files/t10A_error_message.ctl > test/workdirs/t10_error_messages/A.error
	perl src/runPhaME.pl test/ctl_files/t10B_error_message.ctl > test/workdirs/t10_error_messages/B.error
	a=$(wc -l < test/workdirs/t10_error_messages/A.error)
	b=$(wc -l < test/workdirs/t10_error_messages/B.error)
	c=14
	if [ "$a" -eq "$b" ];then
		echo "Test 10 finished without any errors";
	else
		echo -e "Test 10: There is something wrong while printing error messages!"
		exit 1
	fi
	################################################################################
fi

if [[ $1 -eq 11 ]] || [[ -z $1 ]];
then
	################### #11 Test the threshold option#########################
	mkdir -p test/workdirs/t11_flu
	perl src/runPhaME.pl test/ctl_files/t11_flu_test_coverage_threshold.ctl
	a=$(grep -c ">" test/workdirs/t11_flu/results/t11_all_snp_alignment.fna)
	b=25
	if [ "$a" -eq "$b" ];then
		echo "Test 11 finished without any errors";
	else
		echo -e "Test 11: There is something wrong with threshold option!"
		exit 1
	fi
	################################################################################
fi

if [[ $1 -eq 13 ]] || [[ -z $1 ]];
then
	################### #13 Test the realignment option#########################
	mkdir -p test/workdirs/t13_realignment
	cp -r test/workdirs/t7_ebola_complete_pread/* test/workdirs/t13_realignment/
	cp test/workdirs/t3_ebola_contigs/working_list.txt test/workdirs/t13_realignment/
	perl src/runPhaME.pl test/ctl_files/t13_realignment.ctl
	a=$(grep -c ">" test/workdirs/t13_realignment/results/t13_all_snp_alignment.fna)
	b=10
	if [ "$a" -eq "$b" ];then
		echo "Test 13 finished without any errors";
	else
		echo -e "Test 13: There is something wrong with realignment option!"
		exit 1
	fi
	################################################################################
fi

if [[ $1 -eq 14 ]] || [[ -z $1 ]];
then
	################### #13 Test the second time option#########################
	mkdir -p test/workdirs/t14_secondtime
	cp -r test/workdirs/t5_ebola_complete_contigs/* test/workdirs/t14_secondtime/
	cp test/data/ebola_reads/*R[1-2].fastq test/workdirs/t14_secondtime/
	perl src/runPhaME.pl test/ctl_files/t14_secondtime.ctl
	a=$(grep -c ">" test/workdirs/t14_secondtime/results/t14_all_snp_alignment.fna)
	b=12
	if [ "$a" -eq "$b" ];then
		echo "Test 14 finished without any errors";
	else
		echo -e "Test 14: There is something wrong with second time option!"
		exit 1
	fi
	################################################################################
fi
