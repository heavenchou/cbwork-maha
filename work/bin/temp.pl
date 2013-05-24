$pattern = '%big5%.*?%/big5%|[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f]|&[^;]*;|\<[^\>]*\>';
$sic="ечн╝д]";
		$sic = resolveEntInAtt($sic);
print $sic;
		#$sic = myDecode($sic);
