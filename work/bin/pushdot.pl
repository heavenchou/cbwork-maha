########################################################
#
# �yŪ���J�{��  by heaven                2004/08/14
#
# �ϥΤ�k�G
# pushdot.pl ²��аO��.txt �ª�xml.xml ���G��xml.xml
#
########################################################
# 2005/04/26 : �ק�p���D
# 10/15 : �B�z�@�Ǥ��
# 10/15 : �B�z�x��r�� �K�]�^�T�ӲŸ��� <item>
# 10/15 : �� <tt> ���B�z�k
# 10/14 : �[�j <tt> , �e�\�ĤG�榳�i�ϡj�Ψ䥦��r
# 10/14 : �[�j <tt> , �e�\�ĤG�榳�i�ϡj (�٭n�A�[�j)
# 10/13 : �B�z <tt> ��~�j���� �� <sg>
# 10/10 : �B�z <foreign>...</foreign>
# 10/10 : �B�z <head type="added">....</head> �� &SD-...; �x��r
# 10/8 : �N���� <t lang="san|pli|..." �令���� <t ... place="foot" 
# 10/8 : �B�z <l lang="unknow" �ήհɼƦr���׭q [[04]>]
# 10/6 : �[�j�Q�骺�P�_
# 10/5 : ���ʤ��A���yŪ�P�p���I. �Ҧp���Ӳ��ܮհ� <lem> <t> ���d�򤧥~.
# 10/4 : �B�z�ɧ��� 0x0d �r��
# 10/4 : �B�z�ڧQ����g�r, <foreign>
# 10/3 : �B�z�j�����հ�, �P��, <tt>
# 9/8 : �B�z�G�ɤ@���u�C�v�@���u�D�v�� bug
# 9/5 : �B�z�q�ε�, ��, �����䥦�����^��, ���I���P�ɤ@�ߥH SM ���D

use strict;

local *INTxt;
local *INXml;
local *OUTXml;

my $big5='(?:(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x7f]))';
my $losebig5='(?:(?:[\x80-\xff][\x40-\xff])|[+\-*\/\(\)\@\?:0-9])';

########################################################
# �P�_�Ѽ�
########################################################

if($#ARGV != 2)
{
	print "�ϥΤ�k�G\n";
	print "    pushdot.pl ²��аO��.txt �ª�xml.xml ���G��xml.xml\n";
	print "\n���N�䵲��....\n";
	<STDIN>;
	exit;
}

########################################################
# �D�Ѽ�
########################################################

my $InTxtFile = shift;
my $InXmlFile = shift;
my $OutXmlFile = shift;

my $hasdot1 = 0;		# �ΨӧP�_�O�_�� dot , 0: �S��, 1:�yŪ, 2:�p���I
my $hasdot2 = 0;		# �ΨӧP�_�O�_�� dot , 0: �S��, 1:�yŪ, 2:�p���I
my $tagbuff = "";		# �Ȧs tag �� buff

my $istt = 0;           # �P�_�O���O <tt> �j����, 0:�@�몬�p, 1:xml �o�{ <tt> 2:sm ���w�B�z�� <tt> �榡(��~����)
my $whicht = 0;         # �ثe�O�b���@�� <t> �̭�? �� : 1 , �~ : 2 

########################################################
# �D�{��
########################################################

open INTxt, "$InTxtFile" or die "open $InTxtFile error$!";
open INXml, "$InXmlFile" or die "open $InXmlFile error$!";
open OUTXml, ">$OutXmlFile" or die "open $OutXmlFile error$!";

my @lines1 = <INTxt>;
my @lines2 = <INXml>;

close INTxt;
close INXml;

my $index1 = 0;
my $index2 = 0;

# 1. ���N�����n�� XML copy �L�h

while(1)
{
	print OUTXml "$lines2[$index2]";
	last if($lines2[$index2] =~ /<body>/);
	$index2++;
}
$index2++;

while(1)
{
	$hasdot1 = 0;		# �ΨӧP�_�O�_�� dot
	$hasdot2 = 0;		# �ΨӧP�_�O�_�� dot
	
	# ------------------------ �U���@�Ӧr
	
	my $word2 = get_word2();
	if($istt == 1)
	{
	    make_tt();
	    $istt = 2;
	}
	if($istt == 2 and $whicht == 2)
	{
	    $index1++;      # <tt> �����~�r, �ҥHŪ�U�@��
	}
	my $word1 = get_word1();
	if($istt == 2 and $whicht == 2)
	{
	    $index1--;      # �٭�
	}	
	if($word1 ne "" and $word2 eq "")
	{
		print "Error: $InXmlFile no data\n";
		print OUTXml "<?>Out of data";
		last;
	}
	
	# ------------------------ �P�_�G�Ӧr�O�_�ۦP
	
	my $result = check_2_word($word1, $word2);

	if($result == 1)	# �G��P�B
	{
		if($hasdot1 == $hasdot2)
		{
			print OUTXml $tagbuff;
		}
		elsif($hasdot1 == 1)
		{
			$tagbuff =~ s/�D//;
			
			# <rdg wit="�i�j�j">���C</rdg></app> ==> <rdg wit="�i�j�j">��</rdg></app>�C
			if($tagbuff =~ /^<((\/rdg)|(\/lem)|(\/t)|(note[^>]*resp="CBETA".*?)|(app.*?))>/)
			{
			    if($tagbuff =~ /^.*<\/((app)|(tt)|(note))>/)
			    {
				    $tagbuff =~ s/^(.*<\/(?:(?:app)|(?:tt)|(?:note))>)/$1�C/;
				    print OUTXml "$tagbuff";
				}
				else
				{
				    print OUTXml "�C<<?>:<�b rdg,lem,t,note ���e���yŪ���ӳB�z��>>$tagbuff";
				}
			}
			elsif($tagbuff =~ /^<foreign.*?>.*?<\/foreign>/)
			{
			    $tagbuff =~ s/^(<foreign.*?>.*?<\/foreign>)/$1�C/;
				print OUTXml "$tagbuff";
			}
			else
			{
				print OUTXml "�C$tagbuff";
			}
		}
		elsif($hasdot1 == 2)
		{
			$tagbuff =~ s/�C//;
			# <rdg wit="�i�j�j">���D</rdg></app> ==> <rdg wit="�i�j�j">��</rdg></app>�D
			if($tagbuff =~ /^<((\/rdg)|(\/lem)|(\/t)|(note[^>]*resp="CBETA".*?)|(app.*?))>/)
			{
			    if($tagbuff =~ /^.*<\/((app)|(tt)|(note))>/)
			    {
				    $tagbuff =~ s/^(.*<\/(?:(?:app)|(?:tt)|(?:note))>)/$1�D/;
				    print OUTXml "$tagbuff";
				}
				else
				{
				    print OUTXml "�D<<?>:<�b rdg,lem,t,note ���e���yŪ���ӳB�z��>>$tagbuff";
				}
			}
			elsif($tagbuff =~ /^<foreign.*?>.*?<\/foreign>/)
			{
			    $tagbuff =~ s/^(<foreign.*?>.*?<\/foreign>)/$1�D/;
				print OUTXml "$tagbuff";
			}
			else
			{
				print OUTXml "�D$tagbuff";
			}			
		}
		elsif($hasdot1 == 0 and $hasdot2 == 1)
		{
			$tagbuff =~ s/�C//;
			print OUTXml "$tagbuff";
		}
		elsif($hasdot1 == 0 and $hasdot2 == 2)
		{
			$tagbuff =~ s/�D//;
			print OUTXml "$tagbuff";
		}
		else
		{
			print OUTXml "<?>$tagbuff";		# �j���Τ��W�F
		}

		print OUTXml "$word2";
	}
	else
	{
		print OUTXml "<?>$tagbuff$word2";
		exit;
	}
	
	if($word1 eq "" and $word2 eq "")
	{
		last;
	}
}

close OUTXml;


########################################################
#
# XML ���J�� <tt> �j���ӡA�ҥH sm ���n�B�z���M xml ���@�˪��榡
#�Ҧp
#T18n0859_p0178c23Z#H������������������
#T18n0859_p0178c24_##[41]�n�@��@�T�@�ҡ@�h�@��@���o(�G�X)�@�i(�@)�@�{(�G)
#�ܦ�
#T18n0859_p0178c23Z#H������������������
#[41]�n�@��@�T�@�ҡ@�h�@��@���o(�G�X)�@�i(�@)�@�{(�G)T18n0859_p0178c24_##
#
# �Ĥ@�� <t> �N���Ĥ@��, �ĤG�� <t> ���ĤG��, �Ĥ@�浲����, �A�N�ĤG�檺 Txxn... ����e����
########################################################

sub make_tt
{
    my $data;
    if($index1 == $#lines1)
    {
        return;     #�̫�@��F, ���Ϊ��F
    }
    
    my $line1 = $lines1[$index1];
    my $line2 = $lines1[$index1+1];
    my $line3 = $lines1[$index1+2];
    
    # �B�z�׭q�P����

    if($line2 =~ />/)
    {
        if($line3 =~ />>/ and $line2 =~ />>/)
        {
            while($line3 =~ /^$big5*?\[($losebig5+?)\]/)
            {
        	    $line3 =~ s/^($big5*?)\[($losebig5+?)\]/$1:1:$2:2:/;
	        }
	        $line3 =~ s/\[($losebig5*?)>>($losebig5*?)\]/$2/g;
	        $line3 =~ s/\[($losebig5*?)>($losebig5*?)\]/$2$1/g;
	        $line3 =~ s/:1:/\[/g;
	        $line3 =~ s/:2:/\]/g;
	    }

        while($line2 =~ /^$big5*?\[($losebig5+?)\]/)
        {
    	    $line2 =~ s/^($big5*?)\[($losebig5+?)\]/$1:1:$2:2:/;
	    }
	    $line2 =~ s/\[($losebig5*?)>>($losebig5*?)\]/$2/g;
	    $line2 =~ s/\[($losebig5*?)>($losebig5*?)\]/$2$1/g;
	    $line2 =~ s/:1:/\[/g;
	    $line2 =~ s/:2:/\]/g;
	}

    if($line2 =~ /^[TX]\d\dn.{5}p.{7}.{3}(.*)/)
    {
        $line2 =~ s/^([TX]\d\dn.{5}p.{7}.{3})(.*)/$2$1/;
    }
    else
    {
        return;     # �ĤG��S���歺
    }
    $lines1[$index1+1] = $line2;
    $lines1[$index1+2] = $line3;
}
########################################################
#
# ���o�¤�r���r
#
########################################################

sub get_word1
{	
	local $_;
	
	while(1)
	{
		if($index1 > $#lines1)		# �����F
		{
			return "";
		}
		
		if($lines1[$index1] eq "\n") 
		{
			$index1 ++;
			next;
		}
		
		if($lines1[$index1] =~ /^�C/)
		{
			$hasdot1 = 1;	
			$lines1[$index1] =~ s/^�C//;
			next;
		}
		
		if($lines1[$index1] =~ /^�D/)
		{
			$hasdot1 = 2;	
			$lines1[$index1] =~ s/^�D//;
			next;
		}
		
		if($lines1[$index1] =~ /^((?:�@)|(?:��)|(?:��)|(?:��)|(?:��)|(?:��)|(?:��)|(?:��)|(?:��)|(?:��)|(?:��)|(?:��)|(?:��)|(?:��)|(?:��)|(?:��)|(?:��))/)
		{
			$lines1[$index1] =~ s/^((?:�@)|(?:��)|(?:��)|(?:��)|(?:��)|(?:��)|(?:��)|(?:��)|(?:��)|(?:��)|(?:��)|(?:��)|(?:��)|(?:��)|(?:��)|(?:��)|(?:��))//;
			next;
		}
		
		if($lines1[$index1] =~ /^<.*?>/)
		{
			$lines1[$index1] =~ s/^<.*?>//;
			next;
		}
		last;
	}
	
	$_ = $lines1[$index1];	# �B�z�׭q�P����
	
	# ���歺  X79n1563_p0657a09_##

	if(/^[TX]\d\dn.{5}p(.{7}).{3}/)
	{
		# �B�z�׭q�P����
		
		while(/^$big5*?\[($losebig5+?)\]/)
		{
			s/^($big5*?)\[($losebig5+?)\]/$1:1:$2:2:/;
		}
		s/\[($losebig5*?)>>($losebig5*?)\]/$2$1/g;
		s/\[($losebig5*?)>($losebig5*?)\]/$2$1/g;
		s/:1:/\[/g;
		s/:2:/\]/g;
		
		# �B�z�q�ε�
		
		s=\Q����[�I/��][�I/��]\E=&CIxxx;=g;
		s=\Q��[�I/��]\E=&CIxxx;=g;
		s=\Q[�I/��]��\E=&CIxxx;=g;
		s/\Q�e[��-�B+��]\E/&CIxxx;/g;
		s/\Q�Y[��*��]\E/&CIxxx;/g;
		s/\Q�w[��*�C]\E/&CIxxx;/g;
	
		s/\Q[��*��]��\E/&CIxxx;/g;
		s/\Q[��*�O]�M\E/&CIxxx;/g;
		s=\Q[�@/��][��*��]\E=&CIxxx;=g;
		s=\Q[��*��][��*��]\E=&CIxxx;=g;
		s=\Q�y[��*��]\E=&CIxxx;=g;
		
		$lines1[$index1] = $_;
		
		$lines1[$index1] =~ s/^[TX]\d\dn.{5}p(.{7}).{3}//;
		return "n=\"$1\"";
	}
	elsif(/^\[\d+[A-Za-z]?\]/)	# �հɼƦr
	{
		$lines1[$index1] =~ s/^(\[\d+[A-Za-z]?\])//;
		return "$1";
	}
	elsif(/^\[��\]/)	# �P��
	{
		$lines1[$index1] =~ s/^(\[��\])//;
		return "$1";
	}
	elsif(/^\[($losebig5+?)\]/)	# �ʦr
	{
		$lines1[$index1] =~ s/^(\[($losebig5+?)\])//;
		return "$1";
	}
	elsif(/^&CIxxx;/)	# �q�ε�
	{
		$lines1[$index1] =~ s/^(&CIxxx;)//;
		return "$1";
	}
	elsif(/^�i�ϡj/)	# �i�ϡj
	{
		$lines1[$index1] =~ s/^(�i�ϡj)//;
		return "$1";
	}
	elsif(/^([Aaiu])\1/)	# �ڧQ��
	{
		$lines1[$index1] =~ s/^([Aaiu])\1//;
		return "&$1macron;";
	}
	elsif(/^\.[dDhlLmnNrsStT]/)	# �ڧQ��
	{
		$lines1[$index1] =~ s/^\.([dDhlLmnNrsStT])//;
		return "&$1dotblw;";
	}
	elsif(/^\^[mn]/)	# �ڧQ��
	{
		$lines1[$index1] =~ s/^\^([mn])//;
		return "&$1dotabv;";
	}
	elsif(/^~n/)        # �ڧQ��
	{
		$lines1[$index1] =~ s/^~n//;
		return "&ntilde;";
	}
	elsif(/^\`[sS]/)	# �ڧQ��
	{
		$lines1[$index1] =~ s/^\`([sS])//;
		return "&$1acute;";
	}
	elsif(/^�iMA�j/)	# ���&M062462;&M062431;&M062473;
	{
		$lines1[$index1] =~ s/^�iMA�j//;
		return "&M062462;";
	}
	elsif(/^�iTA�j/)	# ���&M062462;&M062431;&M062473;
	{
		$lines1[$index1] =~ s/^�iTA�j//;
		return "&M062431;";
	}
	elsif(/^�iRA�j/)	# ���&M062462;&M062431;&M062473;
	{
		$lines1[$index1] =~ s/^�iRA�j//;
		return "&M062473;";
	}
	elsif(/^$big5/)     # �@��r
	{
		$lines1[$index1] =~ s/^($big5)//;
		return "$1";
	}
	else
	{
		print "�������r:\n";
		print "line = $index1\n";
		print "word = $lines1[$index1]\n";
		print "���N�䵲��...\n";
		<>;
		exit;
	}
}

sub get_word2
{
	local $_;
	$tagbuff = "";	# �Ȧs tag �� buff

	while(1)
	{
		if($index2 > $#lines2)		# �����F
		{
			return "";
		}

		if($lines2[$index2] eq "\n")		# ���B�z����
		{
			$tagbuff .= "\n";
			$index2 ++;
			next;
		}

		if($lines2[$index2] =~ /^(<lb.*?>)/)
		{
			last;
		}

	    #<head type="added">...</head>
	    if($lines2[$index2] =~ /^<head[^>]*type="added"[^>]*>.*?<\/head>/)
		{
			$lines2[$index2] =~ s/^(<head[^>]*type="added"[^>]*>.*?<\/head>)//;
			$tagbuff .= $1;
			next;
		}
		
		# XML : <item n="�]�@�^">....
		# SM  : �]�@�^
		if($lines2[$index2] =~ /^<item n="(.*?)">/)
		{
		    my $tmp = $1;
		    $lines1[$index1] =~ s/^\Q${tmp}\E//;
			$lines2[$index2] =~ s/^(<item n="(.*?)">)//;
			$tagbuff .= $1;
			next;
		}

        # rdg ���G��, �@�حn�L�o(�հ�), �@�حn�q�L(�׭q)

	    #<rdg wit="�i�j�j">��</rdg>(�׭q)
	    if($lines2[$index2] =~ /^<rdg[^>]*wit="�i�j�j"[^>]*>/)
		{
			$lines2[$index2] =~ s/^(<rdg[^>]*wit="�i�j�j"[^>]*>)//;
			$tagbuff .= $1;
			next;
		}
		
	    # �L�o(�հ�)
	    if($lines2[$index2] =~ /^<rdg.*?>.*?<\/rdg>/)			
	    {
		    $lines2[$index2] =~ s/^(<rdg.*?>.*?<\/rdg>)//;
			$tagbuff .= $1;
			next;
	    }
	    
	    # �L�o <t lang="san" resp="Taisho" place="foot">D&imacron;rgha-&amacron;gama</t>
	    #if($lines2[$index2] =~ /^<t[^>]*lang="(?:(?:san)|(?:pli)|(?:unknown))"[^>]*>.*?<\/t>/)			
	    if($lines2[$index2] =~ /^<t[^>]*place="foot"[^>]*>.*?<\/t>/)	
	    {
            # $lines2[$index2] =~ s/^(<t[^>]*lang="(?:(?:san)|(?:pli)|(?:unknown))"[^>]*>.*?<\/t>)//;
            $lines2[$index2] =~ s/^(<t[^>]*place="foot"[^>]*>.*?<\/t>)//;
			$tagbuff .= $1;
			next;
	    }
	    #<note n="0011004" place="foot" type="equivalent">�C��g...</note>
	    if($lines2[$index2] =~ /^<note[^>]*?type="equivalent"[^>]*?>.*?<\/note>/)			
	    {
		    $lines2[$index2] =~ s/^(<note[^>]*?type="equivalent"[^>]*?>.*?<\/note>)//;
			$tagbuff .= $1;
			next;
	    }
	    #<note n="0578006" place="foot" type="rest">�~���D�b�����D�e��i���j�i���j�i���j</note>
	    if($lines2[$index2] =~ /^<note[^>]*?type="rest"[^>]*?>.*?<\/note>/)			
	    {
		    $lines2[$index2] =~ s/^(<note[^>]*?type="rest"[^>]*?>.*?<\/note>)//;
			$tagbuff .= $1;
			next;
	    }
	    
	    #<foreign n="0434012" lang="pli" resp="Taisho" place="foot">Niga&ndotblw...</foreign>
	    if($lines2[$index2] =~ /^<foreign .*?>.*?<\/foreign>/)			
	    {
		    $lines2[$index2] =~ s/^(<foreign .*?>.*?<\/foreign>)//;
			$tagbuff .= $1;
			next;
	    }
	    #<note n="0030012" place="foot" type="cf.">
	    if($lines2[$index2] =~ /^<note[^>]*?type="cf\."[^>]*?>.*?<\/note>/)			
	    {
		    $lines2[$index2] =~ s/^(<note[^>]*?type="cf\."[^>]*?>.*?<\/note>)//;
			$tagbuff .= $1;
			next;
	    }
	    
	    # <note n="0150002" resp="CBETA" type="mod">�ǡש��i���j�i���j�i���j</note>
	    if($lines2[$index2] =~ /^<note[^>]*?resp="CBETA"[^>]*?>.*?<\/note>/)			
	    {
		    $lines2[$index2] =~ s/^(<note[^>]*?resp="CBETA"[^>]*?>.*?<\/note>)//;
			$tagbuff .= $1;
			next;
	    }
	    
	    # �W�������ǭn�b�e
	    # ���U�o�������ǭn�b��
	    
		if($lines2[$index2] =~ /^<note.*?>/ or $lines2[$index2] =~ /^<\/note>/)
		{
			last;
		}
	
		if($lines2[$index2] =~ /^<anchor.*?>/ or $lines2[$index2] =~ /^<app[^>]*type="��"[^>]*>/)
		{
			last;
		}
		
		#if($lines2[$index2] =~ /^<p[^>]*?place="inline"[^>]*?>/)
		#{
		#	last;
		#}
		
		if($lines2[$index2] =~ /^<figure.*?>/)
		{
			last;
		}
	
		if($lines2[$index2] =~ /^<tt>/)
		{
		    $lines2[$index2] =~ s/^(<tt>)//;
			$tagbuff .= $1;
			if($istt == 0)
			{
			    $istt = 1;
			}
			next;
		}
		
		if($lines2[$index2] =~ /^<t lang="san-sd">/)
		{
		    $whicht = 1;
		    $lines2[$index2] =~ s/^(<t lang="san-sd">)//;
			$tagbuff .= $1;
			next;
		}
		if($lines2[$index2] =~ /^<t lang="chi">/)
		{
		    $whicht = 2;
		    $lines2[$index2] =~ s/^(<t lang="chi">)//;
			$tagbuff .= $1;
			next;
		}
		
		if($lines2[$index2] =~ /^<sg.*?>/)
		{
			last;
		}
		if($lines2[$index2] =~ /^<\/sg>/)
		{
			last;
		}
		
		# ----- �ݭn�B�z���аO�b��b�����e

		if($lines2[$index2] =~ /^<.*?>/)
		{
			$lines2[$index2] =~ s/^(<.*?>)//;
			$tagbuff .= $1;
			next;
		}

		if($lines2[$index2] =~ /^�@/)
		{
			$lines2[$index2] =~ s/^(�@)//;
			$tagbuff .= $1;
			next;
		}
		
		if($lines2[$index2] =~ /^&lac;/)
		{
			$lines2[$index2] =~ s/^(&lac;)//;
			$tagbuff .= $1;
			next;
		}

		if($lines2[$index2] =~ /^�C/)
		{
			$lines2[$index2] =~ s/^(�C)//;
			$tagbuff .= $1;
			$hasdot2 = 1;
			next;
		}

		if($lines2[$index2] =~ /^�D/)
		{
			$lines2[$index2] =~ s/^(�D)//;
			$tagbuff .= $1;
			$hasdot2 = 2;
			next;
		}
		
		if($lines2[$index2] =~ /^\xd/)
		{
			$lines2[$index2] =~ s/^(\xd)//;
			$tagbuff .= $1;
			next;
		}

		last;
	}
	
	$_ = $lines2[$index2];
	
	# ���歺  X79n1563_p0657a09_##

	if(/^<lb.*?\/>/)
	{
		$lines2[$index2] =~ s/^(<lb.*?\/>)//;
		if($istt == 2 and $index1 < $#lines1)
		{
		    # ��ĤG���٭�
		    $lines1[$index1+1] =~ s/^(.*?)([TX]\d\dn.{5}p.{7}.{3})/$2$1/;
		}
		$istt = 0;
		return "$1";
	}
	
	# <note n="0150001" resp="Taisho" type="orig" place="foot text">���Ķ�g�T�áק��i���j</note>
	if(/^<note[^>]*?resp="Taisho"[^>]*?>[^<]*?<\/note>/)			
	{
		$lines2[$index2] =~ s/^(<note[^>]*?resp="Taisho"[^>]*?>[^<]*?<\/note>)//;
		return "$1";
	}

	if(/^<note.*?>/)			# <note place="inline">...</note>
	{
		$lines2[$index2] =~ s/^(<note.*?>)//;
		return "$1";
	}
	if(/^<\/note>/)				# <note place="inline">...</note>
	{
		$lines2[$index2] =~ s/^(<\/note>)//;
		return "$1";
	}
	if(/^<anchor.*?>/)
	{
		$lines2[$index2] =~ s/^(<anchor.*?>)//;
		return "$1";
	}
	if(/^<app[^>]*type="��"[^>]*>/)
	{
		$lines2[$index2] =~ s/^(<app[^>]*type="��"[^>]*>)//;
		return "$1";
	}
	
	#if(/^<p[^>]*?place="inline"[^>]*?>/)
	#{
	#	$lines2[$index2] =~ s/^(<p[^>]*?place="inline"[^>]*?>)//;
	#	return "$1";
	#}
	if(/^&((CB)|(CI)|(M)|(SD)).*?;/)		# �ʦr
	{
		$lines2[$index2] =~ s/^(&((CB)|(CI)|(M)|(SD)).*?;)//;
		return "$1";
	}
	if(/^&.((macron)|(dotblw)|(dotabv)|(tilde)|(acute));/)		# �ڧQ��
	{
		$lines2[$index2] =~ s/^(&.((macron)|(dotblw)|(dotabv)|(tilde)|(acute));)//;
		return "$1";
	}
	if(/^<figure.*?>/)		# ��
	{
		$lines2[$index2] =~ s/^(<figure.*?>)//;
		return "$1";
	}
	if(/^<sg.*?>/)		# <sg>
	{
		$lines2[$index2] =~ s/^(<sg.*?>)//;
		return "$1";
	}
	if(/^<\/sg>/)		# <sg>
	{
		$lines2[$index2] =~ s/^(<\/sg>)//;
		return "$1";
	}
	
	if(/^\[��\]/)		# <app><lem resp="CBETA.say"></lem><rdg wit="�i�j�j">[��]</rdg></app>
	{
		$lines2[$index2] =~ s/^(\[��\])//;
		return "$1";
	}	
	if(/^\[\d+[A-Za-z]?]/)		# T01n0026 : <lb n="0433a23"/>....rdg wit="�i�j�j">[11]</rdg></app>
	{
		$lines2[$index2] =~ s/^(\[\d+[A-Za-z]?\])//;
		return "$1";
	}

	if(/^$big5/)			# �@��r
	{
		$lines2[$index2] =~ s/^($big5)//;
		return "$1";
	}
}

################################################################
# �P�_�G�̬O�_�ۦP
################################################################

sub check_2_word
{
	my $word1 = shift;
	my $word2 = shift;
	
	if($word2 eq "��")
	{
	    my $debug = 1;
	}
	
	if($word1 eq $word2)
	{
		return 1;
	}
	
	# �ˬd�O���O�歺
	
	if($word2 =~ /<lb/ and $word2 =~ /$word1/)
	{
		return 1;
	}
	
	if($word2 =~ /&CB.*?;/ and $word1 =~ /\[/)		# �ʦr, �ݧP�_
	{
		return 1;
	}	
	
	if($word2 =~ /&SD.*?;/ and $word1 =~ /��/)		# �x��r
	{
		return 1;
	}
	if($word2 =~ /&SD-D953;/ and $word1 =~ /�K/)		# �x��r
	{
		return 1;
	}
	if($word2 =~ /&SD-E35A;/ and $word1 =~ /�]/)		# �x��r
	{
		return 1;
	}
	if($word2 =~ /&SD-E35B;/ and $word1 =~ /\Q�^\E/)		# �x��r
	{
		return 1;
	}
	if($word2 =~ /&SD-E347;/ and $word1 =~ /\Q��\E/)		# �x��r
	{
		return 1;
	}
	
	
	
	if($word2 =~ /&CI.*?;/ and $word1 eq "&CIxxx;")		# �q�ε�
	{
		return 1;
	}
	
	if($word2 =~ /&M.*?;/ and $word1 =~ /(��)|(��)|(��)|(��)|(��)|(��)|(��)/)		# �ʦr, �ݧP�_
	{
		return 1;
	}
	
	if($word2 =~ /<note[^>]*?resp="Taisho"[^>]*?>[^<]*?<\/note>/ and $word1 =~ /\[((\d+[A-Za-z]?)|(��))\]/)
	{
		return 1;
	}	
	
	if($word2 =~ /<anchor.*?>/ and $word1 =~ /\[((\d+[A-Za-z]?)|(��))\]/)
	{
		return 1;
	}
	
	if($word2 =~ /<app[^>]*type="��"[^>]*>/ and $word1 =~ /\[��\]/)
	{
		return 1;
	}
	
	if($word2 =~ /<note.*?>/ and $word1 eq "(")
	{
		return 1;
	}
	
	if($word2 eq "</note>" and $word1 eq ")")
	{
		return 1;
	}
	
	if($word2 =~ /<sg.*?>/ and $word1 eq "(")
	{
		return 1;
	}
	
	if($word2 eq "</sg>" and $word1 eq ")")
	{
		return 1;
	}
	
	#if($word2 =~ /<p[^>]*?place="inline"[^>]*?>/ and $word1 eq "��")
	#{
	#	return 1;
	#}

	if($word2 =~ /<figure.*?>/ and $word1 eq "�i�ϡj")
	{
		return 1;
	}	

	return 0;
}