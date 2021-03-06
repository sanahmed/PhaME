#!/usr/bin/env perl

use strict;
use warnings;
use FileHandle;

package PhaME;

# Rune some checks
# Check for first time run 
# Check if the previous run finished properly 

sub check
{
my $dir=shift;
my $refdir=shift;
my $time=shift;
my $data=shift;
my $reference=shift;
my $log=shift;
my $list=$dir.'/working_list.txt';
my $wdir=$dir.'/results';
my $progress=0;
my $alignment=0;
my %refcheck;

if ($time==1){
   if (-e $log && !-z $log){
      open (LOG,"$log")||die "$!";
      while (<LOG>){
         chomp;
         if (/NUCmer on all reference genomes complete/){$progress=1;}
         if (/NUCmer on all contig\/draft genomes complete/){$progress=2;}
         if (/Read Mapping complete/){$progress=3;}
         if (/SNP alignment complete/){$progress=4;$alignment=1;}
         if (/Tree phylogeny complete/ && $alignment==1){$progress=5;}
      }
   }

   if (-e $log && $data<=2){
      if ($progress==3){return($progress);}
      if ($progress<3){
         print "\n\tWarning: Previous run not complete.\n\t";
         return($progress);
      }
   }
   if (-e $log && $data>=3 && $data<=5){
      if ($progress==4){return($progress);}
      if ($progress<4){
         print "\n\tWarning: Previous run not complete.\n\t";
         return($progress);
      }
   }
   if (-e $log && $data==6){
      if ($progress==5){return($progress);}
      if ($progress<5){
         print "\n\tWarning: Previous run not complete.\n\t";
         return($progress);
      }
   }
   if (!-e $log){return("0");}
} # time==1

# Check if all snps and gaps files are present in appropriate directories
if ($time==2){
#print "This is the 2nd time around!\n";
   my $snpdir="$wdir/snps";
   my $gapdir="$wdir/gaps";
   if (!-e $list){
      print "\n$list not found.\nChange control file to run the entire pipeline.\n";
      return("1");
   }
   else{
      open (LIST,$list);
      while (<LIST>){
         chomp;

         my $snpsfile= "$snpdir/$reference\_$_.snps";
         my $gapsfile= "$gapdir/$reference\_$_.gaps";
         if (/contig/){
            $snpsfile="$snpdir/$reference\_$_"."s.snps";
            $gapsfile= "$gapdir/$reference\_$_"."s.gaps";
         }
         if (/(.+)_p|sread/){
            $snpsfile="$snpdir/$reference\_$1.vcf";
            $gapsfile=glob "$gapdir/$reference\_$1\_$reference*.gaps"; 
         }
#         $refcheck{$_}++;
         if ($reference ne $_ && !-e $snpsfile){
            print "$snpsfile\n";
            print "\nsnps directory not complete.\nChange control file to finish previous run.\n";
            return("1");
         }
         if ($reference ne $_ && !-e $gapsfile){
            print "$gapsfile\n";
            print "\ngaps directory not complete.\nChange control file to finish previous run.\n";
            return("1");
         }
      }
      return("0");
   }
   close LIST;
} # time==2
} # sub check

# Concatenate multiple reference chromosomes from one genome into one mega chromosome 
# Saves them in a separate directory "/files" under the working directory 
# Returns the name of the genome file and the total length of the genome
sub prepareComplete
{
my $wdir=shift;
my $file=shift;
my $name=shift;
my $sequence;

#print "$name\t$wdir/files/$name.fna\n";

open (OUT,">$wdir/files/$name.fna")||die "$!";
print OUT ">$name\n";
open (IN,$file)||die "$!";
while (<IN>){
   chomp;
   if (!/^>/){$sequence.=$_;}#print OUT $_;}
}
print OUT "$sequence\n";;
close OUT;
close IN;
return $name,length $sequence;
} # prepareComplete

# Change contigs names
# Savers them in a separate directory "\files" under the working directory
# Returns the name of the contig file and the number of contigs present
sub prepareContig
{
my $dir=shift;
my $file=shift;
my $name=shift;
my ($header,@seq);
my $sequence;
my $count=1;
my $contig=$name.'_contig';
my $outfile=$dir.'/files/'.$name.'_contigs.fna';

#print "$contig\t$outfile\n";

open (OUT, ">$outfile")||die "$!";
my $fh=FileHandle->new($file)|| die "$!";
if ($fh->open("<$file")){
   $/=">";
   while (<$fh>){
      $_=~ s/\>//g;
      unless($_){next;};
      ($header,@seq)=split /\n/,$_;
      $sequence= join "",@seq;
      $header= $name.'_'.$count;
#      print ">$header\n$sequence\n";
      print OUT ">$header\n$sequence\n";
      $count++;
   }
   $/="\n";
   $fh->close;
   close OUT;
}
return $contig,$count;
}

# Identifies gap coords in reference genomes
# Gaps identified in NUCmer
sub identifyGaps
{
my $dir=shift;
my $list=shift;
my $name=shift;
my $type=shift;
my $project=shift;
my $gapdir=$dir.'/gaps';
my $repeatdir=$dir.'/stats';
my %query;
my $line=0;
my $gapfile;
my $gap_start;
my $gap_end;

if ($type=~/map/){$gapfile="$dir\/$project\_mapping_gaps.txt";}
elsif ($type=~/snp/){$gapfile="$dir\/$project\_all_gaps.txt";}
open (GAP,">$gapfile")||die "$!";

open (LIST,"$list")||die "$!";
while (<LIST>){
   chomp;
   $query{$_}++;
}
close LIST;

opendir(DIR,"$gapdir");
while (my $gaps= readdir(DIR)){
#   if ($gaps=~ /^$name\_(.+)\_norepeats\.gaps/ || $gaps=~ /^$name\_(.+_contig)s\.gaps/ && $gaps!~ /^$name\_norepeats/){
   if ($gaps=~ /^$name\_norepeats\_(.+)\_norepeats\.gaps/ || $gaps=~ /^$name\_(.+_contig)s\.gaps/ ||$gaps=~ /^$name\_(.+)\.gaps/ ){
      if (exists $query{$1}){
         $line=0;
         my $gapfile= "$gapdir/$gaps";
         open (IN,$gapfile)|| die "$!";
#         print "Nucmer Gaps\n";
         while (<IN>){$line++; print GAP "$_";}
         close IN;
         if ($line ==0){print "Empty File: $gapfile\n"; $line=0;}
      }
   }
   if ($type=~/snp/){
#      if ($gaps=~ /^$name\_norepeats\_(.+)\_?$name?\_?[\d+\_\d+]?\.gaps$/){
      if ($gaps=~ /^$name\_(.+)\_$name(\_\d+\_\d+)?\.gaps$/){
         my $query=$1;
         my $tmp= $query.'_read';
         if (exists $query{$tmp}){
            $line=0;
            my $gap_file= "$gapdir/$gaps";
            open (IN,$gap_file)|| die "$!";
#         print "Read Mapping Gaps\n";
            while (<IN>){
               chomp;
               $line++;
               next if (/Start\s+End\s+Length.+/);
               my ($start,$end,$length,$ref)= split "\t",$_;
               if ($ref=~ /$name\_(\d+)\_(\d+)$/){
                  $gap_start=$start+$1-1;
                  $gap_end=$1+$end-1;
               }
               else{
                  $gap_start=$start-1;
                  $gap_end=$end;
               }
               print GAP "$name\t$gap_start\t$gap_end\t$length\tREADS_$query\n";
            }
            close IN;
            if ($line == 1){`rm $gapfile`; $line=0;}
         }
      }
   }
#   last OUTER;
}
closedir DIR;

opendir(REPEAT,"$repeatdir");
while (my $repeats= readdir(REPEAT)){
   if ($repeats=~ /$name\_repeat_coords\.txt/){
#      print "$repeats\n";
#   if ($gaps=~ /repeats_coords\.txt/){
      my $repeatfile= "$repeatdir/$repeats";
      open (IN,$repeatfile)|| die "$!";
#      print "Repeats\n";
      while (<IN>){
         chomp;
         my ($ref,$temp,$start,$end,$length)= split "\t",$_;
         print GAP "$ref\t$start\t$end\t$length\tREPEATS\n";
      }
      close IN;
   }
#   last OUTER;
}
closedir REPEAT;
return $gapfile;
}

# Identify CDS coords 
sub codingRegions
{
my $dir=shift;
my $annotation=shift;
my $name=shift;
my $start;
my $end;
my $gap_start=1;
my $gap_end;
my $source_start=1;
my $source_end=0;
my %CDS;
my $line;
my $temp;

my $outfile=$dir."/noncoding.txt";
my $coding=$dir."/CDScoords.txt";

open (OUT,">$outfile");
open (CDS,">$coding");

my $first=1;
my $permutation=0;

open (IN, "$annotation")|| die "$!";
while(<IN>){
   chomp;
   if (/##sequence-region/){
      $permutation=$permutation+$source_end;
      ($line,$temp,$source_start,$source_end)=split " ",$_;
   }
   if (!/^#/){
      my ($name,$source,$method,$start,$stop,$score,$strand,$phase,$field)=split "\t",$_;
#      my ($name,$method,$start,$stop,$score,$strand,$phase,$field)=split "\t",$_;
      my @group=split ";",$field;

      if ($method=~/CDS/){
         $start=$start+$permutation;
         $stop=$stop+$permutation;

         print CDS "$name\t$start\t$stop\t";
         $CDS{$start}=$stop;
         foreach (@group){if (/product=(.+)/ || /description=(.+)/){print CDS $1;}}
         print CDS "\n";
      }
   }
}

my $prev=0;
foreach my $begin (sort{$a<=>$b} keys %CDS){
   my $end=$CDS{$begin};
   if ($first){
      if ($begin==1){$gap_start=$end+1;}
      else{
         $gap_end=$begin-1;
         if ($gap_start<$gap_end){print OUT "$name\t$gap_start\t$gap_end\tnoncoding\n";}
      }
      $first =0;
   }
   else {
      $gap_end=$begin-1;
      if ($gap_start<$gap_end){print OUT "$name\t$gap_start\t$gap_end\tnoncoding\n";}
   }
   if ($begin==$prev){
      $gap_start=$prev-1;
      $gap_end=$prev-1;
      print OUT "$name\t$gap_start\t$gap_end\tnoncoding\n";
   }

   $gap_start=$end+1;
   $prev=$end+2;
}
}

sub clean
{
my $dir=shift;
print "\nHERE IS WHERE I CLEAN THIS MESS\n";
my @cleanup=glob("$dir/*.pileup");
if (scalar @cleanup >0){foreach (@cleanup){`rm $_`;}}
@cleanup=glob("$dir/*.bam");
if (scalar @cleanup >0){foreach (@cleanup){`rm $_`;}}
@cleanup=glob("$dir/*.bcf");
if (scalar @cleanup >0){foreach (@cleanup){`rm $_`;}}
@cleanup=glob("$dir/*.mgaps");
if (scalar @cleanup >0){foreach (@cleanup){`rm $_`;}}
@cleanup=glob("$dir/*.ntref");
if (scalar @cleanup >0){foreach (@cleanup){`rm $_`;}}
@cleanup=glob("$dir/*.sam");
if (scalar @cleanup >0){foreach (@cleanup){`rm $_`;}}
@cleanup=glob("$dir/*.delta");
if (scalar @cleanup >0){foreach (@cleanup){`rm $_`;}}
@cleanup=glob("$dir/*filter");
#foreach (@cleanup){print "$_\n";}
if (scalar @cleanup >0){foreach (@cleanup){`rm $_`;}}
}

#-------------------------------------------------------------------------
#  SCRIPT RUNNERS

# Run NUCmer on reference genomes 
sub completeNUCmer
{
my $indir=shift;
my $bindir=shift;
my $list=shift;
my $code=shift;
my $thread=shift;
my $error=shift;
my $log=shift;
my $outdir=$indir.'/results';

print "\n";
my $nucmer="$bindir/runNUCmer.pl -q $indir -d $outdir -t $thread -l $list -c $code 2>$error > $log\n\n";
print $nucmer;
if (system ($nucmer)){die "Error running $nucmer.\n";}
}

# Run NUCmer on contigs
# Needs a reference
sub contigNUCmer
{
my $indir=shift;
my $bindir=shift;
my $list=shift;
my $code=shift;
my $thread=shift;
my $reference=shift;
my $type=shift;
my $error=shift;
my $log=shift;
my $outdir=$indir.'/results';

print "\n";
my $con_nucmer="$bindir/runContigNUCmer.pl -r $reference -q $indir -d $outdir -l $list -t $thread -y $type 2>>$error >> $log\n\n";
print $con_nucmer;
if (system ($con_nucmer)){die "Error running $con_nucmer.\n";}
}

# Removes gaps using a gap file
sub removeGaps
{
my $bindir=shift;
my $reference=shift;
my $readgaps=shift;

print "\n";
my $remove="time $bindir/removeGaps.pl $reference $readgaps\n\n";
print $remove;
if (system ($remove)){die "Error running $remove.\n";}
}

# Runs bowtie on paired-end reads
sub readsMapping
{
my $indir=shift;
my $bindir=shift;
my $list=shift;
my $thread=shift;
my $name=shift;
my $error=shift;
my $log=shift;
my $outdir=$indir."/results";
my $reference= $outdir.'/temp/'.$name.'.fna';
my $type;

if(!-e $reference){$indir.'/'.$name.'.fna';}
print "\n";
my $map="$bindir/runReadsMapping.pl -r $reference -q $indir -d $outdir -t $thread -l $list -a bowtie 2>>$error >> $log\n\n";
print $map;
if (system ($map)){die "Error running $map.\n";}

opendir (CLEAN, "$outdir");
while (my $file= readdir(CLEAN)){
   if ($file=~/.+\.vcf$/){
      my $vcf_file=$outdir.'/'.$file;
      `mv $vcf_file $outdir/snps`;
      print "Moved $file to the snps directory\n";
   }
}
closedir CLEAN;
return ("Read Mapping complete");
}

sub buildSNPDB
{
my $outdir=shift;
my $bindir=shift;
my $reference=shift;
my $list=shift;
my $project=shift;
my $signal=shift;
my $error=shift;
my $log=shift;

print "\n";
my $SNPdb="$bindir/buildSNPDB.pl -i $outdir -r $reference -l $list -p $project -c $signal 2>>$error >> $log\n\n";
print $SNPdb;
if (system ($SNPdb)){die "Error running $SNPdb.\n";}
return ("SNP database complete");
}

sub modeltest
{
my $outdir=shift;
my $file=shift;
my $threads=shift;
my $error=shift;
my $log=shift;

my $infile=$outdir."/$file\_all_snp_alignment.fna";
my $outfile=$outdir."/$file\_modelTest.txt";

my $modeltest= "java -jar /users/252891/scratch/tools/jmodeltest-2.1.2/jModelTest.jar -d $infile -f -i -g 4 -s 11 -AIC -a -tr $threads > $outfile\n\n";
if (system ($modeltest)){die "Error running $modeltest.\n";}

return ("SNP alignemnt complete");
}

sub buildTree
{
my $bindir=shift;
my $outdir=shift;
my $thread=shift;
my $tree=shift;
my $name=shift;
my $error=shift;
my $log=shift;

if ($tree==1||$tree==3){
   print "\n";
   my $fasttree="$bindir/FastTree/FastTreeMP -nt -gtr < $outdir/$name\_snp_alignment.fna > $outdir/$name\.fasttree >>$error\n\n";
   print $fasttree;
   if (system ($fasttree)){die "Error running $fasttree.\n";}
}
if ($tree==2||$tree==3){
   print "\n";
   my $raxml="$bindir/RAxMLmaster/raxmlHPC-PTHREADS -p 10 -T $thread -m GTRGAMMAI -s $outdir/$name\_snp_alignment.fna -w $outdir -n $name 2>>$error >> $log\n\n";
   print $raxml;
   if (system ($raxml)){die "Error running $raxml.\n";}
}
open (OUT, ">>$log");
print OUT "Tree phylogeny complete.\n";
close OUT;

if ($tree==1){return ("Fasttree phylogeny complete");}
if ($tree==2){return ("RAxML phylogeny complete");}
if ($tree==3){return ("Phylogeny complete");}
}

sub bootstrap
{
my $bindir=shift;
my $outdir=shift;
my $thread=shift;
my $tree=shift;
my $name=shift;
my $bootstrap=shift;
my $error=shift;
my $log=shift;

if ($tree==1){
   my $bootTrees="$bindir/RAxMLmaster/raxmlHPC-PTHREADS -p 10 -T $thread -m GTRGAMMAI -b 10000 -t $outdir/$name\.fasttree -s $outdir/$name\_snp_alignment.fna -w $outdir -N $bootstrap -n $name\_b -k 2>>$error >> $log\n\n";
   print $bootTrees;
   if (system ($bootTrees)){die "Error running $bootTrees.\n";}

   my $bestTree="$bindir/RAxMLmaster/raxmlHPC-PTHREADS -p 10 -T $thread -f b -m GTRGAMMAI -t $outdir/$name\.fasttree -s $outdir/$name\_snp_alignment.fna -z $outdir/RAxML_bootstrap.$name\_b -w $outdir -n $name\_best 2>>$error >> $log\n\n";
   print $bestTree;
   if (system ($bestTree)){die "Error running $bestTree.\n";}
}

if ($tree=>2){
   my $bootTrees="$bindir/RAxMLmaster/raxmlHPC-PTHREADS -p 10 -T $thread -m GTRGAMMAI -b 10000 -t $outdir/RAxML_bestTree.$name -s $outdir/$name\_snp_alignment.fna -w $outdir -N $bootstrap -n $name\_b -k 2>>$error >> $log\n\n";
   print $bootTrees;
   if (system ($bootTrees)){die "Error running $bootTrees.\n";}
   my $bestTree="$bindir/RAxMLmaster/raxmlHPC-PTHREADS -p 10 -T $thread -f b -m GTRGAMMAI -t $outdir/RAxML_bestTree.$name -s $outdir/$name\_snp_alignment.fna -z $outdir/RAxML_bootstrap.$name\_b -w $outdir -n $name\_best 2>>$error >> $log\n\n";
   print $bestTree;
   if (system ($bestTree)){die "Error running $bestTree.\n";}

}
return ("Bootstrap complete");
}

sub extractGenes
{
my $dir=shift;
my $stat=shift;
my $file=shift;
my $bindir=shift;
my $list=shift;
my $thread=shift;
my $gapfile=shift;
my $genefile=shift;
my $error=shift;
my $log=shift;
my $genedir=$dir.'/PSgenes';

print "\n";
my $extract="$bindir/extractGenes.pl -d $dir -t $thread -l $list -s $stat -f $file -p $gapfile -g $genefile 2>>$error >> $log\n\n";
print $extract;
if (system ($extract)){die "Error running $extract.\n";}

opendir (DIR,"$genedir") ||die "$!";
OUTER:while (my $files= readdir(DIR)){
   next if ($files=~/^..?$/);
   if ($files=~ /.+\.fna$/){
      my $file= $genedir.'/'.$files;
      open (IN,"$file")|| die"$!";
      while (<IN>){
         if (!/^>/){
            if (!/^ATG/){
               print "$file\n";
               `rm $file`;
               next OUTER;
            }
         }
      }
      close IN;
   }
}
close DIR;
return ("Genes with SNPs in PSgenes Directory");
}

sub translateGenes
{
my $dir=shift;
my $bindir=shift;
my $thread=shift;
my $program=shift;
my $error=shift;
my $log=shift;
my $genedir=$dir.'/PSgenes';

print "\n";
my $translate="$bindir/parallel_run.pl -d $genedir -t $thread -m $program 2>>$error >> $log\n\n";
print $translate;
if (system ($translate)){die "Error running $translate.\n";}

return ("Gene translation complete");
}

sub alignGenes
{
my $dir=shift;
my $bindir=shift;
my $thread=shift;
my $program=shift;
my $error=shift;
my $log=shift;
my $genedir=$dir.'/PSgenes';

print "\n";
my $align="$bindir/parallel_run.pl -d $genedir -t $thread -m $program 2>>$error >> $log\n\n";
print $align;
if (system ($align)){die "Error running $align.\n";}

return ("MSA complete");
}


sub revTransGenes
{
my $dir=shift;
my $bindir=shift;
my $thread=shift;
my $program=shift;
my $error=shift;
my $log=shift;
my $genedir=$dir.'/PSgenes';

my $revTrans="$bindir/parallel_run.pl -d $genedir -t $thread -m $program 2>>$error >> $log\n\n";
print $revTrans;
if (system ($revTrans)){die "Error running $revTrans.\n";}

return ("Codon MSA complete");
}

sub core
{
my $dir=shift;
my $bindir=shift;
my $output=shift;
my $error=shift;
my $log=shift;
my $genedir=$dir.'/PSgenes';

my $core="$bindir/catAlign.pl $genedir $output 2>>$error >> $log\n\n";
print $core;
if (system ($core)){die "Error running $core.\n";}

return ("Core gene alignment complete"); 
}

sub paml
{
my $dir=shift;
my $bindir=shift;
my $tree=shift;
my $model=shift;
my $suffix=shift;
my $NSsites=shift;
my $core=shift;
my $thread=shift;
my $error=shift;
my $log=shift;
my $branch=1;
my $pamldir=$dir.'/paml';

if ($model==0){
   print "\n";
   my $ps="time $bindir/runPAML.pl -i $dir -t $thread -r $tree -m $model -n $NSsites -s $suffix -c $core 2>>$error >> $log\n\n";
   print $ps;
   if (system ($ps)){die "Error running $ps.\n";}

   `mv $pamldir/*/*$suffix $pamldir`;
   print "\n";
   my $parse="time $bindir/parseSitePAML.pl $pamldir $NSsites 2>>$error >> $log\n\n";
   print $parse;
   if (system($parse)){die "Error running $parse. \n";}
}

if ($model==2){
   print "\n";
   my $edit="time $bindir/ParseTree.pl $tree 2>>$error >> $log\n\n";
   print $edit;
   if (system ($edit)){die "Error running $edit.\n";}

   print "\n";
   my $ps="time $bindir/runPAML.pl -i $dir -t $thread -r $tree -m $model -n $NSsites -s $suffix -c $core 2>>$error >> $log\n\n";
   print $ps;
   if (system ($ps)){die "Error running $ps.\n";}

   `mv $pamldir/*/*$suffix $pamldir`;
   print "\n";
   my $parse="time $bindir/parseSitePAML.pl $pamldir 0,1,2,7,8,$NSsites 2>>$error >> $log\n\n";
   print $parse;
   if (system($parse)){die "Error running $parse. \n";}

}
}

sub hyphy
{
my $dir=shift;
my $bindir=shift;
my $tree=shift;
my $outtree=shift;
my $core=shift;
my $threads=shift;
my $analysis=shift;
my $error=shift;
my $log=shift;

$threads=$threads/2;

my $hyphy="$bindir/runHyPhy.pl -i $dir -t $threads -r $tree -o $outtree -c $core -a bsrel 2>>$error >> $log\n\n";
print $hyphy;
if (system($hyphy)){die "Error running $hyphy. \n";}
}

1;
