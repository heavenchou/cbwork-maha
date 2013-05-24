# checkxml.pl
# �ˬd XML ��
#
# �ϥΤ�k:
#       ��U checkxml.pl t01
#       ���� checkxml.pl
#
# Log:
# �A����� 2005/11/28 10:28 by Ray
# v 0.01, 2003/3/11 02:19PM by Ray
# v 0.2.0, �ˬd�ʦr���ɬO�_�s�b, 2003/6/9 01:43�U�� by Ray
# v 0.3.1, ��ѼƩ�� config.pl, 2003/12/3 02:40�U�� by Ray
# v 0.4.1, �Ӭd�x��r���ɬO�_�s�b, 2003/12/30 01:32�U�� by Ray
# v 0.5.1, ���L <!--\n .... -->\n �������F�褣�ˬd, 2004/1/2 04:32�U�� by Ray
# v 0.6.1, �ˬd����٬A��, 2004/2/19 12:00�U�� by Ray
# v 0.7.1, �ˬd�զr��(�����নentity), 2004/6/2 09:42�W�� by Ray
# v 0.7.2, 2004/6/3 03:04�U�� by Ray
# v 0.8.1, 2004/6/7 03:07�U�� by Ray
# v 0.9.1, 2004/6/8 08:44�W�� by Ray

require "config.pl";

print STDERR "��X�O����: $log_file\n";
print STDERR "�ӷ� XML �ɥؿ�:$xml_in_dir\n";
print STDERR "�ʦr���ɥؿ�: $gaiji_cb_in_dir\n";
print STDERR "�x��r���ɥؿ�: $sd_gif_in_dir\n";
print STDERR "�����r���ɥؿ�: $rj_gif_in_dir\n";
print STDERR "������Ϲ��ɥؿ�: $figure_in_dir\n";

$vol=shift;
if ($vol ne '') { print STDERR "vol=$vol\n"; }

open O, ">$log_file" or die;
select O;

%figures = ();
%gaijis = ();

if ($vol eq '') {
        $all = 1;
        read_figures("$figure_in_dir/T");
        read_figures("$figure_in_dir/X");
        read_figures("$figure_in_dir/J");
        read_figures("$figure_in_dir/H");
        read_figures("$figure_in_dir/W");
        read_figures("$figure_in_dir/I");
        read_figures("$figure_in_dir/C");
        read_figures("$figure_in_dir/F");
        read_figures("$figure_in_dir/K");
        read_figures("$figure_in_dir/L");
        read_figures("$figure_in_dir/P");
        read_gaijis($gaiji_cb_in_dir);
        read_gaijis($sd_gif_in_dir);
        read_gaijis($rj_gif_in_dir);
        opendir DIR, "$xml_in_dir" or die "open $xml_in_dir error $!";
        @alldir = grep /^[TXJHWIABCFGKLMNPQSU]/, readdir DIR;
        
        closedir(DIR);
        foreach $vol (@alldir) 
        {
        	if( -d "$xml_in_dir/$vol")
        	{
				do_vol();
			}
        }
} else {
        $all = 0;
        $vol=uc($vol);
        opendir DIR, "$xml_in_dir" or die "open $xml_in_dir error $!";
        @alldir = grep /^$vol/, readdir DIR;
        closedir(DIR);
        foreach $vol (@alldir) {
                do_vol();
        }
}
closedir DIR;

if ($all) {
        foreach  $k (sort keys %figures) {
                print "���ɨS�Ψ�: $k\n";
        }
        foreach  $k (sort keys %gaijis) {
                print "�ʦr���ɨS�Ψ�: [$k]\n";
        }
}
close O;

sub do_vol {
        opendir (INDIR, "$xml_in_dir/$vol") or die "open $xml_in_dir/$vol error $!";
        @allfiles = grep(/\.xml$/i, readdir(INDIR));
        closedir(INDIR);
        foreach $f (@allfiles) {
                do1file($f);
        }
}

sub do1file {
        $file=shift;
        print STDERR "$file ";
        open I,"$xml_in_dir/$vol/$file" or die;
        my $in_remark=0;
        $body=0;
        $old_brace1=0;
        $old_brace2=0;
        @braces = ();
        while(<I>) {
                $t=$_;
                if ($in_remark) {
                        if (/^\-\->\n$/) {
                                $in_remark=0;
                        }
                        next;
                }
                if (/^<!\-\-\n$/) {
                        $in_remark=1;
                } elsif (/(<[^>]*?)\n/) {
                        $s=$1;
                        if ($t!~/^<!/) {
                                print "Tag ���\n";
                                print "$file $t\n";
                        }
                }
                $line=$t;
                $brace1=0;
                $brace2=0;
                #$t=~s/(&CB.*?;|&SD.*?;|<figure.*?>)/&rep($1)/eg;
                if ($t=~/<body/) {
                        $body=1;
                }
                # �ˬd��g�r�O�_���w�� entity
                if ($body) { 
                        $temp = $t;
                        $temp =~ s/<[^>]+?>/ /g; # �h���аO
                        $temp =~ s/[\x80-\xff][\x00-\xff]/ /g; # �h������
                        $temp =~ s/&.*?;/ /g;
                        $temp =~ s/\d+\./ /g;
                        $temp =~ s/V?I{2,3}\.?/ /g;
                        if ($temp =~ /^(.*)(\`s|aa|ii|uu|\.[dhlmnrst]|\^[amn]|\~n)/i) {
                                $temp1 = $1;
                                print "��g $2 ���� entity: $file\n";
                                print " $t \n";
                        }
                }
                $t=~s#(&CB.*?;|&CI.*?;|&SD.*?;|&RJ.*?;|\[([\x80-\xff][\x00-\xff]|\+|\-|\*|\/|\x40|\?|\(|\)){2,}\]|<figure.*?>|<p[^>]*?></p>|<p.*?>|[\x80-\xff][\x00-\xff])#&rep($1)#eg;
        }
        close I;
}

sub rep{
        my $s=shift;
        my $cb;
        if ($s=~/&(.*?);/) {
                $cb=$1;
        }
        if ($cb=~/^CB/) {
                check_cb($cb);
        } elsif ($cb=~/^CI/){
                check_ci($cb);
        } elsif ($cb=~/^SD/){
                my $s1=substr($cb,3,2);
                my $path="$sd_gif_in_dir/$s1/$cb.gif";
                if (not -e $path) {
                        print "�x����ɤ��s�b: $path \n";
                        print "$file $t\n";
                } else {
                        delete $gaijis{$cb};
                }
        } elsif ($cb=~/^RJ/){
                my $s1=substr($cb,3,2);
                my $path="$rj_gif_in_dir/$s1/$cb.gif";
                if (not -e $path) {
                        print "�������ɤ��s�b: $path \n";
                        print "$file $t\n";
                } else {
                        delete $gaijis{$cb};
                }
        } elsif ($s=~/\[([\x80-\xff][\x00-\xff]|\+|\-|\*|\/|\x40|\?|\(|\))+\]/){
                if ($s =~ /\+|\-|\*|\/|\x40|\?/) { # �ܤ֦��@�ӳs���Ÿ� �~�O�զr��
                        print "�t�զr�� $s\n";
                        print "$file $t\n";
                }
        } elsif ($s=~/^<figure/){
                $s=~/entity="Fig(.*?)"/;
                my $ent=$1;
                my $s1=substr($ent,0,1);
                my $path="$figure_in_dir/$s1/$ent.gif";
                if (not -e $path) {
                        print "������Ϲ��ɤ��s�b: $path \n";
                        print "$file $t\n";
                }
                delete $figures{$ent};
        } elsif ($s=~/^<p[^>]*?><\/p>/){
                if ($s=~/^<pb/) {                       
                        print "</p>���Ӳ���W�@��\n";
                } else {
                        print "�Ū��q��\n";
                }
                print "$file $t\n";
        #} elsif ($body and $s=~/^<p(.*?)>/){
        #       my $s=$1;
        #       if ($s !~ /id=/) {
        #               print "<p> �֤F id �ݩ�\n";
        #               print "$file $t\n";
        #       }
        } elsif ($s =~ /^[\x80-\xff]/) {
                $i = scalar @braces;
                if ($i==0) {
                        if ($s eq "�f" or $s eq "�^") {
                                brace_err();
                        } elsif ($s eq "�e" or $s eq "�]") {
                                push @braces, $s;
                        }
                } else {
                        if ($s eq "�e" or $s eq "�]") {
                                push @braces, $s;
                        } elsif ($s eq "�f") {
                                if ($braces[$i-1] eq "�e") {
                                        pop @braces;
                                } else {
                                        brace_err();
                                }
                        } elsif ($s eq "�^") {
                                if ($braces[$i-1] eq "�]") {
                                        pop @braces;
                                } else {
                                        brace_err();
                                }
                        }
                }
        }
        return $s;
}

sub brace_err {
        print "$file �A������� $line\n";
}

sub read_figures {
        $path = shift;
        opendir DIR, $path or die "cannot open dir $path\n";
        @alldir = grep /\.gif$/, readdir DIR;
        closedir(DIR);
        foreach $s (@alldir) {
                $s =~ /^(.*)\.gif$/;
                $figures{$1}=1;
        }
}

sub read_gaijis {
        $path = shift;
        opendir DIR, $path or die "open $path error";
        @alldir = grep !/^\.\.?$/, readdir DIR;
        closedir(DIR);

        foreach $d (@alldir) {
                opendir DIR, "$path/$d" or die;
                @allfile = grep !/^\.\.?$/, readdir DIR;
                foreach $s (@allfile) {
                        if ($s !~ /\.gif$/i) {
                                print "�ʦr���ɤ��O GIF ��: $s\n";
                                next;
                        }
                        $s =~ /^(.*)\.gif$/i;
                        $gaijis{$1}=1;
                }
        }
}

sub check_ci() {
        my $s=shift;
        if ($s eq "CI0001") { check_cb("CB00269"); }
        elsif ($s eq "CI0002") { check_cb("CB00277"); }
        elsif ($s eq "CI0003") { check_cb("CB00662"); }
        elsif ($s eq "CI0004") { check_cb("CB00566"); }
        elsif ($s eq "CI0005") { check_cb("CB00247"); }
        elsif ($s eq "CI0006") { check_cb("CB00662"); }
        elsif ($s eq "CI0007") { check_cb("CB13514"); }
        elsif ($s eq "CI0009") { check_cb("CB04612"); check_cb("CB00269"); }
        elsif ($s eq "CI0010") { check_cb("CB04712"); }
        elsif ($s eq "CI0011") { check_cb("CB04608"); check_cb("CB00224"); }
        elsif ($s eq "CI0012") { check_cb("CB05088"); check_cb("CB05087"); }
        elsif ($s eq "CI0013") { check_cb("CB00662"); }
        elsif ($s eq "CI0014") { check_cb("CB13566"); check_cb("CB00300"); }
        elsif ($s eq "CI0015") { check_cb("CB04712"); }
}

sub check_cb {
        my $cb = shift;
        my $s1=substr($cb,2,2);
        if (not -e "$gaiji_cb_in_dir/$s1/$cb.gif") {
                print "�ʦr $cb ���ɤ��s�b\n";
                print "$file $t\n";
        } else {
                delete $gaijis{$cb};
        }
}
