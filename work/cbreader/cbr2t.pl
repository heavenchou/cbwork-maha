#############################################
# $Id: cbr2t.pl,v 1.5 2009/03/16 09:02:38 heaven Exp $
# �N cbreader ���ͪ� html �ɧ˦��¤�r��
#############################################

$vol = shift;
#exit if $vol eq "";

# �ӷ��ؿ�, �]�N�O cbreader ���ͪ� html �ɥؿ�
$source_path = "c:/release/cbr_out/";

$filename = "$source_path${vol}/*.htm";
$big5='(?:(?:[\x80-\xff][\x40-\xff])|(?:[\x00-\x7f]))';


@files = <${filename}>;
open OUT, ">${vol}_cbr.txt";

foreach $file (sort(@files))
{
	open IN, $file;
	h2t();
	close IN;
}

close OUT;

###########################

sub h2t()
{
	local $_;
	
	while(<IN>)
	{
		next unless (/^name="\d{4}.\d\d"/);

		# name="0016b19" id="0016b19"><span class="linehead">T01n0001_p0016b19��</span>
		# �h�Y�h��
		
		s/^.*?class="linehead">(.*?)<\/span>/$1/;
		s/<br><a \n/\n/;

		s/��lac�F//g;
		s#<span class="corr">(.*?)</span>#$1#g;		# �]���аO���_��, �ҥH�n���B�z
		s/<img src=".*?sd-gif.*?">/��/g;
		s/<img src=.*?>/�i�ϡj/g;
		s/<[^<]*?>//g;		# �h�аO
		s/<[^<]*?>//g;		# �h�аO
		s/<[^<]*?>//g;		# �h�аO
		s/\[(\d[a-zA-Z]?)\]/\[0$1\]/g;	# �N�հɼƦr�˦��G���
		if(/^T/)
		{
			s/\[(\d\d)[a]\]/\[$1\]/g;
			s/\[\d\d[b-z]\]//g;
		}
		else
		{
			s/\[(\d\d)[a-z]\]/\[$1\]/g;
		}
		print OUT;
	}
}