use strict;
use warnings;
use POSIX;
use Data::Dumper;

my $baits = $ARGV[0];
my $mod_encode = $ARGV[1];

open(OUT,">>"."results.txt");

sub bait_info($){
	my $baits = shift;
	my %bait_info=();
	my $line = 0;
	open (BAIT, $baits) or die $!;	
	while($line = <BAIT>){                
		chomp($line); 	
		my @temp = split(/\t/, $line);
				my $bait_name = $temp[0];
				my $chromosome = $temp[1];
				my $start = $temp[2];
				my $stop = $temp[3];
				$bait_info{$bait_name} = $bait_name."|".$chromosome."|".$start."|".$stop;	
	}	
	return(\%bait_info);
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
	#File name parsing 
	my @temp_name=();
	@temp_name = split(/\//,$mod_encode);
	my $filename=$temp_name[@temp_name-1];
	@temp_name=();
	@temp_name = split(/\_/,$filename);
	my $n=$temp_name[3];
	my $w=$temp_name[4];
	if($n eq "GFP") {
		$mod_encode_name = $temp_name[0]."@".$temp_name[2]."@".$temp_name[4]; 
	}
	elsif($w eq "GFP") {
		my $super = $temp_name[2]."_".$temp_name[3];
		$mod_encode_name = $temp_name[0]."@".$super."@".$temp_name[5]; 
	}
	elsif($temp_name[2] =~ m/GFP/){
		$mod_encode_name = $temp_name[0]."@".$temp_name[2]."@".$temp_name[3];
	}
	else{
		my $super = $temp_name[2]."_".$temp_name[3];
		$mod_encode_name = $temp_name[0]."@".$super."@".$temp_name[4];
	}		

	

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
	return(\%mod_encode_hash);
	close (BAIT);
}

my $mod_encode_hash = [];
($mod_encode_hash)=&mod_encode_data($mod_encode);


sub compare($$){
my $bait_info = [];
my $mod_encode_hash = [];
my $key_bait = 0;
my $key_modencode = 0;

$bait_info = shift;
$mod_encode_hash = shift;

	foreach $key_bait ( keys %$bait_info ) {
		my $holder = 0;
		my $midpoint = 0;
		my $baitfile = $bait_info->{$key_bait};
		my ($bait_name,$chromosomeB,$startB,$stopB) = split(/\|/,$baitfile);
		foreach $key_modencode ( keys %$mod_encode_hash ) {
			my $modencodefile = $mod_encode_hash->{$key_modencode};
			my ($mod_encode_name,$number,$startM,$stopM) = split(/\|/,$modencodefile);
			my ($value,$gene_name,$stage) = split(/\@/,$mod_encode_name);	
			$chromosomeB  = uc($chromosomeB);
			$number = uc($number);
			if($chromosomeB eq $number){
				$holder = $stopM - $startM;
				$holder = $holder / 2;
				$midpoint = $startM + $holder;
				if(($midpoint > $startB) and ($midpoint < $stopB)){
					print OUT "$bait_name\t$gene_name\t$stage\t$number\t$midpoint\t$startB\t$stopB\n";
				}
			
			}
		}

	}

}
()=&compare($bait_info,$mod_encode_hash);



close OUT;