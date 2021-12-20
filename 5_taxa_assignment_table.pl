#!/usr/bin/perl
use diagnostics;
use warnings;
use strict;

my $arq1 = $ARGV[0]; #Blast_results_formatted2OTUtable.tab
my $prefix = $ARGV[1]; #prefix to taxa assignment output
open (MYFILE, $arq1);
my @file = <MYFILE>;
close (MYFILE);
open(NEW_FILE, ">", "${prefix}_OTU_tax_assignments_tmp.txt") or die "Couldn't open: $!";

print NEW_FILE "amplicon\tKingdom\tPhylum\tClass\tOrder\tFamily\tGenus\tSpecies\tSIM\tOTU_abundance\n";
my @new_file=();
	foreach my $line (@file) {
		chomp ($line);
		my @fields = split (/\t/, $line);
		my @lineage = split (/\|/, $fields[3]);
		if (scalar @lineage == 7)	{
			my @species = split (/\+/, $lineage[6]);
			if (scalar @species == 2)       {
			push (@new_file, ("$fields[0]\t$lineage[0]\t$lineage[1]\t$lineage[2]\t$lineage[3]\t$lineage[4]\t$lineage[5]\t$species[1]\t$fields[2]\t$fields[1]\n"));
			}
			else	{
				if (length($fields[4]))	{
				push (@new_file, ("$fields[0]\tNA\tNA\tNA\tNA\tNA\tNA\t$fields[4]\t$fields[2]\t$fields[1]\n"));
				}
				else	{
				push (@new_file, ("$fields[0]\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\t$fields[1]\n"));
				}	
			}
		}
		else	{
		if (length($fields[4])) {
		push (@new_file, ("$fields[0]\tNA\tNA\tNA\tNA\tNA\tNA\t$fields[4]\t$fields[2]\t$fields[1]\n"));
		}
		else	{
		push (@new_file, ("$fields[0]\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\t$fields[1]\n"));
		}
		}
	}
	print NEW_FILE @new_file;
	

