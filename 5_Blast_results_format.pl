#!/usr/bin/perl
use diagnostics;
use warnings;
use strict;

my $INPUT = $ARGV[0];
open (MYFILE, $INPUT);
my @file = <MYFILE>;
close (MYFILE);


open (NEW_FILE, '>>Blast_results_formatted2OTUtable_tmp.tab');
my @new_file=();
        foreach my $line (@file) {
                my @fields = split (/\s+/, $line);
		my @seqid = split (/_/, $fields[0]);
		my $abundance = $seqid[1];
		my @acc = split (/\|/, $fields[3]);
		push (@new_file, ("$seqid[0]\t$abundance\t$fields[1]\t$fields[2]\t$acc[1]\t$fields[4]\n"));
         }
print NEW_FILE @new_file;



