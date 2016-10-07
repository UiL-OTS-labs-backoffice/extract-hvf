#!/usr/bin/perl
use warnings;
use strict;
use Time::Piece;

# Retrieves ppnum, ppgroup, contrast, total sum of the habituation looking times, and pre/post looking times for a .hvf-file.
sub processFile
{
	my $ppnum;
	my $ppgroup;
	my $contrast;
    my $date;
	my $totalsum = 0;
	my @looktimes;

	open (my $in, "<", @_) || die $!;

	while (<$in>)
	{
		my @parts = split(/\s/, $_);
		if (/^! ppnum\:\s+([0-9]+)$/)
		{
			$ppnum = $1;
		}
		elsif (/^! ppgroup\:\s+([0-9]+)$/)
		{
			$ppgroup = $1;
		}
		elsif (/^! contrast\:\s+([0-9]+)$/)
		{
			$contrast = $1;
		}
		elsif (/^! started\:\s+(.*?)\sCES?T\s([0-9]+)$/)
		{
			my $t = Time::Piece->strptime($1 . " " . $2, "%a %b %d %T %Y");
			$date = $t->strftime("%Y-%m-%d %T");
		}
		elsif (/^[^!].*HAB/ && @parts == 9)
		{
			$totalsum += $parts[-1];
		}
		elsif (/^! pretest/)
		{
			@looktimes = $_ =~ /LT=([0-9]+)/g;
		}
	};

	close $in || die $!;

	return ($ppnum, $ppgroup, $contrast, $date, @looktimes, $totalsum);
}

open (my $out, ">", "out.csv") || die $!;
print $out "filename;ppnum;ppgroup;contrast;date;pretestLT;posttestLT;habLT\n";

my $fcount = 0;
my $logcount = 0;

# Loop over the files starting with "hvf." in this directory
foreach my $file (<hvf.*>) 
{
	if ($file =~ /.log/)
	{
		$logcount++;
	}
	else
	{
		my $line = join(';', processFile($file));
		print $out "$file;$line\n";
		$fcount++;	
	}
}

close $out || die $!;
print "total hvf.nnn files processed: $fcount, .log files: $logcount\n";
