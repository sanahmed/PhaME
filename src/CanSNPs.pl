#!/usr/bin/env perl

use strict;
use warnings;
use File::Basename;
use Getopt::Long;

my $group_file="";
my $list="";
my $threshold = 0.5;
my $version = 0.2;
my $symbol = "-";
GetOptions(
	"group=s"     => \$group_file,
	"list=s"      => \$list,
	"threshold=f" => \$threshold,
	"symbol=s"    => \$symbol,
	"version"     => sub{printVersion()},
	"help|?"      => sub{Usage()}
);
my $input_align=$ARGV[0];


sub Usage{
	my $msg=shift;
	print ("\nfailed ...     ".$msg."\n\n") if $msg;
	print <<"END";
	Usage: perl $0 [options] --group <group_file> <snp_alignment>  > output.fasta

	--group    Group inforamtion in tab-delimited text file [mutually exclusive to list]
                   ex:   ID               Group
		         fasta_header_A	  A
			 fasta_header_B   A 
			 fasta_header_C   B
			 fasta_header_D   B
	  OR

        --list     file with a list fasta headers. one per line [mutually exclusive to group]
                   The list will be treated as One group. All other sequences in the input 
                   alignment will be as Another group.

	Options:
	--threshold    Fraction of nucleotide in a group for defining Canonical SNPs (default :0.5)
	--symbol       Not Canonical nt will use symbol in the output (default: "-")
			 
	
END
exit;
}

if(!@ARGV){ &Usage("No alignment input.");}
if(! -e $group_file && ! -e $list ){ &Usage("No group file input or given list.");}
if(-e $group_file &&  -e $list ){ &Usage("group and list options are mutually exclusive.");}
if ( $threshold <0 or $threshold >1){ &Usage("threshold is between 0 and 1");}

## Read group info 
## Return $group hash reference:  ID -> Group
#@ Return $group_count hash reference: Group -> Count in number
my ($group, $group_count);
if ( -e $list){
	open (my $lfh,"<",$list);
	while(<$lfh>){
		chomp;
		$_ =~ s/\s//g;
		$group->{$_}="A";
		$group_count->{"A"}++;
	}
	close $lfh;
}elsif(-e $group_file){
	($group,$group_count) = &readGroup($group_file);
}

my %seq; # sequence hash: fasta header -> sequence
my %unique; # unique count hash store {group}{position}{nucleotide}{count}

#read sequence in paragraph mode separated by ">"
$/ = ">";
open(my $fh, "<", $input_align);
while( my $sequenceEntry= <$fh>){
	next if ($sequenceEntry =~ m/^\s*>/);
	my $sequenceTitle = "";
	$sequenceTitle = ($sequenceEntry =~ m/^([^\n]+)/)? $1 : "No title was found!";
	$sequenceEntry =~ s/^[^\n]+\n//;
	$sequenceEntry =~ s/[^A-Za-z0-9 \n]//g;
	
	if (-e $list){
		$seq{$sequenceTitle}=$sequenceEntry;
		my $group_id = $group->{$sequenceTitle};
		if (!$group_id){
			$group_id="B";
			$group->{$sequenceTitle}="B";
			$group_count->{"B"}++;	
		}
		my @nts = split //,$sequenceEntry;
		for my $i (0 .. $#nts){
			my $nt=uc($nts[$i]);
			$unique{$group_id}{$i}{$nt}++;
		}
	}else{
		if ($group->{$sequenceTitle}){
			$seq{$sequenceTitle}=$sequenceEntry;
			my $group_id = $group->{$sequenceTitle};
			my @nts = split //,$sequenceEntry;
			for my $i (0 .. $#nts){
				my $nt=uc($nts[$i]);
				$unique{$group_id}{$i}{$nt}++;
			}
		}
	}
}
close $fh;

$/ = ""; # return the default paragraph mode (newline)
my $len;
# apply criteria to define Canonical SNPs
# 1. The {group}{pos}{nucleotide} does not have in the other groups pos nt 
# 2. fration of any nucleotide > threshold. (dominant nt)
foreach my $id (sort keys %seq){
	my $seq = $seq{$id};
	chomp $seq;  # remove trailing newline
	my $unique_seq="";
	my $group_id = $group->{$id};
	my $group_num = $group_count->{$group_id};
	my @nts = split //,$seq;
	$len=0;
	for my $j (0 .. $#nts){
		my $flag=0;
		my $flag2=0;
		my $nt=uc($nts[$j]);
		OUTER: for my $g (keys %$group_count){
			next if $g eq $group_id;
			if ($unique{$g}{$j}{$nt} and $unique{$g}{$j}{$nt} > 0){
				$flag=1; # not canonical 
				last OUTER;
			}
			for my $n ("A","T","C","G"){
				if ($unique{$g}{$j}{$n} && $unique{$group_id}{$j}{$n}){
					$flag=1;
					last OUTER;
				}
				if ( -e $list && $group_id eq "B"){
					if($unique{"A"}{$j}{$n} and ($unique{"A"}{$j}{$n}/$group_num) >= $threshold){
						$flag2=1;}
				}elsif ($unique{$group_id}{$j}{$n} and ($unique{$group_id}{$j}{$n}/$group_num) >= $threshold){
                    $flag2=1;
					}
			}
		}
		if ($flag){
			$unique_seq .= $symbol;
		}else{ # criteria 1
			if ($flag2){ #criteria 2
				$unique_seq .= $nt;
				$len++;
			}else{
				$unique_seq .= $symbol;
			}
		}
	}
	if ($unique_seq){
		print ">$id\n$unique_seq\n";
	}else{
		print STDERR "no unique aligned seq for $id\n";
	}
}


print STDERR "Length: $len\n";

sub readGroup{
	my $file=shift;
	my %hash;
	my %count;
	open (my $fh2, "<", $file);
	while(<$fh2>){
		chomp;
		next if (/^ID/);
		my ($id,$group)=split /\s+/,$_;
		$hash{$id}=$group;
		$count{$group}++;
	}
	close $fh2;
	return (\%hash,\%count);
}

sub printVersion 
{
    print basename($0), " version: $version\n";
    exit;
}
