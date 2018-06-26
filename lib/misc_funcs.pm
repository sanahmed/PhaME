#!/usr/bin/env perl

use strict;
use warnings;
use FileHandle;
use File::Basename;
use Cwd;

package misc_funcs;

sub read_directory {
    my $workdir = shift;
    my @skip_list = @_;
    my @query;
    my $query_file;
    
    if ( $workdir =~ /.+\/$/ ) { my $temp = chop($workdir); }
    $workdir = $workdir . '/files';

    opendir( my $dh, $workdir )|| die "Can't opendir $workdir: $!";
    my @files_list = readdir($dh);
    foreach $_ (@files_list) {
        next if ( $_ =~ /^..?$/ );
        next if ( $_ =~ /contig/ );
        if ( $_ =~ /(.+)\.fna$/ ) {
            next if ( $_ ~~ @skip_list);
            $query_file = $workdir . '/' . $_;
            push @query, $query_file;
                }
        }
    closedir $dh;
    return @query;
}

1;