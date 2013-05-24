##############################################################
# $Id: add_zh.pl,v 1.1.1.1 2003/05/05 04:04:55 ray Exp $
#
# add_zh.pl	�N�հɱ����ɨS�����媺��ڵ��ѥ[�W����g��
#
# ���{���G�䬰�@�M
#
# add_zh.pl ���ª��հɱ��ز��ͷs���հɱ���, �åB�b����ګo�S���媺���ؤW,
#           ���W��l�g��, ���ѿ��, �H�K���J�հɱ��ؤ�.
# del_zh.pl �N�B�z�n���հɱ��ط��B�~����ƧR��, �]�N�O²��аO���g��, 
#           ��S��O�C�@�歺���O <z> �}�Y
#
# �ϥΪk: �D�n�n�ק�U�C�T�ӰѼ�
#   
#         $infile : ��l���հɱ����ɪ���m
#         $sutra : ²��аO���g�媺��m
#
#         $outfile : �n��X���s���հɱ�����
##############################################################

use strict;

#-------------------------------------------
# �M�ǤJ�ѼƦ������ܼ�
#-------------------------------------------

# �ثe�� rd, heaven �Y���S��ݨD��, �Чi�D��
my $Iam = "heaven";	
$Iam = $ARGV[0] if($ARGV[0]);	# �Y���ǤJ�Ѽ�, �h�Φ��Ѽ�

#-------------------------------------------
# �i�ק諸�ܼ�
#-------------------------------------------

my $vol = "T01";

my $infile = "${vol}�հɱ���.txt";				# �հɱ�����
my $sutra = "c:/cbwork/simple/${vol}/new.txt";	# ��l�g���ɡ]²��аO���^

#if($Iam eq "rd")
#{
#	$infile = "${vol}�հɱ���.txt";				# �հɱ�����
#	$sutra = "c:/cbwork/work/maha/${vol}/T01maha.txt";	# ��l�g���ɡ]²��аO���^
#}

my $outfile = "${vol}notenew.txt";			# �򥻿�X���G��

#-------------------------------------------
# �L�ݭק諸�Ѽ�
#-------------------------------------------
#-------------------------------------------
# �ɮ� handle
#-------------------------------------------

local *IN;
local *OUT;

#-------------------------------------------
# �հɸ��
#-------------------------------------------

my @note;		# �հɱ���
my @sutra;		# ²��аO��

##########################################################
#  �D �{ ��
##########################################################

open IN, $infile || die "open $infile error";
@note = <IN>;	# �հɸ��
close IN;

open IN, $sutra || die "open $sutra error";
my @sutra = <IN>;	# ²��аO�g��
close IN;

open OUT, ">$outfile" || die "open $outfile error";
note_analysis();	# ²����R�հɱ���, �æs�J %note
close OUT;

select STDOUT;
print "ok [any key to exit]\n";
<>;
exit;
########################################################

sub note_analysis()
{
	my $ID;				# %note ��ID
	my $note_page;		# �հɪ���
	my $note_num;		# �հɪ��s��
	my $ptr = 0;		# �w�b²��аO���ˬd�쪺�Ʀr

	select OUT;

	for(my $i = 0;$i <= $#note; $i++)
	{
		if($note[$i] =~ /^p(\d{4})/)
		{
			$note_page = $1;
			print $note[$i];
			next;
		}

		if($note[$i] =~ /^\s*(?:��)?(\d+)\s*(?:(?:<~>)|(?:<s>)|(?:<p>)|(?:��)).+$/)	# �зǮ榡���հ�
		{
			$note_num = $1;
			print $note[$i];
			$ptr = print_sutra($ptr, $note_page, $note_num);
		}
		else					# �D�зǮ榡�հ�
		{
			print $note[$i];
		}
	}
}

###############################################

sub print_sutra()
{
	# T01n0001_p0001a04A##[02]���w�����F[03]�z
	
	local $_;
	my $ptr = shift;
	my $page = shift;
	my $note_num = shift;
	my $mypage;

	for(my $i = $ptr; $i<=$#sutra; $i++)
	{
		$_ = $sutra[$i];
		/T.{8}p(\d{4})/;
		$mypage = $1;

		if ($mypage > $page)		# ���ƶW�L�F
		{
			print "<z>\n<z> not found\n<z>\n";
			return $i;
		}
		
		if(($mypage == $page) && (/\[$note_num\]/))
		{
			print "<z>\n";
			
			print "<z>$sutra[$i-1]" if($i > 0);
			
			s/(\[$note_num\])/$1��<z>/;
			print "<z>$_";
			
			print "<z>$sutra[$i+1]" if($i < $#sutra);
			
			print "<z>\n";
			
			return $i;
		}
	}
	return $#sutra;
}

############### end #######################