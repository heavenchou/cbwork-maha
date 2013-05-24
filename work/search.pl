

use File::Recurse;
use strict;

my $big5 = q{
[\x00-\x7F] # ASCII/CNS-Roman
| [\xA1-\xFE][\x40-\x7E\xA1-\xFE] # Big Five
};

my $search = shift;

#$search  =~ s/([\x5b-\x5e\x7c])/\\$1/g;
print STDERR "$search\n";

#my $kill_rx = q(xml$|sgm$|sgml$|raw$);
my $kill_rx = q(xml$);
my $dir = shift || '.';      # use arg or current dir

my $f;

recurse(\&maybe_kill_file, $dir);		
		
sub maybe_kill_file {
    return if -d $_;         # ignore dirs
    $f = $_;
#    print STDERR "$_\n";
    if (/$kill_rx/i) {       # delete if it matches our spec
    	open (F, $_);
			open (OF, ">$of");
    	while(<F>){
    		if (/^(?:$big5)*?$search/ox){
				$_="$f:$_";
				s#.*\\/T[^/]*/##i;
				s/\.xml//i;
				s/<lb n="//i;
				s#"/># #;
				while(/\&([MC][^;]*)/g){
					print "$1\t$_";
				}

 #   			print "$f:$_";
#    			last;
    		}
    	}
			close (OF);
    }
}
