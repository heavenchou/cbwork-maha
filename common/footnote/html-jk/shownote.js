/*
	shownote.js
	Copyright (C) 2003 Ray Chou (ray.chou@url.com.tw)

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.
	
	v0.1, 2002/11/27 06:28PM by Ray
	v0.2, �w�� Netscape 7.0, Mozilla 1.2 �ק�, 2002/11/30 03:44PM by Ray
	v0.3, ��g�r���e�{, 2002/12/11 11:34AM by Ray
	v0.4, �@���հɨ�ӬY��, 2002/12/16 05:06PM by Ray
	v0.5, �i�ϡj�i�Сj, 2002/12/16 06:05PM by Ray
	v0.6, �Y���A�Y����, 2002/12/20 02:52PM by Ray
	v0.7, �x��r�H TTF �e�{, 2002/12/20 06:07PM by Ray
	v0.8, 2002/12/23 04:11PM by Ray
	v0.9, 2003/1/2 11:14AM by Ray
*/

var verName = new Object();
verName["000"] = "CBETA"  ;
verName["010"] = "�j"     ; 
verName["020"] = "��"     ; 
verName["030"] = "��"     ; 
verName["040"] = "��"     ;
verName["041"] = "����"   ;
verName["050"] = "�R"     ;
verName["051"] = "�R�A"   ;
verName["060"] = "�t"     ;
verName["061"] = "�t�A"   ;
verName["062"] = "�t��"   ;
verName["070"] = "�c"     ;
verName["071"] = "�c�A"   ;
verName["080"] = "�w"     ;
verName["090"] = "�E"     ;
verName["100"] = "��"     ;
verName["110"] = "��"     ;
verName["120"] = "��"     ;
verName["130"] = "�M"     ;
verName["140"] = "�F"     ;
verName["150"] = "��"     ;
verName["160"] = "�["     ;
verName["170"] = "��"     ;
verName["180"] = "��"     ;
verName["181"] = "���A"   ;
verName["182"] = "����"   ;
verName["183"] = "����"   ;
verName["190"] = "��"     ;
verName["191"] = "�֤A"   ;
verName["200"] = "��"     ;
verName["210"] = "�Y"     ;
verName["220"] = "��"     ;
verName["230"] = "��"     ;
verName["240"] = "��"     ;
verName["250"] = "��"     ;
verName["251"] = "�A"     ;
verName["252"] = "��"     ;
verName["253"] = "�B"     ;
verName["254"] = "��"     ;
verName["255"] = "�v"     ;
verName["a04"] = "��"     ;
verName["a06"] = "��"     ;
verName["a07"] = "�O"     ;
verName["a09"] = "�n"     ;
verName["b00"] = "��"     ;
verName["b01"] = "��"     ;
verName["b03"] = "�j��"   ;
verName["b04"] = "���"   ;
verName["b05"] = "�_��"   ;
verName["b09"] = "�n��"   ;
verName["b10"] = "�y����" ;
verName["b11"] = "�Y��"   ;
verName["b12"] = "�Y����" ;
verName["b13"] = "�ਦ"   ;
verName["zzz"] = "����"   ;


function aOnClick (n) {
	var temp;
	var fn="f"+n;
	
	var winParent = window.parent;
	var docFoot = winParent.frames.foot.document;
	var docJK = winParent.frames.jk.document;
	var docTool = winParent.frames.tool.document;
	
	var nt=docFoot.getElementById(fn);
	if (nt == null) {
		window.status="Error in shownote.js Line 90: Footnote object not found!";
		return false;
	}
	nt.scrollIntoView();
	nt.focus();

	n="n"+n;
	nt=document.getElementById(n);

	docJK.open("text/html; charset=big5", "replace")
	docJK.write("�i�涵�հɡj<br>");

	var pb=n.substr(1,4);
	pb=pb.replace(/^0*/g, "");
	var strPage="p. "+pb;

	var jk=n.substr(5);
	jk=jk.replace(/^0*(.*)$/, "$1");
	if (jk=='') {
		jk="0";
	}
	strPage+=", [" + jk + "] ";

	var docTool = winParent.frames.tool.document;
	temp=docTool.getElementById('jk_ver');
	var jk_ver = temp.value;
	
	s="";
	if (jk_ver == "000") {
		s=nt.getAttribute('mod');
		if (s!=null) {
			//s=s.replace(/&SD(.*?);/g, "<font face='siddam'>$1</font>");
			s=dia(s);
			s=s.replace(/FigT00(\w{4})/g, "<img src='../sd-gif/SD-$1.gif'>");
			s=s.replace(/FigT(\d{8})/g, "<img src='../figures/$1.gif'>");
			s=s.replace(/\{\{(.*?)\}\}/g, "<font color='red'>$1</font>");
		}
	}
	if (s=="" || s==null) {
		s = nt.getAttribute('orig');
		//s=s.replace(/&SD(.*?);/g, "<font face='siddam'>$1</font>");
		s=dia(s);
		s=s.replace(/FigT00(\w{4})/g, "<img src='../sd-gif/SD-$1.gif'>");
		s=s.replace(/FigT(\d{8})/g, "<img src='../figures/$1.gif'>");
	}

	if (s!='') {
		docJK.write(strPage);
		docJK.write(s);
	}
	
	var ver=nt.getAttribute('ver');
	if (ver!=null && s!=''){
		var tb=nt.getAttribute('table');
		if ((tb==null) || (tb!="0")) {
			docJK.write("<table border=1 cellpadding=5 cellspacing=0>");
			//docJK.write('<tr><th colspan="2">�����Φr</th>');
			var tempArray=ver.split(" ");
			tempArray=tempArray.sort();
			for (i=0;i<tempArray.length;i++){
				va=tempArray[i];
				if (va=='') {
					continue;
				}
				docJK.write("<TR><TD class=menulines>");
				s=nt.getAttribute("v"+va);
				s=s.replace(/FigT00(\w{4})/g, "<img src='../sd-gif/SD-$1.gif'>");
				s=s.replace(/FigT(\d{8})/g, "<img src='../figures/$1.gif'>");
				//s=s.replace(/&SD(.*?);/g, "<font face='siddam'>$1</font>");
				// <td> �S�����e���ɭ�, �ؽu�]�|����, �ҥH��@�ӥ��Ϊť�
				if (s=='') {
					s="�@";
				}
				if (verName[va]!="�Y��" && verName[va]!="�Y����" && va!="zzz") {
					docJK.write("�i");
				}
				docJK.write(verName[va]);
				if (verName[va]!="�Y��" && verName[va]!="�Y����" && va!="zzz") {
					docJK.write("�j");
				}
				docJK.write("<td>" + s + "</TD></TR>");
			}
			docJK.write("</table>");
		}
	}
	
	docJK.close();

	return false;
}


function abc(n,state){
	var nt=document.getElementById(n);
	nt.style.backgroundColor=state;
}