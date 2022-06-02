# Copyright (c) 2022 Gouhei Tanaka. All rights reserved.
# Citation: G.Tanaka and R.Nakane, Scientific Reports (2022).
# DOI: 10.1038/s41598-022-13687-z

#!/usr/bin/perl

# convert 'DAE_pre.m' to 'DAE.m' by changing 'param' to a time-varying signal
#  (1) delete 'param' in 'function eqs = DAE_pre(t,in2,in3,param)'
#  (2) add 'param1 = interp1(st,s,t,'spline');'

$infile = "DAE_pre.m";
$outfile = "DAE.m";

open(IN,"$infile") || die "can't open $infile";
open(OUT,">$outfile") || die "can't open $outfile";

$flag = 0;

while(<IN>){

    # Remove change-line code
    chomp($_);
    $string = $_;
        
    # Remove ^M
    $string =~ s/\x0D\x0A|\x0D|\x0A//g;

    # Change 'paramx(x=1,2,...)' to 'param'
    $string =~ s/param(\d+)/param/g;

    # Delete 'param' in the first line
    # function eqs = DAE_pre(t,in2,in3,param1)

    # Change 'param' to a time-varying signal
    if($string =~ /function eqs/){
	$string =~ s/,param\)/,st,samplein\)/;
	print OUT $string."\n";
    }
    elsif(($string =~ /^\s*$/)&&($flag == 0)){  # if blank
	print OUT "param = interp1\(st,samplein,t,\'spline\'\)\;\n\n";
	$flag = 1;
    }
    else{
	print OUT $string."\n";
    }
}

close IN;
close OUT;
