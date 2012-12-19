#! /usr/bin/perl
use warnings;
use strict;


my @files = <*>;

system ("dos2unix baits.txt"); 
foreach my $file (@files) {
	if(($file =~ /combined_peaks.gff3$/) or ($file =~ /combined.gff3$/)){
		print "\nprocessing $file...\n";
		system ("perl analysis.pl baits.txt $file");
	}

}  

