use strict;
use warnings;
use POSIX;
use Data::Dumper;

my $baits = $ARGV[0];
my $mod_encode = $ARGV[1];

open(OUT,">"."results.txt");

sub bait_info($){
	my %mod_encode_hash=();
	my $mod_encode = shift;
	my $mod_encode_name = 0;
	my $line = 0;
	open (BAIT, $baits) or die $!;	
	my $position = 0;
	while($line = <BAIT>){  
		next if($line =~ m/#/);
		chomp($line); 	
		#Contents of the file.
		my @temp = split(/\t/, $line);		
		my $number = "CHROMOSOME"."_".$temp[0];
		my $start = $temp[3]; 
		my $stop = $temp[4];
		$mod_encode_hash{$position} = $mod_encode."|".$number."|".$start."|".$stop;
		$position ++;
				#print "$mod_encode\n";
	}	
	return(\%mod_encode_hash,$mod_encode);
	close (BAIT);
}
my $bait_info = [];
($bait_info)=&bait_info($baits);

sub mod_encode_data($){
	my %mod_encode_hash=();
	my $mod_encode = shift;
	my $mod_encode_name = 0;
	my $line = 0;
	open (MODENCODE, $mod_encode) or die $!;	
	my $position = 0;
	while($line = <MODENCODE>){  
		next if($line =~ m/#/);
		chomp($line); 	
		#Contents of the file.
		my @temp = split(/\t/, $line);		
		my $number = "CHROMOSOME"."_".$temp[0];
		my $start = $temp[3]; 
		my $stop = $temp[4];
		$mod_encode_hash{$position} = $mod_encode_name."|".$number."|".$start."|".$stop;
		$position ++;
	}	
	return(\%mod_encode_hash,$mod_encode);
	close (MODENCODE);
}

my $mod_encode_hash = [];
($mod_encode_hash)=&mod_encode_data($mod_encode);


sub compare($$$){
my $bait_info = [];
my $mod_encode_hash = [];
my $key_bait = 0;
my $key_modencode = 0;
my $mod_encode = 0;
$bait_info = shift;
$mod_encode_hash = shift;
$mod_encode = shift;
		my $counter = 0;
	foreach $key_bait ( keys %$bait_info ) {

		my $holder = 0;
		my $midpoint = 0;
		my $baitfile = $bait_info->{$key_bait};
		my ($bait_name,$chromosomeB,$startB,$stopB) = split(/\|/,$baitfile);

		foreach $key_modencode ( keys %$mod_encode_hash ) {
			my $modencodefile = $mod_encode_hash->{$key_modencode};
			my ($mod_encode_name,$number,$startM,$stopM) = split(/\|/,$modencodefile);
			#my ($value,$gene_name,$stage) = split(/\@/,$mod_encode_name);	
			$chromosomeB  = uc($chromosomeB);
			$number = uc($number);
			my $holderB = $stopB - $startB;
			$holderB = $holderB / 2;
			my $midpointB = $startB + $holderB;
			my $midpoint_left_b = $midpointB - 25;
			my $midpoint_right_b = $midpointB + 25;
			if($chromosomeB eq $number){
				$holder = $stopM - $startM;
				$holder = $holder / 2;
				$midpoint = $startM + $holder;
				my $midpoint_left_m = $midpoint - 25;
				my $midpoint_right_m = $midpoint + 25;
				my $distance = abs($midpoint - $midpoint_right_b);
				if($distance <= 5) {
				#if(($midpoint > $startB) and ($midpoint < $stopB)){
					print OUT "$mod_encode\t$bait_name\t$number\t$midpoint\t$startB\t$stopB\n";
					$counter++;
					
					# print OUT "$mod_encode\t";
					# print OUT "$bait_name\t";
					# print OUT "$gene_name\t";
					# print OUT "$stage\t";
					# print OUT "$number\t";
					
				}
			
			}
		}

	}

	print "$counter\n";
	
}
()=&compare($bait_info,$mod_encode_hash,$mod_encode);



close OUT;