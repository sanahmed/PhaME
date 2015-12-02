#!/usr/bin/perl 
################################################################
# Written by Sanaa Ahmed
# Jan. 03, 2013

# Given a directory containing snp files creates SNP alignment 
# SNP files can be:  
#  vcf files from read mapping (suffix: .vcf)
#  show-snps file from nucmer  (suffix .snps)
# Requires:
#  Gap tab-delimited file with the following template
#   Fasta header, start coord, end coord
#  Reference fasta file used for read mapping and nucmer
#  List of all genomes to report SNP alignment for.
################################################################

use strict;
use Getopt::Long;
#use diagnostics;
use FileHandle;
use File::Basename;

my $indir;
my $reffile;
my $refheader;
my $coding=0;
my $project;
my $allSNPoutfile;
my $SNPstats;
my $SNPcomps;
my $cdsSNPoutfile;
my $intSNPoutfile;
my $CDScoords;
my $noncoding;
my $ambiguous;
my $gapfile;
my $basefile;
my $allgapfile;
my $pairMatrixfile;
my $coreMatrixfile;
my $cdsMatrixfile;
my $intMatrixfile;
my $ref_sequence;
my $reference;
my @header_list;
my @headers;
my %gap_location;
my %noncoding_location;
my %coding_location;
my %query_gaps;
my $snp_file;
my %pairSNPcount;
my %coreSNPcount;
my %cdsSNPcount;
my %intSNPcount;
my %snp_location;
my $rpos;
my $rbase;
my $qbase;
my $qpos;
my $buff;
my $dist;
my $frm;
my $ref;
my $query;
my %positions;

GetOptions(
   'i=s'      => \$indir,
   'r=s'      => \$reffile,
   'l=s'      => \$refheader,
   'c=s'      => \$coding,
   'p=s'      => \$project,
   'help|h'   => sub{usage()},
);

if (!$indir && !$reffile && !$refheader){die &usage;}
if ($indir=~ /.+\/$/){my $tmp= chop($indir);}
my ($name,$path,$suffix)=fileparse("$reffile",qr/\.[^.]*/);

$allSNPoutfile="$indir\/$project\_all_snp_alignment.fna";
$SNPstats="$indir\/$project\_stats.txt";
$SNPcomps="$indir\/$project\_comparisons.txt";
if ($coding==1){
   $cdsSNPoutfile="$indir\/$project\_cds_snp_alignment.fna";
   $intSNPoutfile="$indir\/$project\_int_snp_alignment.fna";
   $CDScoords="$indir\/CDScoords.txt";
   $noncoding="$indir\/noncoding.txt";
}

$ambiguous="$indir\/$project\_ambiguousSNPpositions.txt";
$allgapfile="$indir\/$project\_gaps.txt";
$basefile="$indir\/$project\_summaryStatistics.txt";
$gapfile="$indir\/$project\_all_gaps.txt";
$pairMatrixfile="$indir\/$project\_snp_pairwiseMatrix.txt";
$coreMatrixfile="$indir\/$project\_snp_coreMatrix.txt";
$cdsMatrixfile="$indir\/$project\_snp_CDSMatrix.txt";
$intMatrixfile="$indir\/$project\_snp_intergenicMatrix.txt";

open (OUT, ">$allSNPoutfile")|| die "$!";
open (STAT, ">$SNPstats")|| die "$!";
open (AMB, ">$ambiguous")|| die "$!";
open (COMP, ">$SNPcomps")|| die "$!";
open (GAPF, ">$allgapfile")|| die "$!";
open (BASE, ">>$basefile")|| die "$!";
open (PMAT, ">$pairMatrixfile")|| die "$!";
open (CMAT, ">$coreMatrixfile")|| die "$!";
open (CDSMAT, ">$cdsMatrixfile")|| die "$!";
open (IMAT, ">$intMatrixfile")|| die "$!";
if ($coding==1){
   open (CDSOUT, ">$cdsSNPoutfile")|| die "$!"; 
   open (INTOUT, ">$intSNPoutfile")|| die "$!";
}

#print BASE "Reference used:\t$name\n";
print AMB "Reference\tQuery\tSNP\tSNP\tref Pos.\n";
if ($coding==1){print STAT "Strain1\tStrain2\tType\tSNP1 pos\tSNP2 pos\tSNP1\tSNP2\tCDS start\tCDS end\n";}
else{print STAT "Strain1\tStrain2\tSNP1 pos\tSNP2 pos\tSNP1\tSNP2\n";}
print COMP "SNP Pos\tGenomes\n";
print PMAT "\t";
print CMAT "\t";
print CDSMAT "\t";
print IMAT "\t";
#if ($genbank==1){print CDSSTAT "SNP Pos\tGenomes\n";}
read_cds_coords() if ($coding==1);
read_reference($reffile);

print "Reading Gaps file.\n";
read_gap($gapfile);

print "Printing Summary Statistics.\n";
print_summary();
read_directory($indir);

print "Creating SNP alignment.\n";
create_ALLsnp_array();
if ($coding==1){
   create_CDSsnp_array();
   create_INTsnp_array();
}

print "Creating SNP stats file. \n";
create_stats();
create_comparison();
create_matrix();

print "SNP alignment complete.\n";

close OUT;
close STAT;
close AMB;
close COMP;
close GAPF;
close BASE;
close PMAT;
close CMAT;
close CDSMAT;
close IMAT;
close CDSOUT;


sub read_reference
{
my ($header,@seq);
my $fh= FileHandle->new($reffile)|| die "$!";
if ($fh->open("< $reffile")){
   $/=">";
   while (<$fh>){
      $_=~ s/\>//g;
      unless($_){next;};
      ($header,@seq)=split /\n/,$_;
      $ref_sequence= join "",@seq;
      #print length $ref_sequence,"\n";
      $reference= $header;
   }
   $/="\n";
   $fh->close;
}

open (IN,"$refheader")||die "$!";
while (<IN>){
   chomp;
   push(@header_list,"$reference:$_");
   push(@headers,$_);
}
close IN;
}

sub read_gap
{
my ($gap_start,$gap_end);
open (IN, "$gapfile")|| die "$!";
while (<IN>){
   chomp;
   if (/^$reference\s+(\d+)\s+(\d+)\s+(\d+)\s+(\S+)$/){
      ($gap_start,$gap_end)=($1,$2);
      for (my $i=$gap_start;$i<=$gap_end;$i++){$gap_location{$i}++;}
      $query_gaps{$4}+=$3;
   }
}
close IN;

if (-e $noncoding){
   open (IN, "$noncoding")|| die "$!";
   while (<IN>){
      chomp;
      if (/^$reference\s+(\d+)\s+(\d+)\s+\S+$/){
         my ($start,$end)=($1,$2);
         for (my $i=$start;$i<=$end;$i++){$noncoding_location{$i}++;}
      }
   }
}
close IN;
}

sub read_directory
{
my $snp_dir= $indir.'/snps';

opendir(DIR,$snp_dir);
while (my $files= readdir(DIR)){
   next if ($files=~ /^..?$/);
   $snp_file= $snp_dir.'/'.$files;
   SNPcounts($snp_file);
   if ($files=~ /^$name.+snps$/){
      if ($files=~ /contigs.snps$/){
         $snp_file= $snp_dir.'/'.$files;
         contig_nucmer_snp($snp_file);
      }
      else{
         $snp_file= $snp_dir.'/'.$files;
         read_nucmer_snp($snp_file);
      }
   }
   elsif ($files=~/.+\.vcf/){
      $snp_file= $snp_dir.'/'.$files;
      read_vcf_snp($snp_file);
   }
}
}

sub create_ALLsnp_array
{
my $ref=0;
my $current_snp=0;
my $first=0;
my $second=0;
my $CDScount=0;

foreach my $comparison(@header_list){
   $CDScount=0;
   if ($comparison=~/(.+):(.+)/){
      print OUT ">$2\n";
      ($first,$second)=($1,$2);
   }
   foreach (sort {$a<=>$b}keys %snp_location){
      $current_snp=$_ -1;
      if (!defined $gap_location{$_}){ # Check SNP is not present in gaps.
         if (defined $snp_location{$_}{$comparison}){
            print OUT $snp_location{$_}{$comparison};
            $CDScount++;
         }
         else {
            $ref= substr($ref_sequence,$current_snp,1);
            print OUT $ref;
            $CDScount++;
         }# else
      }# gap_location
   }#snp_location
   print OUT "\n";
}#header list
print BASE "Total SNPs:\t$CDScount\n";
}

sub create_CDSsnp_array
{
my $ref=0;
my $current_snp=0;
my $first=0;
my $second=0;
my $CDScount=0;
foreach my $comparison(@header_list){
   $CDScount=0;
   if ($comparison=~/(.+):(.+)/){
      print CDSOUT ">$2\n";
      ($first,$second)=($1,$2);
   }
   foreach (sort {$a<=>$b}keys %snp_location){
      $current_snp=$_ -1;
      #Check SNP is not present in gaps and present in coding region.
      if (!defined $gap_location{$_} && defined $coding_location{$_}){
         if (defined $snp_location{$_}{$comparison}){
            print CDSOUT $snp_location{$_}{$comparison};
            $CDScount++;
         }
         else {
            $ref= substr($ref_sequence,$current_snp,1);
            print CDSOUT $ref;
            $CDScount++;
         }# else
      }# gap_location
   }#snp_location
   print CDSOUT "\n";
}#header list
if ($coding==1){print BASE "CDS SNPs:\t$CDScount\n";}
}

sub create_INTsnp_array
{
my $ref=0;
my $current_snp=0;
my $first=0;
my $second=0;

foreach my $comparison(@header_list){
   if ($comparison=~/(.+):(.+)/){
      print INTOUT ">$2\n";
      ($first,$second)=($1,$2);
   }
   foreach (sort {$a<=>$b}keys %snp_location){
      $current_snp=$_ -1;
      #Check SNP is not present in gaps and present in coding region.
      if (!defined $gap_location{$_} && defined $coding_location{$_}){
         if (defined $snp_location{$_}{$comparison}){print INTOUT $snp_location{$_}{$comparison};}
         else {
            $ref= substr($ref_sequence,$current_snp,1);
            print INTOUT $ref;
         }# else
      }# gap_location
   }#snp_location
   print INTOUT "\n";
}#header list
}

sub create_stats
{
my $ref=0;
my $current_snp=0;
my $first=0;
my $second=0;
my $start=0;
my $end=0;

foreach my $comparison(@header_list){
  if ($comparison=~/(.+):(.+)/){($first,$second)=($1,$2);}
   foreach (sort {$a<=>$b}keys %snp_location){
      $current_snp=$_ -1;
      if (!defined $gap_location{$_}){
         if (defined $snp_location{$_}{$comparison} && $first ne $second){
            $ref= substr($ref_sequence,$current_snp,1);
            if ($coding==1){
               if (!defined $coding_location{$_}){
                  print STAT "$first\t$second\tnoncoding SNP\t$_\t$positions{$_}{$comparison}\t$ref\t$snp_location{$_}{$comparison}\n";
               }
               elsif (defined $coding_location{$_}){
                  my $snp=$_;
                  my ($start,$end,$product)= split /,/, $coding_location{$_};
                 # print "$start\t$end\n";
                  print STAT "$first\t$second\tcoding SNP\t$snp\t$positions{$snp}{$comparison}\t$ref\t$snp_location{$snp}{$comparison}\t$start\t$end\n";
               }
            }
            else{print STAT "$first\t$second\t$_\t$positions{$_}{$comparison}\t$ref\t$snp_location{$_}{$comparison}\n";}
         }
      }
   }
}
}

sub create_comparison
{
my $ref=0;
my $current=0;

foreach (@headers){
   print COMP "\t$_";
}
print COMP "\n";

foreach (sort {$a<=>$b}keys %snp_location){
   $current=$_ -1;
   if (!defined $gap_location{$_}){
      print COMP "$_\t";
      foreach my $comparison(@header_list){
         if (defined $snp_location{$_}{$comparison}){print COMP "$snp_location{$_}{$comparison}\t";}
         elsif(!defined $snp_location{$_}{$comparison}){
            $ref= substr($ref_sequence,$current,1);
            print COMP "$ref\t";
         }
      }
      print COMP "\n";
   }
}
}

sub create_matrix
{
foreach (@headers){
   print PMAT "$_\t";
   print CMAT "$_\t";
   print CDSMAT "$_\t";
   print IMAT "$_\t";
}
print PMAT "\n";
print CMAT "\n";
print CDSMAT "\n";
print IMAT "\n";

foreach my $column(@headers){
   #print "$column\n";
   if ($column!~/contig/ && $column!~/read/){
      print PMAT "$column\t";
      print CMAT "$column\t";
      print CDSMAT "$column\t";
      print IMAT "$column\t";
      foreach my $row(@headers){
         #print "$column:$row\n";
         if ($column eq $row){
            print PMAT "\t";
            print CMAT "\t";
            print CDSMAT "\t";
            print IMAT "\t";
         }
         else{
#         print MAT "$row\t";
            if (defined $pairSNPcount{"$column:$row"}){print PMAT $pairSNPcount{"$column:$row"},"\t";}
            else{print PMAT "0\t";}
           
            if (defined $coreSNPcount{"$column:$row"}){print CMAT $coreSNPcount{"$column:$row"},"\t";}
            else{print CMAT "0\t";}
            
            if (defined $cdsSNPcount{"$column:$row"}){print CDSMAT $cdsSNPcount{"$column:$row"},"\t";}
            else{print CDSMAT "0\t";}

            if (defined $intSNPcount{"$column:$row"}){print IMAT $intSNPcount{"$column:$row"},"\t";}
            else{print IMAT "0\t";}
         }
      }
      print PMAT "\n";
      print CMAT "\n";
      print CDSMAT "\n";
      print IMAT "\n";
   }
}
}

sub SNPcounts
{
my $file=shift;
my $pairCount=0;
my $coreCount=0;
my $cdsCount=0;
my $intCount=0;
my $query_id=0;
my $ref_id=0;
my ($ref_pos,$ref_base,$snp,$snp_pos,$buff,$dist,$ref_direction,$snp_direction);
my ($tmp,$snp_quality,$vcf_info, $vcf_info2);
my ($sname,$spath,$ssuffix)=fileparse("$file",qr/\.[^.]*/);
my $contig=0;

if ($sname=~/contigs$/){$contig=1;}
open (my $fh, $file) or die "$!";
my $header = <$fh>;
while(<$fh>){
   chomp;
   if ($ssuffix =~ /snps/&& $_ =~ /^\d+/){
      ($ref_pos,$ref_base,$snp,$snp_pos,$buff,$dist,$ref_direction,$snp_direction,$ref_id,$query_id)=split /\t/,$_;
#      print "$ref_pos\t$snp_pos\t$ref_id\t$query_id\n";
      $pairCount++;
      if (!defined $gap_location{$ref_pos}){
         $coreCount++;
         if (!defined $coding_location{$ref_pos}){$intCount++;}
         if (defined $coding_location{$ref_pos}){$cdsCount++;}
      }
   }

   if ($ssuffix =~ /vcf/){
      my $depth=0;
      if (/^#CHROM.+\/$reference\_(\S+)\.sort\.bam/){$query_id=$1.'_read';}
      if ($_ !~ /^#/){
         ($ref_id,$ref_pos,$tmp,$ref_base,$snp,$snp_quality,$tmp,$vcf_info,$vcf_info2,$tmp)=split /\t/,$_;
         my @values=split /;/,$vcf_info2;
         if ($values[0]=~/DP=(\d+)/){$depth=$1;}
         if ($snp!~ /\./ && $ref_base!~ /\./ && $vcf_info2!~ /INDEL/ && $depth >=15){
            $pairCount++;
            if (!defined $gap_location{$ref_pos}){$coreCount++;}
            if (!defined $coding_location{$ref_pos}){$intCount++;}
            if (defined $coding_location{$ref_pos}){$cdsCount++;}
         }
      }
   }
}
#print "BEFORE\t$ref_id\t$query_id\t$pairCount\n";
if ($ref_id=~ /(.+)_(\d+)_(\d+)$/){$ref_id=$1;}
#if ($query_id=~ /(.+)_(\d+)_(\d+)$/){$query_id=$1;}
if ($contig==1){
   if ($query_id=~ /(.+)_(\d+)$/){$query_id=$1;}
   $query_id=$query_id.'_contig';
}
else{if ($query_id=~ /(.+)_(\d+)_(\d+)$/){$query_id=$1;}}

#print "AFTER\t$ref_id\t$query_id\t$pairCount\n";
$pairSNPcount{"$ref_id:$query_id"}=$pairCount;
$coreSNPcount{"$ref_id:$query_id"}=$coreCount;
$cdsSNPcount{"$ref_id:$query_id"}=$cdsCount;
$intSNPcount{"$ref_id:$query_id"}=$intCount;
}

sub print_summary
{
my $last=0;
my $first=1;
my $gap_total=0;

foreach my $query(sort keys %query_gaps){
   print BASE "$query\t",$query_gaps{$query},"\n";
}


print BASE "Reference used:\t$name\n";

my ($start,$end);
foreach my $keys(sort{$a<=>$b}keys %gap_location){
   if ($first){$start=$keys;$last=$keys;$first=0;}
   elsif ($last!=$keys-1){
      print GAPF "$start\t$last\n";
      my $gap_length=$last-$start+1;
      $gap_total+=$gap_length;
      $start=$keys;
   }
   $last=$keys;
}
my $base_total= (length $ref_sequence)-$gap_total;
print BASE "Reference sequence length:\t",length $ref_sequence,
"\nTotal gap length:\t$gap_total
Core genome length:\t$base_total\n";

close GAPF;
}

sub contig_nucmer_snp
{
my $count=0;
open (IN,"$snp_file")||die "$!";
while (<IN>){
   chomp;
   if (/^\d/){
      $count++;
      ($rpos,$rbase,$qbase,$qpos,$buff,$dist,$frm,$frm,$ref,$query)= split ("\t",$_);
      if ($query=~/(\S+)_\d+$/){$query= $1.'_contig';}
      if ($qbase!~ /\./ && $rbase!~ /\./ && $ref=~ /$reference/){
         $snp_location{$rpos}{"$ref:$query"}= $qbase;
         $snp_location{$rpos}{"$ref:$ref"}=$rbase;
         $positions{$rpos}{"$ref:$query"}=$qpos;
      }
      else {$gap_location{$rpos}++;}
   }
}
close IN;
}

sub read_nucmer_snp
{
my $count=0;
open (IN,"$snp_file")||die "$!";
while (<IN>){
   chomp;
   if (/^\d/){
      $count++;
      ($rpos,$rbase,$qbase,$qpos,$buff,$dist,$frm,$frm,$ref,$query)= split ("\t",$_);
      if ($query=~ /(.*)\_(\d+)\_\d+$/){
         $query=$1;
         $qpos=$qpos+$2-1;
      }
      if ($ref=~ /(.*)\_(\d+)\_\d+$/){
         $ref=$1;
         $rpos=$rpos+$2-1;
      }
      if ($qbase!~ /\./ && $rbase!~ /\./ && $ref=~ /$reference/){
         $snp_location{$rpos}{"$ref:$query"}= $qbase;
         $positions{$rpos}{"$ref:$query"}=$qpos;
      }
      else {$gap_location{$rpos}++;}
   }
}
close IN;
}

sub read_vcf_snp
{
my $count=0;
my ($id,$qual,$filter,$info1,$info2,$tmp);
my %mapped;
my $depth=15;
open (IN,"$snp_file")||die "$!";
while (<IN>){
   chomp;
   if (/^#CHROM.+\/\S+\/$reference\_(\S+)\.sort\.bam/){$query=$1.'_read';}
   if (!/^\#/){
      ($ref,$rpos,$id,$rbase,$qbase,$qual,$filter,$info1,$info2,$tmp)= split ("\t",$_);
#      print "$ref\t$rpos\t$rbase\t$qbase\t$info1\t$info2\t$tmp\n";
      my @info=split(";",$info1);
#      print "$info[0]\n";
      if ($info[0]=~/.+=(\d+)/){$depth=$1;}
      if ($depth <15){$gap_location{$rpos}++;}
      if ($qbase!~ /\./ && $rbase!~ /\./ && $info1!~ /INDEL/ && $depth>=15){
         if ($ref=~ /(.+)_(\d+)_(\d+)$/){
            $ref= $1;
            my $start=$2;
            if ($start>1){$rpos= $rpos+$start-1;}
         }
         if ($qbase=~ /(\D),(\D)/){
            $qbase=$1; my $temp=$2;
            print AMB "$reference\t$query\t$qbase\t$temp\t$rpos\n";
         }
         else{$snp_location{$rpos}{"$reference:$query"}= $qbase;$count++;}
         $positions{$rpos}{"$ref:$query"}='read';
      }
   }
}
close IN;
}

sub read_cds_coords
{
open (CDS, "$CDScoords")||die "$!";
while (<CDS>){
   chomp;
   my ($id,$start,$end,$product)= split /\s+/,$_;
   for ($start..$end){$coding_location{$_}="$start,$end,$product";}
  # if ($snp>=$start && $snp<=$end){return ($start,$end);}
}
#return ($start,$end);
}

sub usage
{
print STDERR"
Usage:
   $0 -i <in directory> -r <reference filename> -l <query list file> -g <gap filename> -o <output directory>

   -i          in directory name
   -r          reference file
   -l          header list
   -help|h|?   print usage/help
";
exit;
}

