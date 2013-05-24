/*
cbeta.ent 的 encoding 必須是 UTF8
使用方法:
	go T01
	go
*/
import java.awt.Color;
import java.io.*;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.Iterator;

public class go {
	static String xml_root = "/release/utf8-xml";
	static String out_root = "/release/pdf";
	public static void main(String[] args) {
		if (args.length>0) {
			String s = args[0];
			if (s.equalsIgnoreCase("T")) {
				do_all_t();
			} else if (s.equalsIgnoreCase("X")) {
				do_all_x();
			} else {
				do1vol(s);
			}
		} else {
			do_all_t();
			do_all_x();
		}
	}
	
	static void do_all_t () {
		for(int i=1; i<=85; i++) {
			String vol = new PrintfFormat("%2.2d").sprintf(i) ;
			vol = "T" + vol;
			do1vol(vol);
		}
	}
	
	static void do_all_x () {
		for(int i=63; i<=88; i++) {
			String vol = new PrintfFormat("%2.2d").sprintf(i) ;
			vol = "X" + vol;
			do1vol(vol);
		}
	}

	static void do1vol(String vol) {
		vol = vol.toUpperCase();
		File f = new File(xml_root + "/" + vol);
		if (!f.exists()) {
			return;
		}
		System.out.print(vol+"\n");
		String[] allfiles = f.list();
		f = new File(out_root + "/" + vol);
		f.mkdirs();
		for(int j=0; j<allfiles.length; j++) {
			String s = allfiles[j];
			if (s.endsWith(".xml")) {
				String o = s.substring(0,s.length()-4) + ".pdf";
				s = xml_root + "/" + vol + "/" + s;
				o = out_root + "/" + vol + "/" + o;
				try {
					xml2pdf my_xml2pdf = new xml2pdf();
					my_xml2pdf.go(s, o);
				} catch (Exception e) {
					e.printStackTrace();
					System.exit(1);
				}
			}
		}
	}
}