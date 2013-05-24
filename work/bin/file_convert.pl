############################################################################
#
# files convert                                                    by heaven
#
# �N�G�ӥؿ����ɮװ��@�ǳB�z, �Ҧp big5 to utf8, �զr�� to �q�Φr , �άO���
#
############################################################################

use Win32::ODBC;

#####################
# �Ѽ�
#####################

##########################################
# ����\��
# 1. �G���ɮפ�� : comp2file
# 2. �զr���ন�q�Φr : des2nor
# 3. big5 �ন utf8 : big52utf8
# 4. �N utf8 �ܦ� big5 �榡, ���L�o�̬O�@�U�����@��
##########################################

my $function = "comp2file";		# ���G�ӥؿ����ɮ�
# my $function = "des2nor";			# �N �զr�� �ܦ� �q�Φr �榡
# my $function = "big52utf8";		# �N big5 �ܦ� utf8 �榡
# my $function = "utf82big5";		# �N utf8 �ܦ� big5 �榡, �@�U�����@��, �B���γ] source_root ��target_root

my $source_root = "C:/cbwork/simple/release/normal/";		# �ӷ��ؿ�

# my $source_root = "C:/release/normal-des/";					# �ӷ��ؿ�
# my $source_root = "c:/release/app1-des/";					# �ӷ��ؿ�

# my $source_root = "C:/cbwork/xml/";						# �ӷ��ؿ�

##my $source_root = "C:/Release/cbr_out/";					# �ӷ��ؿ�
##my $source_root = "C:/Release/app1/";						# �ӷ��ؿ�
##my $source_root = "C:/release/utf8-xml/";					# �ӷ��ؿ�
##my $source_root = "C:/release/xml-utf8/";					# �ӷ��ؿ�

my $target_root = "c:/release/normal/";			# �ت��ؿ�

# my $target_root = "c:/release/normal-des-nor/";	# �ت��ؿ�
# my $target_root = "c:/release/app1-des-nor/";		# �ت��ؿ�
# my $target_root = "c:/release/normal-des-utf8/";	# �ت��ؿ�
# my $target_root = "c:/release/app1-des-utf8/";		# �ت��ؿ�

# my $target_root = "c:/release/xml-utf8/";			# �ت��ؿ�

my $file_ext = "*.*";								# �n�B�z�����ɦW

my $TFrom = 1; 	# �j���óB�z�U�ƶ}�l
my $Tto = 85;		# �j���óB�z�U�Ƶ���
my $XFrom = 11;		# �����óB�z�U�ƶ}�l
my $Xto = 16;		# �����óB�z�U�Ƶ���

my $runT = 0;		# ����j����
my $runX = 1;		# ����������

# 1. �G���ɮפ�� �M���ܼ�

my $difffile = "2filediff.txt";		# �\�� 1 ���t����

my $skip_fullspace = 0;				# ���������ť�
my $skip_space = 0;					# �����b���ť�
my $skip_juan_head = 0;				# �����������
my $skip_enter = 1;					# ��������
my $skip_siddam = 0;				# �����x��r
my $skip_line_head = 0;				# �����歺 (app �� normal)
my $skip_para_head = 0;				# �����q�� (pda)

# 2. �զr���ন�q�Φr �M���ܼ�
# 3. big5 �ন utf8 �M���ܼ�

my $des2uni = 1;					# �O�_�n�N�ʦr���� unicode ? (xml ����, normal, app �n)
my $des2nor = 1;					# �O�_�n�N�ʦr�����q�Φr ? (xml ����, normal, app �n)(T54n2128 �� 2129 �|�۰ʨ���)

# 4. utf8 �ন big5 �M���ܼ�

my $extispdf = 1;						# �Y�B�zpdf , �h�� 1, �_�h�� 0
my $easyver = 1;						# �Y�� 1 �h�۰ʩ����歺,����P���b���Ů�, �� wincommand �Y�i���. 0 �h�d�U�歺, �� wfgfc ���.

######################## �H�U�i�H���κ� #######################################

my $ext = "_pdf.txt";					# ���X�j�ɫ᪺���W, �Ҧp T01_pdf.txt
#app �]�� 1
my $remove_linehead_eng = 0;			# �N�歺���^�崫��, ���ɤ~���Ω����^��.
my $onlyTX = 0;							# �u�d�U�歺�O TX �}�Y����r, �]�N�O�ư�����
#pdf �]�� 1
my $skiptag = 1;						# �����аO

if($function eq "utf82big5")
{
	if($extispdf) # pdf ��
	{
		$source_root = "C:/release/pdf/";						# �ӷ��ؿ�
		$target_root = "c:/release/pdf_out/pdf/";			# �ت��ؿ�
		$ext = ".txt";					# ���X�j�ɫ᪺���W, �Ҧp T01_pdf.txt
		$file_ext = "*.txt";
		#app �]�� 1
		$remove_linehead_eng = 0;			# �N�歺���^�崫��, ���ɤ~���Ω����^��.
		$onlyTX = 0;						# �u�d�U�歺�O TX �}�Y����r, �]�N�O�ư�����
		#pdf �]�� 1
		$skiptag = 1;						# �����аO
	}
	else # app ��
	{
		$source_root = "C:/Release/app1-utf8/";			# �ӷ��ؿ�
		$target_root = "c:/release/pdf_out/app1/";			# �ت��ؿ�
		$ext = ".txt";					# ���X�j�ɫ᪺���W, �Ҧp T01_pdf.txt
		$file_ext = "*.txt";
		#app �]�� 1
		$remove_linehead_eng = 1;			# �N�歺���^�崫��, ���ɤ~���Ω����^��.
		$onlyTX = 1;						# �u�d�U�歺�O TX �}�Y����r, �]�N�O�ư�����
		#pdf �]�� 1
		$skiptag = 0;						# �����аO
	}
}
####################################################################################
# �ܼ�
####################################################################################

my $utf8 = '(?:\&[^;#]+;|[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f])';
my $big5 = '(?:(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x7f]))';
my $losebig5='(?:(?:[\x80-\xff][\x40-\xff])|[\x00-\x3d]|[\x3f-\x5a]|\x5c|[\x5e-\x7f])';

####################################################################################
# �D�{��
####################################################################################

require "b52utf8.plx" if($function eq "big52utf8");  ## this is needed for handling the big5 entity replacements
require "utf8b5o.plx" if($function eq "utf82big5");  ## this is needed for handling the big5 entity replacements
require "siddam.plx"  if($function eq "utf82big5");  ## this is needed for handling the big5 entity replacements

mkdir ($target_root) unless(-d $target_root);

# Ū���ʦr

my %table;
readGaiji() if($function eq "big52utf8" or  $function eq "des2nor");

# �B�z�����ؿ�

open OUT, ">$difffile" if($function eq "comp2file");

$TFrom = 999 if($runT == 0);
$XFrom = 999 if($runX == 0);

for(my $i = $TFrom; $i<= $Tto; $i++)
{
	$i = 85 if ($i == 56);
	$vol = sprintf("T%02d", $i);
	dothisdir($vol);
}
for(my $i = $XFrom; $i<= $Xto; $i++)
{
	$i = 7 if ($i == 6);
	#$i = 54 if ($i == 11);
	$vol = sprintf("X%02d", $i);
	dothisdir($vol);
}
close OUT if($function eq "comp2file");
print "ok!\n";
<>;
exit;

# �B�z��@�ؿ�

sub dothisdir
{
	my $vol = shift;
	my $source_dir = $source_root . $vol . "/$file_ext";
	my $target_dir = $target_root . $vol . "/";
	if($function eq "utf82big5")	# utf8 2 big5 ���ݭn�l�ؿ�, �]���ڭn�@�U�����@�j��
	{
		open OUT, ">${target_root}${vol}${ext}" or die "open ${target_root}${vol}${ext} error";
	}
	else
	{
		mkdir ($target_dir) unless(-d $target_dir);
	}
	my @files = <{$source_dir}>;
	foreach my $file (sort(@files))
	{
		my $outfile = $file;
		if($file =~ /.*\/(.*)/)
		{
			$outfile = $1;
		}
		dothisfile($file, "${target_dir}$outfile");
	}
	close OUT if($function eq "utf82big5");	# utf8 2 big5 ���ݭn�l�ؿ�, �]���ڭn�@�U�����@�j��
}

# �B�z��@�ɮ�

sub dothisfile
{
	my $file_from = shift;
	my $file_to = shift;
	print $file_from . "\n";
	
	##########################################################################
	if($function eq "big52utf8" or  $function eq "des2nor")
	{
		open IN, "$file_from" or die "open $file_from error";
		open OUT, ">$file_to" or die "open $file_to error";
		
		while(<IN>)
		{
			$_ = big52utf8ln($_) if ($function eq "big52utf8");
			$_ = des2norln($_) if ($function eq "des2nor");
			print OUT;
		}

		close OUT;
		close IN;
	}
	# utf8 2 big5 ##################################################################
	elsif ($function eq "utf82big5")	
	{
		open IN, "$file_from" or die "open $file_from error";

		if($skiptag)
		{
			while(<IN>)
			{
				last if(/Vol\./);
			}
			<IN>;
		}	
		while(<IN>)
		{
			if($onlyTX)
			{
				next unless(/^[TX]/);
			}
			if($skiptag)
			{
				s/<.*?>//g;
				s/^\s*P. (\d+)$//;
			}
			$_ = utf82big5ln($_);
			#s/�j���s��j���øg/�÷sġ���øg/;
			#s/2005\/3\/26/2005\/4\/5/;

			print OUT;
		}

		close IN;
	}
	# ����ɮ� ##########################################################################
	elsif ($function eq "comp2file")	
	{
		my $space = '�@';
		open IN, "$file_from" or die "1 open $file_from error";
		open IN1, "$file_to" or die "2 open $file_to error";
		print OUT "$file_from\n";
		while(<IN>)
		{
			#next if(/<!ENTITY CB00108/);
			my $line = <IN1>;
		
			#while($line =~ /^(([#=])|(�i))/)	###########----------------------------------
			#{
			#	$line = <IN1>;
			#}
			if($_ ne $line)
			{
				#my $skip_fullspace = 0;				# ���������ť�
				#my $skip_space = 0;					# �����b���ť�
				#my $skip_juan_head = 0;				# �����������
				#my $skip_enter = 0;					# ��������
				#my $skip_siddam = 1;					# �����x��r
				#my $skip_line_head = 0;				# �����歺 (app �� normal)
				#my $skip_para_head = 0;				# �����q�� (pda)
				
				my $line1 = $_;
				my $line2 = $line;
				
				if($skip_juan_head)				# �����������
				{
					if(/^((#)|(�i))/)
					{
						next;
					}
				}
				if($skip_fullspace)				# ���������ť�
				{
					$line1 =~ s/$space//g;
					$line2 =~ s/$space//g;
				}
				if($skip_space)					# �����b���ť�
				{
					$line1 =~ s/ //g;
					$line2 =~ s/ //g;
				}
				if($skip_enter)					# ��������
				{
					$line1 =~ s/\n$//;
					$line2 =~ s/\n$//;
					$_ =~ s/(\n)?$/\n/;
					$line =~ s/(\n)?$/\n/;
				}
			#	$line1 =~ s/����/��/;###########----------------------------------
			#	$line2 =~ s/����/��/;###########----------------------------------
			#	$line1 =~ s/��$//;###########----------------------------------
			#	$line2 =~ s/��$//;###########----------------------------------

				#while(/^((${big5})*)��/)
				#{
				#	s/^((${big5})*)��/$1�K/;
				#}
				#$_ =~ s=\Q[��*��]\E=�f=g;
				#$_ =~ s=\Q[��/��]\E=��=g;
				#$_ =~ s=\Q[��*�P]\E=�{=g;
				#$_ =~ s=\Q[��*(��-��+�g)]\E=��=g;
				#$_ =~ s=\Q[��-�B+��]\E=��=g;
				#$_ =~ s=\Q[��/��]\E=��=g;
				#$_ =~ s=\Q[��*��]\E=��=g;
				#$_ =~ s=\Q[��*��]\E=�G=g;
				#$_ =~ s=\Q[��-�B+��]\E=�=g;
				#$_ =~ s=\Q[��/��]\E=��=g;
				#$_ =~ s=\Q[��/��]\E=��=g;
				#$_ =~ s=\Q[��*��]\E=��=g;
			
				if($line1 ne $line2)
				{
					if($skip_siddam)					# �����x��r
					{
						while($line1 =~ /^(?:$big5)*?(([a-zA-Z`\.^~! ])|(�i���j)|(��)|(��)|(�E)|(�e)|(�f)|(�])|(\Q�^\E)|(�K))/)
						{
							$line1 =~ s/^(($big5)*?)(([a-zA-Z`\.^~! ])|(�i���j)|(��)|(��)|(�E)|(�e)|(�f)|(�])|(\Q�^\E)|(�K))/$1/;
						}
						while($line2 =~ /^(?:$big5)*?(([a-zA-Z`\.^~! ])|(�i���j)|(��)|(��)|(�E)|(�e)|(�f)|(�])|(\Q�^\E)|(�K))/)
						{
							$line2 =~ s/^(($big5)*?)(([a-zA-Z`\.^~! ])|(�i���j)|(��)|(��)|(�E)|(�e)|(�f)|(�])|(\Q�^\E)|(�K))/$1/;
						}
					}
					
					###############
					#if($line1 =~ /<edition>/) { $line1 =~ s/\(Big5\)/(UTF-8)/;}
					#$line1 =~ s/n="\d+" label/label/;
					#$line1 =~ s/div[321]/divn/;
					#$line2 =~ s/div[321]/divn/;
					#$line1 =~ s/level="[321]"/level="n"/;
					#$line2 =~ s/level="[321]"/level="n"/;
					#$line1 =~ s/uniflag='[210]'//;
					#$line2 =~ s/uniflag='[210]'//;
					#$line1 =~ s/<!-- -\*- charset: CP950 -\*- -->//;
					#$line2 =~ s/<!-- -\*- charset: CP950 -\*- -->//;
					#$line1 =~ s/ uni='.*?'//;
					#$line2 =~ s/ uni='.*?'//;
					###############
					
					if($line1 ne $line2)
					{
						print OUT "$_";
						print OUT "$line";
						print OUT "-----------------------------------------------\n";
					}
				}
			}
		}
		close IN;
		close IN1;		
	}
	##########################################################################
}

#############################################################################
# function : big5 to utf8

sub big52utf8ln
{
	my $line = shift;
	
	$line =~ s/encoding="big5"/encoding="UTF-8"/;		# xml ��
	$line =~ s/coding: big5-dos/charset: CP950/;		# xml ��
	$line =~ s/\(Big5\)/\(UTF-8\)/i;
	my $result = "";
	my $mydes2nor = $des2nor;
	
	if(($line =~ /T54n212[89]/) or ($line =~ /T34n1723_p0776c11/))
	{
		$mydes2nor = 0;
	}
	
	if($mydes2nor)	# ���ݭn�����q�Φr, �ҥH�����q�ε�
	{
		if($des2uni == 0)	# �Y�n���� unicode , ���U�o�ǴN���δ����q�ε�
		{
			$line =~ s=\Q����[�I/��][�I/��]\E=�ϧϩ���=g;
		
		    $line =~ s/\Q�Y[��*��]\E/�R�E/g;
			$line =~ s/\Q[��*�O]�M\E/�D��/g;
			$line =~ s=\Q��[�I/��]\E=�ϩ�=g;
			$line =~ s/\Q�e[��-�B+��]\E/���/g;
			$line =~ s=\Q[�I/��]��\E=����=g;
			$line =~ s/\Q��[�k*��]\E/����/g;
			$line =~ s=\Q[�@/��][��*��]\E=�R�E=g;
			#$line =~ s/\Q�w[��*�C]\E/��x/g;
			#$line =~ s=\Q��[��*�C]\E=��x=g;
		}
		
		# �o�ǬO�S�� unicode ��
		
		$line =~ s/\Q[��*��]��\E/�J��/g;
		$line =~ s=\Q�y[��*��]\E=�e��=g;
		$line =~ s=\Q[��*��][��*��]\E=���=g;
		$line =~ s/\Q[��-�G+��][��-�G+��]\E/���/g;
		$line =~ s=\Q[��*��][��*��]\E=�Ӧ�=g;
	}

	while($line =~ /^($big5)/)
	{
		my $token = $1;
		if($line =~ /^(\[$losebig5*?\])/)	# �O�զr��
		{
			my $loseword = $1;
			if($des2uni)	# �n�N�զr������ unicode 
			{
				if($table_uni{$loseword})				# ���զr���� unicode
				{
					$result .= $table_uni{$loseword};
					$line =~ s/^\Q$loseword\E//;
					next;
				}
			}

			if($mydes2nor)	# �n�N�զr������ normal
			{
				if($table_nor{$loseword})				# ���զr�����q�Φr
				{
					$token = $table_nor{$loseword};
					$line =~ s/^\Q$loseword\E/$token/;
				}
			}
		}
		
		# �ܦ�, �զr�������� unicode , �άO�D�զr��, �άO�զr���L unicode 
		
		if (exists $b52utf8{$token}) 
		{
			$result .= $b52utf8{$token};
			$line =~ s/^\Q$token\E//;
		}
		else
		{
			print STDERR "$line\n";
			print STDERR "$token\n";
			die "Error: not in big52utf8 table. char:[$token] hex:" . unpack("H4",$token) ;
		}
	}
	return $result;
}

#############################################################################
# function : �զr�������q�Φr

sub des2norln
{
	local $_ = shift;
	
	# �� 2128 �� 2129 �g�άY�椣�δ��q�Φr
	
	if(($_ !~ /T54n212[89]/) and ($_ !~ /T34n1723_p0776c11/))
	{
		# ���q�ε�
		
		s=\Q����[�I/��][�I/��]\E=�ϧϩ���=g;
		
		s/\Q�Y[��*��]\E/�R�E/g;
		s/\Q[��*�O]�M\E/�D��/g;
		s=\Q��[�I/��]\E=�ϩ�=g;
		s/\Q[��*��]��\E/�J��/g;
		s/\Q�e[��-�B+��]\E/���/g;
		s=\Q[�I/��]��\E=����=g;
		s=\Q�y[��*��]\E=�e��=g;
		s/\Q��[�k*��]\E/����/g;
		s=\Q[�@/��][��*��]\E=�R�E=g;
		#s/\Q�w[��*�C]\E/��x/g;
		s=\Q[��*��][��*��]\E=���=g;
		s/\Q[��-�G+��][��-�G+��]\E/���/g;
		s=\Q[��*��][��*��]\E=�Ӧ�=g;
		#s=\Q��[��*�C]\E=��x=g;
		
		# ���q�Φr
		
		s/(\[$losebig5*?\])/($table_nor{$1}||$1)/ge;
	}
	return $_;
}

#############################################################################
# function : utf82big5

sub utf82big5ln
{
	local $line = shift;
	my $result = "";
	
	while($line =~ /^($utf8)/)
	{
		my $token = $1;

		if (exists $utf8out{$token}) 
		{
			if($easyver == 1)
			{ 
				if($utf8out{$token} eq "��")	# �o�ǬO����諸�Ÿ�
				{
				}
				elsif($utf8out{$token} eq "�C")
				{
				}
				else
				{
					$result .= $utf8out{$token};
				}
			}
			else
			{
				$result .= $utf8out{$token};
			}
			$line =~ s/^\Q$token\E//;
		}
		else
		{			
			my $tmp = uc(unpack("H*",$token));
			my $c = uc(unpack("H*",UTF8toUCS2($token)));
			
			if(exists $sd2dia{$c})
			{
				$tmp = cbdia2smdia($sd2dia{$c});		# �x��r
			}
			else
			{
				$tmp = "&$tmp;";
			}

			$tmp = "AA" if($tmp eq "&C480;");
			$tmp = "aa" if($tmp eq "&C481;");
			$tmp = "ii" if($tmp eq "&C4AB;");
			$tmp = "^n" if($tmp eq "&E1B985;");
			$tmp = "~n" if($tmp eq "&C3B1;");
			$tmp = ".t" if($tmp eq "&E1B9AD;");
			$tmp = ".n" if($tmp eq "&E1B987;");
			$tmp = "uu" if($tmp eq "&C5AB;");
			$tmp = ".d" if($tmp eq "&E1B88D;");	
			$tmp = "`s" if($tmp eq "&C59B;");	
			$tmp = ".m" if($tmp eq "&E1B983;");
			$tmp = ".s" if($tmp eq "&E1B9A3;");
			$tmp = ".h" if($tmp eq "&E1B8A5;");
			$tmp = ".r" if($tmp eq "&E1B99B;");
			$tmp = "^m" if($tmp eq "&E1B981;");
			$tmp = "�]" if($tmp eq "&EE8D9A;");
			$tmp = "�^" if($tmp eq "&EE8D9B;");
			$tmp = "�K" if($tmp eq "&EDA593;");
			$tmp = "��" if($tmp eq "&EE8D87;");
			$tmp = "�E" if($tmp eq "&EE8EBA;");
			$tmp = "��" if($tmp eq "&EDA597;");
			$tmp = "��" if($tmp eq "&ED9F84;");	
			$tmp = "��" if($tmp eq "&ED96B4;");
			$tmp = "��" if($tmp eq "&EDA786;");
			$tmp = "��" if($tmp eq "&EE8D95;");
			
		
			$result .= $tmp;
			$line =~ s/^\Q$token\E//;
		}
	}
	if($remove_linehead_eng)
	{
		# T01n0098_p0924b02(02)��
		if($easyver)
		{
			$result =~ s/^[TX](\d\d)n(\d\d\d\d).p(\d\d\d\d).(\d\d).*?��//i;
		}
		else
		{
			$result =~ s/^[TX](\d\d)n(\d\d\d\d).p(\d\d\d\d)a(\d\d).*?��/$1_$2_$3_1_$4/i;
			$result =~ s/^[TX](\d\d)n(\d\d\d\d).p(\d\d\d\d)b(\d\d).*?��/$1_$2_$3_2_$4/i;
			$result =~ s/^[TX](\d\d)n(\d\d\d\d).p(\d\d\d\d)c(\d\d).*?��/$1_$2_$3_3_$4/i;
			$result =~ s/^[TX](\d\d)n(\d\d\d\d).p(\d\d\d\d)d(\d\d).*?��/$1_$2_$3_4_$4/i;
			$result =~ s/^[TX](\d\d)n(\d\d\d\d).p(\d\d\d\d)e(\d\d).*?��/$1_$2_$3_5_$4/i;
			$result =~ s/^[TX](\d\d)n(\d\d\d\d).p(\d\d\d\d)f(\d\d).*?��/$1_$2_$3_6_$4/i;
			$result =~ s/^[TX](\d\d)n(\d\d\d\d).p(\d\d\d\d)g(\d\d).*?��/$1_$2_$3_7_$4/i;
			$result =~ s/^[TX](\d\d)n(\d\d\d\d).p(\d\d\d\d)h(\d\d).*?��/$1_$2_$3_8_$4/i;
			$result =~ s/^[TX](\d\d)n(\d\d\d\d).p(\d\d\d\d)i(\d\d).*?��/$1_$2_$3_9_$4/i;
		}
	}
	if($easyver)
	{
		$result =~ s/ //g;
		$result =~ s/�@//g;
		$result =~ s/\n//g;
		$result =~ s/�i�ϡj//g;
	}
	$result =~ s/\x0c//g;
	return $result;
}

#############################################################################
# Ū�ʦr

sub readGaiji {
	my $cb,$des,$nor,$uni,$uniflag;
	print STDERR "Reading Gaiji-m.mdb ....";
	my $db = new Win32::ODBC("gaiji-m");
	if ($db->Sql("SELECT * FROM gaiji")) { die "gaiji-m.mdb SQL failure"; }
	while($db->FetchRow())
	{
		undef %row;
		%row = $db->DataHash();
		
		$cb  = $row{"cb"};		# cbeta code
		$des = $row{"des"};		# �զr��
		$nor = $row{"nor"};		# �q�Φr
		$uni = $row{"uni"};		# unicode
		$uniflag = $row{"uni_flag"};		# unicode flag : 0 �ݤ���, 1 �ݪ���, 2 �٨S�T�w
		
		next if ($cb !~ /^\d/);
		
		if($uni and $uniflag == 1)
		{
			my $val = pack "H4", $uni;
			$val = toutf8($val);		# unicode -> utf8
			$table_uni{$des} = $val;
		}
		
		if($nor)
		{
			$table_nor{$des} = $nor;
		}
	}
	$db->Close();

	# �B�~��, �o�O�b des2normal ��, �Y�Ǧr�����n�B�z, �H�t�X�ª��q�Φr���e
	
	#$table_nor{"[��*��]"} = "��";
	#$table_nor{"[��*��]"} = "";
	#$table_nor{"[��/��]"} = "";
	#$table_nor{"[��*�P]"} = "";
	#$table_nor{"[��*(��-��+�g)]"} = "";
	#$table_nor{"[��-�B+��]"} = "";
	#$table_nor{"[��/��]"} = "";
	#$table_nor{"[��*��]"} = "";
	#$table_nor{"[��*��]"} = "";
	#$table_nor{"[��-�B+��]"} = "";
	#$table_nor{"[��/��]"} = "";
	#$table_nor{"[��/��]"} = "";
	#$table_nor{"[��*��]"} = "";

	print STDERR "ok\n";
}

# unicode to utf8

sub toutf8
{
	my $in = $_[0];
	my $old;
	# encode UTF-8
	my $uc;
	for $uc (unpack("n*", $in)) {
#        print "$uc\n";
	    if ($uc < 0x80) {
		# 1 byte representation
		$old .= chr($uc);
	    } elsif ($uc < 0x800) {
		# 2 byte representation
		$old .= chr(0xC0 | ($uc >> 6)) .
	                chr(0x80 | ($uc & 0x3F));
	    } else {
		# 3 byte representation
		$old .= chr(0xE0 | ($uc >> 12)) .
		        chr(0x80 | (($uc >> 6) & 0x3F)) .
			chr(0x80 | ($uc & 0x3F));
	    }
	}
	return $old;
}

sub UTF8toUCS2 () {
	my $bytes = shift;
	if ($bytes eq "") {
		return "";
	}
	my $save = $bytes;
	if ($bytes =~ /^([\x00-\x7f])$/) {
		pack("n*",unpack("C*",$1));
	} elsif ($bytes =~ /^([\xC0-\xDF])([\x80-\xBF])$/) {
		pack("n", ((ord($1) & 31) << 6) | (ord($2) & 63) );
	} elsif ($bytes =~ /^([\xE0-\xEF])([\x80-\xBF])([\x80-\xBF])/) {
		pack("n", ((ord($1) & 15) << 12) | ((ord($2) & 63) << 6) | (ord($3) & 63));
	} else {
		die "bad UTF-8 data: [$save][" . unpack("H*",$save) . "]";
	}
}

sub toucs2
{
	local (@in) = (@_);
	local ($out) = "";
	if (defined $_[0]) {
	    my $bytes = shift @in;
	    $bytes =~ s/^[\200-\277]+//;  # can't start with 10xxxxxx
	    while (length $bytes) {
		if ($bytes =~ s/^([\000-\177]+)//) {
		    $out .= pack("n*", unpack("C*", $1));
		} elsif ($bytes =~ s/^([\300-\337])([\200-\277])//) {
		    my($b1,$b2) = (ord($1), ord($2));
		    $out .= pack("n", (($b1 & 0x1F) << 6) | ($b2 & 0x3F));
		} elsif ($bytes =~ s/^([\340-\357])([\200-\277])([\200-\277])//) {
		    my($b1,$b2,$b3) = (ord($1), ord($2), ord($3));
		    $out .= pack("n", (($b1 & 0x0F) << 12) |
                                        (($b2 & 0x3F) <<  6) |
				         ($b3 & 0x3F));
		} else {
#		    croak "Bad UTF-8 data";
		}
	    }
	} else {
	    $out = undef;
	}

    return $out;
}

sub cbdia2smdia {
	my $s=shift;
	$s=~s/n~/~n/g;
	$s=~s/a\^/aa/g;
	$s=~s/i\^/ii/g;
	$s=~s/s\//`s/g;
	$s=~s/u\^/uu/g;
	$s=~s/d!/\.d/g;
	$s=~s/h!/\.h/g;
	$s=~s/l!\^/\.ll/g;
	$s=~s/l!/\.l/g;
	$s=~s/m!/\.m/g;
	$s=~s/n%/^n/g;
	$s=~s/n!/\.n/g;
	$s=~s/r!\^/\.rr/g;
	$s=~s/r!/\.r/g;
	$s=~s/s!/\.s/g;
	$s=~s/t!/\.t/g;
	return $s;
}