#!/usr/bin/env perl

use strict;
use FindBin qw($RealBin);
use lib "$RealBin";
use lib "$RealBin/../lib/";
use lib "$RealBin/../ext/lib/perl5";
use FileHandle;
use Getopt::Long;
use Parallel::ForkManager;

my $dir;
my $stat;
my $file;
my $list;
my $threads = 1;
my $seq;
my $header;
my @strings;
my $count = 0;
my ( $refid, $queryid, $rpos, $qpos, $snp, $start, $end );
my %coords;
my %genes;
my $fragment;
my @header_list;
my ( $first, $second );
my $gff_file;
my $outfile;
my @indexArray;
my $indexArray;
my %reference;
my $name;
my %alternative;
my $gapfile;
my %gaps;
my $prev = 0;

GetOptions(
    'd|dir=s'    => \$dir,
    's|stat=s'   => \$stat,
    'f|file=s'   => \$file,
    'l|list=s'   => \$list,
    't|thread=i' => \$threads,
    'g|gene=s'   => \$gff_file,
    'p|gap=s'    => \$gapfile,
);
################################################################################
# Checking for maximum threads possible.
my $maxthreads
    = ( $^O =~ /darwin/ )
    ? `sysctl hw.ncpu | awk '{print \$2}'`
    : `grep -c ^processor /proc/cpuinfo`;
if ( $threads < 1 || $threads > $maxthreads ) {
    die("-thread value must be between 1 and $maxthreads.\n");
}
################################################################################
# create PS gene directory if it doesnt exist
my $genedir = $dir . '/PSgenes';
if ( !-d $genedir ) { `mkdir $genedir`; }

# create threads
my $pm = new Parallel::ForkManager($threads);
$pm->run_on_finish( sub { my ( $pid, $ident ) = @_; } );
# open gap file
open( IN, $gapfile ) || die "$!";
while (<IN>) {
    chomp;
    my ( $gapstart, $gapend ) = split " ", $_;
    my $length = $gapend - $gapstart;

      # print "$temp1\t$gapstart\t$gapend\t$length\t$temp2\n";
    if ( $length >= 100 ) { $gaps{$gapstart} = $gapend; }
}

################################################################################
# parse fasta file of reference genome
my $fh = FileHandle->new($file) || die "$!";
if ( $fh->open("< $file") ) {
    $/ = ">";
    while (<$fh>) {
        $_ =~ s/\>//g;
        unless ($_) { next; }
        ( $header, @strings ) = split /\n/, $_;
        $seq = join "", @strings;
        $reference{$header} = $seq;
        $name = $header;

             # print "$name\n$seq\n";
    }
    $/ = "\n";
    $fh->close;
}
################################################################################
# parse gff file of reference genome
my $fh1 = FileHandle->new($gff_file) || die "No GFF file found!";
if ( $fh1->open("< $gff_file") ) {
    while (<$fh1>) {
        chomp;
        next if (/^#/);
        my @array = split /\t/, $_;
        if ( scalar(@array) == 9 ) {

            #$id,$source,$type,$start,$end,$score,$strand,$phase,$Attributes
            my $chromosome_id = $array[0];
            my $type          = $array[2];
            my $start         = $array[3];
            my $end           = $array[4];
            my $strand        = ( $array[6] eq '+' ) ? 1 : -1;
            my $Attributes    = $array[8];
            if ( $type eq "CDS" ) {
                my %annotations = map { split /=/; } split /;/, $Attributes;
                my $gene_id = $annotations{"ID"} || $annotations{"Name"};
                $gene_id =~ s/\W/_/g;
                # gets strand information and names of genes
                $genes{"$start:$end"}->{id}     = $gene_id;
                $genes{"$start:$end"}->{strand} = $strand;
                
            }
        }

    }
    $fh1->close;
}
################################################################################
# read in the working_list.txt file
open( LIST, "$list" ) || die "$!";
while (<LIST>) {
    chomp;
    push( @header_list, "$name:$_" );

      # print "$name:$_\n";
}
close LIST;
################################################################################
# read in the SNP stats file
open( IN, "$stat" ) || die "$!";
my $stat_header = <IN>;
while (<IN>) {
    chomp;
    my ($refid, $queryid, $type,  $rpos, $qpos,
        $rbase, $qbase,   $start, $end
    ) = split /\t/, $_;
    if ( $type eq "coding SNP" ) {
        if ( $start == 0 ) { $start = 1; }
        if ( abs $start - $end > 300 ) {

            # print "$start\t$end\n";
            $coords{"$start:$end"} = $start;
            $alternative{$rpos}{"$refid:$queryid"} = $qbase;
        }
    }
}
close IN;
################################################################################

my $temp       = keys %coords;
my $size       = length $temp;
my $index_file = $genedir . '/gene_index.txt';
my $gapgenes   = $genedir . '/gene_gaps.txt';
my $compliment;

open( GAP, ">$gapgenes" ) || die "$!";
OUTER:
foreach my $coord ( sort { $coords{$a} <=> $coords{$b} } keys %coords ) {
    my ( $start, $end ) = $coord =~ /(\d+):(\d+)/;
    # print "$start\n";

    foreach my $gap ( keys %gaps ) {
        if ( $gap >= $start && $gaps{$gap} <= $end ) {
            if ( $gaps{$gap} - $gap % 3 != 0 ) {
                print GAP
                    "Gene with coords $start\_$end has a gap from $gap to $gaps{$gap} in the middle.\n";
                next OUTER;
            }
        }
        if ( $gap < $start && $gaps{$gap} > $start && $gaps{$gap} < $end ) {
            if ( $gaps{$gap} - $start % 3 != 0 ) {
                print GAP
                    "Gene with coords $start\_$end has a gap from $start to $gaps{$gap} in the beginning.\n";
                next OUTER;
            }
        }
        if ( $gap > $start && $gap < $end && $gaps{$gap} > $end ) {
            if ( $end - $gap % 3 != 0 ) {
                print GAP
                    "Gene with coords $start\_$end has a gap from $gap to $end at the end.\n";
                next OUTER;
            }
        }
    }

    $count++;
    my $gene_id = $genes{"$start:$end"}->{id};
    $outfile = "$genedir/${gene_id}_${start}_${end}.fna";

    #$outfile=$genedir.'/Gene';
    #$outfile.=sprintf "%0${size}d", $count;
    my $index = sprintf "%0${size}d", $count;

    #$outfile.='.fna';
    #   print "$index\n";
    push( @indexArray, "$index\t$gene_id\t$start\t$end" )
        if ( $genes{"$start:$end"} );
    $pm->start and next;
    open( my $fh, ">$outfile" ) || die "$!";

    # parsing through the working_list.txt file, @header_list contains lines from working_list.txt
    foreach my $comparison (@header_list) {
        # print "$comparison\n\n";
        # $comparison string contains following
        # "KJ660347_2_ebolavirus_GIN_Gueckedou_C07:KR653305_1_Zaire_ebolavirus_isolate_Ebola_virus_H_sapiens_wt_SLE_2014_Makona_20141043__partial_genome_contig"
        if ( $comparison =~ /(.+):(.+)/ ) {
            ( $first, $second ) = ( $1, $2 );
            print $fh ">$second\n";
            }


        if ( $genes{"$start:$end"} ) {
            my $gene_len = $end - $start + 1;
            # subsets nucleotide using gene coordinates

            my $gene = substr( $reference{$name}, $start - 1, $gene_len );
            # print "$name\nname";
            # print "$reference{$name}\n";
            # print "$gene\n\n";
            #         print "$entry\n";
            my $strand = $genes{"$start:$end"}->{strand};
            # print "$strand\n";

            #            print "$first\t$start\t$end\n";
            foreach my $position ( sort { $a <=> $b } keys %alternative ) {
                if ( defined $alternative{$position}{$comparison} ) {
                    if ( $position >= $start && $position <= $end ) {
                        my $snp = $position - $start;

#                     print "$start\t$end\t$position\t$snp\t",$alternative{$position}{$comparison},"\n";
                        substr( $gene, $snp, 1,
                            $alternative{$position}{$comparison} );
                    }
                }
            }
            if ( $strand < 0 ) {
                $compliment = reverse($gene);
                $compliment =~ tr/ACGTacgt/TGCAtgca/;
                $gene = $compliment;
            }
            print $fh "$gene\n";

            #            print "$gene\n";
        }
    }
    close $fh;
    $pm->finish;
}
$pm->wait_all_children;

$indexArray = @indexArray;
if ($indexArray == 0 ){
    print "All the genes have gaps. No Molecular Evolutionary analyses will be performed\n";
    print "Exiting!\n";
    exit 42;
}

open( IND, ">$index_file" ) || die "$!";
foreach my $index (@indexArray) { print IND $index, "\n"; }
close IND;
close GAP;
