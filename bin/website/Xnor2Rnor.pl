#!/usr/local/bin/perl
##########################################################
# �N X ���� normal/app1 �������ন R ���� normal/app1 ����
##########################################################

#######################################
#�i�ק�Ѽ�
#######################################

$from_vol = 1;		# �}�l�U��
$to_vol = 88;		# �����U��

$source_path = "c:/release/normal/";
$out_path = "c:/release/normal_R/";

# $source_path = "c:/release/app1/";
# $out_path = "c:/release/app1_R/";

$XtoRPath = "c:/cbwork/common/X2R/";            # ������ X to R ������Ӫ�

$TX = "X";			# �ثe�u�����򦳪����ഫ���ݨD
#######################################
# �D�{��
#######################################

mkdir($out_path) unless(-d $out_path);

# �U�U�ǳƤu�@

for(my $i=$from_vol; $i<=$to_vol; $i++)
{
	$i = 7 if ($i == 6);
	$i = 53 if ($i == 52);
	
	$vol = $TX . sprintf("%02d", $i);
	@files = <${source_path}${vol}/*.txt>;

	$XtoRfile = "${XtoRPath}${vol}R.txt";
	getx2r();
	
	doit();
	print "$vol ok\n";
}

exit;

sub getx2r()
{
	# xr['0420a04']='1350595a01';
	# X78n1553_p0420a03��R135_pxxxxxxx
    # X78n1553_p0420a04��R135_p0595a01
	undef %X2R;
	#for($i=0; $i<=$#XtoRfiles; $i++)
    {
    	open IN, "$XtoRfile" || die "$_";
    	while(<IN>)
    	{
	    	# xr['0420a04']='1350595a01';
	    	#if(/xr\['(.{7})'\]='(.{10})'/)
	    	# X78n1553_p0420a03��R135_pxxxxxxx
            # X78n1553_p0420a04��R135_p0595a01
    		if(/X..n.{6}(.{7}).*?(R.{5}\d{4}.{3})/)
    		{
    			$X2R{$1} = $2;
    		}
    	}
    	close IN;
    }
}

sub doit()
{
    my $i;

    @files = sort(@files);
    for($i=0; $i<=$#files; $i++)
    { 	
    	my $file = $files[$i];
		open IN, $file;
		@txt = <IN>;
		close IN;
	
		#unlink($file);

		if($file =~ /(X.{7,8})\.txt$/)  # app ��
		{
		    $outfile = $1;
		    print $outfile . "\n";
		    $outfile = "${out_path}R${vol}/R${outfile}.txt";
		}
		elsif($file =~ /(\d{4}.\d{3})\.txt$/)  # app ��
		{
		    $outfile = $1;
		    print $outfile . "\n";
		    $outfile = "${out_path}R${vol}/${outfile}.txt";
		}
		else
		{
		    print "unknow file : $file\n";
		    print "any key exit...\n";
		    <>;
		    exit;
		}
		
		mkdir("${out_path}R${vol}","0777") if(not -d "${out_path}R${vol}");
	
		open OUT, ">$outfile";

		# �L�X�g�夺�e

		foreach $_ (@txt)
		{
			if(/^X..n.....p(.{7}).*?��(.*)/)
			{
				chomp;
				# X78n1553_p0420a11
				# R135_p0595a01
				# xr['0420a04']='1350595a01';

				$rtmp = $X2R{$1};
				$data = $2;
			
				#X78n1553_p0420a01
				#<span id=head X="X78n1553_p0420a06" R="R135_p0595a06"></span>

				if($rtmp eq "")
				{
					if($data eq "")
					{
						s/^.*$//;
					}
					else
					{
						s/^X(..)n.....(p.{7}.*)/X0$1_$2\n/;
					}
				}
				else
				{
					s/^X..n.....p.{7}(.*)/$rtmp$1\n/;
				}
			}
			else
			{
				#s/��Ʈw�򥻤��Сj/��Ʈw���v�ŧi�j/;
				#s/result\/cbintr.htm/copyright.htm/;
				#s/result\/cbintr_e.htm/copyright_e.htm/;
			}
			print OUT;
		}
		close OUT;
    }
}

