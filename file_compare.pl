use Bio::SeqIO;
use Bio::SearchIO;
use strict;
use warnings;
use POSIX;
use Data::Dumper;

 
my $baits = $ARGV[1];
open(OUT,">>"."seq.fa");
system ("dos2unix baits.txt"); 
sub bait_info($){
my $baits = shift;
my %bait_info=();
my $line = 0;
open (BAIT, $baits) or die $!;	
while($line = <BAIT>){                
    chomp($line); 	
    my @temp = split(/\t/, $line);
			my $bait_name = $temp[0];
			my $orf = $temp[1];
			my $gene_name = $temp[2];
			my $bait_lingth = $temp[3];
			my $bait_sequence = $temp[4];

			$bait_info{$bait_name} = $bait_name."|".$orf."|".$gene_name."|".$bait_lingth."|".$bait_sequence;	
}	
return(\%bait_info);
close (BAIT);
}

my $bait_info = [];
($bait_info)=&bait_info($baits);
#system ("dos2unix genomews220.txt");

sub sequence_search(){
my %bait_list=();

    my $bait_info = [];
	$bait_info  = shift;
	my $seqio = Bio::SeqIO->new(-file => "c_elegans.WS220.dna.fa", '-format' => 'Fasta');
	my @ids = ("CHROMOSOME_I","CHROMOSOME_II","CHROMOSOME_III","CHROMOSOME_IV","CHROMOSOME_V","CHROMOSOME_X","CHROMOSOME_MtDNA");
	my $count = 0;
	my $stop  = 0;
	while(my $seq = $seqio->next_seq) {
		my $string = $seq->seq;
		my $name = $ids[$count];
		my $ticker = 0;
		foreach my $key ( keys %$bait_info ) {
			my $bait_file = $bait_info->{$key};
			my ($bait_name,$orf,$gene_name,$bait_lingth,$bait_sequence) = split(/\|/,$bait_file);
			my @strtest = split(//,$bait_sequence);
			my $val = $bait_sequence;
			$val = lc($val);
			my $start = index($string,$val);
			my $stop = $start + $bait_lingth;
			
			if($start > 0){
				$bait_list{$bait_name} = $bait_name."|".$name."|".$start."|".$stop;
				#print "$bait_name $ticker\n";
				#print OUT "$bait_name\t$name\t$start\t$stop\n";
				$ticker++;
			}
			$start = 0;
		}
		$count++;
	}
	my $ticker2 = 0;
	foreach my $key ( keys %$bait_info ) {
		
		if (!exists($bait_list{$key})) {
			my $bait_file = $bait_info->{$key};
			my ($bait_name,$orf,$gene_name,$bait_lingth,$bait_sequence) = split(/\|/,$bait_file);
			print "$bait_name $ticker2\n";
			print OUT ">$bait_name\n";
			print OUT "$bait_sequence\n";
			$ticker2++;
		}
	}
	
}


()=&sequence_search($bait_info);
close OUT;