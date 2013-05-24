/*
	tool.js
	Copyright (C) 2003 Ray Chou (ray.chou@url.com.tw)

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.
	
	v0.1, 2002/11/27 06:29PM by Ray
	v0.2, �w�� Netscape 7.0, Mozilla 1.2 �ק�, 2002/11/30 03:44PM by Ray
	v0.3, 2002/12/16 03:50PM by Ray
	v0.4, 2002/12/16 04:24PM by Ray
	v0.5, ����������M���հ���, 2002/12/16 05:24PM by Ray
	v0.6, �[�������D, 2002/12/19 11:54AM by Ray
	v0.7, 2002/12/23 06:04PM by Ray
*/

winParent = window.parent;

var verHeading = new Object();
verHeading["000"] = "CBETA�q�l��";
verHeading["010"] = "�j���s��j�øg";
verHeading["020"] = "�����]�n������á^(The 'Sung Edition' A. D. 1239)";
verHeading["030"] = "�����]���j����x�á^(The 'Yuan Edition' A. D. 1290)";
verHeading["040"] = "�����]����U�á^(The 'Ming Edition' A. D. 1601)";
verHeading["050"] =  "�R���]���R���L�x���^(The 'Kao-Li Edition' A. D. 1151)";
verHeading["051"] =  "�R���O�� (Another print of the Kao-Li Edition)";
verHeading["060"] =  "���|�t�y�å��]�ѥ��g�g�^(The Tempyoo Mss. [A. D. 729-] and the Chinese Mss. of the Sui [A. D. 581-617] and Tang [A. D. 618-822] dynasities, belonging ot the Imperial Treasure House Shoosoo-in at Nara, specially called Shoogo-zoo)";
verHeading["061"] =  "���ܰ|�t�y�å��O�g (Another copy of the same)";
verHeading["070"] =  "�c���ٹϮѼd���]�§����^(The Old Sung Edition [A. D. 1104-1148] belonging to the Library of the Imperial Household)";
verHeading["080"] =  "�j�w�x��(The Tempyoo Mss. of the monastery 'Daitoku-ji')";
verHeading["090"] =  "�U�w�x��(The Tempyoo Mss. of the monastery 'Mantoku-ji')";
verHeading["100"] =  "�ۤs�x��(The Tempyoo Mss. of the monastery 'Ishiyama-dera')";
verHeading["110"] =  "�����|��(The Tempyoo Mss. of the monastery 'Chion-in')";
verHeading["120"] =  "���٦x��(The Tempyoo Mss. of the monastery 'Daigo-ji')"; 
verHeading["130"] =  "���M�x�å�(Ninnaji Mss. by Kuukai and others. C. 800. A. D.)";
verHeading["140"] =  "�F�j�x��(The Tempyoo Mss. of the monastery 'Toodai-ji')";
verHeading["150"] =  "����������å�(Mr. Nakamura's Mss. from Tun-huang)";
verHeading["160"] =  "�[���w��(The Tempyoo Mss. belonging to the Kuhara Library)";
verHeading["170"] =  "�˥вM�ӭ����å�(The Tempyoo Ms. owned by Mr. Seitaro Morita)";
verHeading["180"] =  "���ץ��]���ץX�g�øg�^(Stein Mss. from Tun-huang)";
verHeading["181"] =  "���ץ��]���ץX�g�øg�^(Stein Mss. from Tun-huang)";
verHeading["182"] =  "���ץ��]���ץX�g�øg�^(Stein Mss. from Tun-huang)";
verHeading["190"] =  "��֦x��(The Tempyoo Mss. of the monastery 'Saifuku-ji')";
verHeading["191"] =  "��֦x��(The Tempyoo Mss. of the monastery 'Saifuku-ji')";
verHeading["200"] =  "�F�ʫҫǳժ��]��(The Chinese Mss. of the Tang dynasty belonging to the Imperial Museum of Tokyo)";
verHeading["210"] =  "�Y�ꥻ�]�Y��j�øg�^Tokyo edition (small typed)";
verHeading["220"] =  "�����å�(The Mss. preserved in the Kongoo-zoo Library, Tooji, Kyoto)" 
verHeading["230"] =  "��������(The Edition of Kooya-san, C. 1250 A. D.)" 

var currentVer="000";
var anchorFlag=true;

function selectDiBen(x) {
	selectVer(x);
	var jk_ver=document.getElementById('jk_ver');
	jk_ver.value=x; // ����

	// ��ܨ����հ�
	if (x=="000" || x=="010") { // cbeta�� �� �j���ê�
		showFoot();
	}

	// ���ݭn���հ��ഫ
	var obj = document.getElementById('vv');
	if (x=="000" && obj.value=="010") {
		obj.value=x;
		return;
	}
	if (x=="010" && obj.value=="000") {
		obj.value=x;
		return;
	}
	selectVer(obj.value);
}

function selectVer(x) {
	window.status="����������...";
	docText = winParent.frames.text.document;

	var jk_ver=document.getElementById('jk_ver');
	
	var vers=docText.getElementById('vers');
	vers.childNodes[0].nodeValue=verHeading[x];
	var col=docText.getElementsByTagName('SPAN');
	var s1, s2;
	for (i=0; i<col.length; i++) {
		nt=col[i];
		var id=nt.id;
		var att_mod=nt.getAttribute('mod');
		if (id.substr(0,1)=="n" || id.substr(0,1)=="c") {
			var ver=nt.getAttribute('ver');
			if (typeof(ver)!='undefined' && ver!=null){
				s1 = nt.innerHTML;
				s1=s1.replace(/^((\[<a.*?a>\])?).*$/i, "$1");
				var searchResult;
				eval('searchResult=ver.search(/' + x + '/);');
				if (searchResult>-1) {
					s=nt.getAttribute('v'+x);
					s=transAtt(s);
					s=s.replace(/&SD(.*?);/g, "<font face='siddam'>$1</font>");
					nt.innerHTML=s1+s;
					if (x=="000" || x=="010") { // cbeta�� �� �j���ê�
						if (nt.getAttribute('v000')!=nt.getAttribute('v010')) {
							nt.style.color = "red";
						}
					} else {
						nt.style.color = "";
					}
				} else if (jk_ver.value=="000") {
					s = nt.getAttribute('v000');
					s=transAtt(s);
					nt.innerHTML = s1 + s;
				} else {
					s = nt.getAttribute('v010');
					s=transAtt(s);
					nt.innerHTML = s1 + s;
				}
			}
		}
	}
	currentVer=x;
	
	// �M���հ���
	docJK = winParent.frames.jk.document;
	docJK.open();
	docJK.clear();
	docJK.close();
	window.status="����";
}

function switchAnchor() {
	var o=document.getElementById('show2');
	if (anchorFlag) {
		hideAnchor();
		o.value='��ܮհɲŸ�';
	} else {
		showAnchor();
		o.value='���îհɲŸ�';
	}
	anchorFlag = !anchorFlag;
}

function hideAnchor() {
	docText = winParent.frames.text.document;
	var col=docText.getElementsByTagName('span');
	for (i=0; i<col.length; i++) {
		nt=col[i];
		id=nt.id;
		if (id.substr(0,1)=="n") {
			var s="";
			var wit=nt.getAttribute('ver');
			if (wit != null) {
				if (wit.indexOf(currentVer)>-1){
					s=nt.getAttribute('v'+currentVer);
				} else {
					s=nt.getAttribute('v000');
				}
			}
			s=transAtt(s);
			nt.innerHTML=s;
		}
	}
}

function showAnchor() {
	docText = winParent.frames.text.document;
	var col=docText.getElementsByTagName('span');
	var s;
	var n;
	var html;
	for (i=0; i<col.length; i++) {
		nt=col[i];
		id=nt.id;
		if (id.substr(0,1)=="n") {
			s=id.substr(1);
			html="[<a id=\"a" + s + "\" href=\"\" onClick=\"return aOnClick('" + s + "')\"";
			html+=" onfocus='abc(\"n" + s + "\",sr)' onblur='abc(\"n" + s + "\",xr)'";
			html+=">";
			n=id.substr(6);
			n=n.replace(/^0*(.*)$/, "$1");
			if (n=="") {
				n="0";
			}
			html += n + "</a>]";
			var wit=nt.getAttribute('ver');
			if (wit!=null) {
				if (wit.indexOf(currentVer)>-1){
					html+=nt.getAttribute('v'+currentVer);
				} else {
					html+=nt.getAttribute('v000');
				}
			}
			html=transAtt(html);
			nt.innerHTML = html;
		}
	}
}

function transAtt(s) {
	s=s.replace(/FigT00(\w{4})/g, "<img src='../sd-gif/SD-$1.gif'>");
	s=s.replace(/FigT(\d{8})/g, "<img src='../figures/$1.gif'>");						
	return s;
}