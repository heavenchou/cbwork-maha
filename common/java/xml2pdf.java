/*
Encoding: UTF8
Requirement:
	JDOM
	iText -- a Free Java-PDF Library, http://www.lowagie.com/iText/
執行前要將 cbeta.ent 存成 UTF8

Created by Ray B. X. Zhou

Log:
	2005/7/30 18:49 by Ray
		<note place="interlinear"> 比照 <note place="inline">
	2005/3/28 09:49 by Ray
		rend="no_nor" 不使用通用字
		處理不在 <p> 裏面的 <note place="inline"> 包多個 <p>, T21n1299p0388a16
		<note place="inline"> 包 <list>, T50n2054, p. 286b20
		<juan> 不換頁, <milestone> 換頁就好, 不然 T85n2827 第一頁會空白
	2005/3/27 12:30 by Ray
		<foreign place="foot"> 不顯示
		處理 <lg> 包 <note place="inline"> T16n0657, p. 206b27
	2005/3/26 by Ray
		figures 改用 gif
	2004/9/27
		顯示悉曇字
		j2sdk1.4.2_05
		cbeta@ccbs.ntu.edu.tw => service@cbeta.org
	2002/11/7 02:15PM by Ray
		<item> 的 n 屬性也要印
	2002/10/3 05:46PM by Ray
*/

import java.awt.Color;
import java.io.*; 
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.List;
import java.util.Map;
import java.util.Iterator;
import java.util.Date;
import java.text.DateFormat;
import java.lang.Character;
import java.lang.Number;

import org.jdom.*; 
import org.jdom.input.*; 
import org.jdom.output.*; 
import org.jdom.ProcessingInstruction;

import com.lowagie.text.*;
import com.lowagie.text.DocumentException;
import com.lowagie.text.pdf.BaseFont;
import com.lowagie.text.pdf.PdfAction;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.PdfDestination;
import com.lowagie.text.pdf.PdfOutline;
import com.lowagie.text.pdf.PdfPageEventHelper;
import com.lowagie.text.pdf.PdfWriter;
import com.lowagie.text.html.HtmlWriter;
import com.lowagie.text.xml.*;

public class xml2pdf {
	//String cb_png_root = "\\2004\\cbeta\\queizi\\gaiji-CB-png";
	//String cb_png_root = "\\edith\\java\\gaiji-cb-png";
	String cb_png_root = ".\\gaiji-cb-png";

	//String mojikyo_root = "d:\\mydocs\\cbeta\\cd\\cd10\\hh-work\\mojikyo-png";
	//String sd_png_root = "d:\\mydocs\\cbeta\\cd\\cd10\\hh-work\\sd-png";

	//String figure_root = "\\2004\\cbeta\\figures-png";
	//String figure_root = "\\edith\\java\\figures-png";
	String figure_root = ".\\figures";

	//edith modify 2004/12/30 記錄:發行日期
	//String today=(new java.util.Date()).toString(); 
	Date myDate=new java.util.Date();	//取得今天的日期與時間
	String today = DateFormat.getDateInstance().format(myDate); //調整日期格式→2005/1/4
	//edith modify 2005/1/27
	int des_i=0;
	String[] des_array = new String[99999];
		
	int level =0;	
	String my_label = null;
	
	boolean debug=false;
	boolean debug2=false;
	File log_file;
	PrintWriter log_writer;
	BaseFont my_base_font;
	BaseFont my_xitan_base_font;
	Font my_font_footer;
	Font my_font_body;
	Font my_font_byline;
	Font my_font_xitan;
	public xml2pdf() throws DocumentException, IOException {
		try {
			log_file = new File(".", "log.txt");
			log_writer = new PrintWriter(new FileWriter(log_file));			
		} catch(IOException e) {
			//System.out.println("78|IO Exception e{" + e.toString() +"}\n");
		}
		my_base_font = BaseFont.createFont("c:\\windows\\fonts\\ARIALUNI.TTF", BaseFont.IDENTITY_H, BaseFont.EMBEDDED);
		//my_xitan_base_font = BaseFont.createFont("c:\\windows\\fonts\\SiddamU2.TTF", BaseFont.IDENTITY_H, BaseFont.EMBEDDED);
		my_xitan_base_font = BaseFont.createFont("\\ray\\2005\\CBETA\\QueiZi\\SiddamU2.TTF", BaseFont.IDENTITY_H, BaseFont.EMBEDDED);
		my_font_footer = new Font(my_base_font, 12);
		my_font_body = new Font(my_base_font, 14, Font.NORMAL); 
		my_font_byline = new Font(my_base_font, 14, Font.NORMAL, new Color(153, 51, 0));
		my_font_xitan = new Font(my_xitan_base_font, 14, Font.NORMAL);
		my_chunk = new Chunk("", my_font_body);
	}

	com.lowagie.text.Document my_pdf_doc;
	PdfContentByte my_pdf_cb;
	PdfOutline my_pdf_outline_root;
	org.jdom.Element my_tei_header;
	Chunk my_chunk;
	Phrase my_phrase;
	Paragraph MyParagraph;
	String MyTextBuffer="";
	int my_pass=1;
	PdfOutline my_outline_mulu[]=new PdfOutline[50];  // <mulu> 的 level 最深可以到 50
	boolean my_mulu = false;
	boolean my_write_mulu = false;
	boolean my_dirty_flag;
	boolean my_nor = true; // 是否用通用字
	boolean note_inline = false;

	// modified by Ray 2005/3/25 09:40下午, 因為 <p type="pre"> 也要強迫換行
	//boolean in_lg = false;
	boolean lb_newline = false;
	
	boolean first_cell_in_row=false;
	int cols_of_table;
	int row_in_table;
	int in_table=0;
	
	public void go(String xml, String pdf) {
		try {
			System.out.print(xml + "=>" + pdf);
			SAXBuilder my_sax = new SAXBuilder();
			//my_sax.setExpandEntities(false);
			org.jdom.Document d = my_sax.build(new File(xml)); 
			my_pdf_doc = new com.lowagie.text.Document();
			PdfWriter writer = PdfWriter.getInstance(my_pdf_doc, new FileOutputStream(pdf));
			writer.setPageEvent(new my_page_event_helper());
			my_phrase=new Phrase("P. ", my_font_footer);
			HeaderFooter my_footer = new HeaderFooter(my_phrase, true);
			my_phrase=null;
			my_footer.setAlignment(com.lowagie.text.Element.ALIGN_RIGHT);
			my_pdf_doc.setFooter(my_footer);
			my_pdf_doc.open();
			
			// 左邊目錄
			my_pdf_cb = writer.getDirectContent();
			my_pdf_outline_root = my_pdf_cb.getRootOutline(); 
			org.jdom.Element r = d.getRootElement();
			my_tei_header = r.getChild("teiHeader");

			org.jdom.Element my_body = r.getChild("text");
			org.jdom.Element my_text = my_body.getChild("body");
			List my_div1s = my_text.getChildren("div1");
			PdfAction my_empty_action = new PdfAction("");
			if (my_div1s.size()>1) {
				my_outline_mulu[0] = my_pdf_outline_root;
				my_mulu=true;
			}

			my_process_element(r, my_pdf_doc);
			System.out.print("\n");
		} catch (Exception e) {
			System.out.println("<lb n=" + my_lb + ">");
			System.out.println("Exception e{" + e.toString() +"}\n");
			e.printStackTrace();
			System.exit(1);
		} finally {
			my_pdf_doc.close();
			log_writer.close();
		}
	}
		
	void my_process_element(org.jdom.Element el, Object parent_container) throws DocumentException {
		boolean my_nor_save = my_nor;
		String my_element_name=el.getName();
		//edith modify 2004/12/31
		if (my_element_name.equalsIgnoreCase("gloss") || my_element_name.equalsIgnoreCase("rdg")) {
			return;
		}

		String attr_rend = el.getAttributeValue("rend");
		if (attr_rend!=null && attr_rend.equalsIgnoreCase("no_nor")) {
			my_nor = false; // 不用通用字
		}
		
		//edith modify 2004/12/31
		if (my_element_name.equalsIgnoreCase("note")) {
			String type = el.getAttributeValue("type");
			String note_place = el.getAttributeValue("place");
			String note_resp = el.getAttributeValue("resp");
			if (type!=null) 
			{
				/*edith add 2005/3/23 <note n="xxx" resp="xxx" type="rest"> 裡的文字不顯示
				<note n="0648006" resp="CBETA" type="rest">中阿含經大品第一竟九字在卷末題前行【明】【聖】</note>
				<note n="0666015" resp="CBETA" type="rest">（中阿…竟）十字在谷末題前行【宋】【元】【聖】</note> 
				*/
				if (type.equalsIgnoreCase("orig") || type.equalsIgnoreCase("mod") || type.equalsIgnoreCase("rest")) 
				{
					return;
				}				
				
			}
			//edith modify 2005/1/4 <note place="foot text"> 不顯示, 例如
			//<note n="0002013" resp="Taisho" type="orig" place="foot">			
			if (note_place!=null) 
			{
				if (note_place.equalsIgnoreCase("foot")) 
				{
					return;
				}
			}
			
			//edith modify 2005/3/23 <note resp="CBETA.Eva"> CBETA開頭的值都不顯示, 例如 T19n1026.xml
			//<lb n="0727a14"/><note resp="CBETA.Eva">為配合悉漢對照，故將p727a14中文與p727a15悉曇字前後對調</note>		
			if (note_resp!=null) 
			{
				if (note_resp.indexOf("CBETA") !=-1) //字串裡符合 "CBETA" 字串
				{
					return;
				}
			}
		}
		
		//edith modify 2005/1/4 <t place="foot">不顯示, 例如
		//<t lang="san" resp="Taisho" place="foot">D&imacron;rgha-&amacron;gama</t>
		if (my_element_name.equalsIgnoreCase("t")) {
			String t_place = el.getAttributeValue("place");
			if (t_place!=null) 
			{
				if (t_place.equalsIgnoreCase("foot")) 
				{
					//if (debug2) {System.out.println("174<t place=" +t_place+"> return\n");}
					return;
				}
			}
		}

		/*edith add 2005/3/22 
		T01n0026.xml <foreign n="xxx" lang="pli" resp="xxx" place="foot">時不顯示裡面的巴利文
		T19n0999.xml <foreign n="xxx" lang="san" resp="xxx" place="foot">時不顯示裡面的悉曇字 
		*/
		if (my_element_name.equalsIgnoreCase("foreign")) {
			String foreign_place = el.getAttributeValue("place");
			String foreign_lang = el.getAttributeValue("lang");
			/*
			if (foreign_place!=null && foreign_lang!=null && foreign_place.equalsIgnoreCase("foot") ) 
			{
				if (foreign_lang.equalsIgnoreCase("pli") || foreign_lang.equalsIgnoreCase("san")) 
				{
					return;
				}
			}
			*/
			if (foreign_place!=null && foreign_place.equalsIgnoreCase("foot") ) {
				return;
			}
		}
		
		Object cur_container = null;
		Object new_container = my_start_element(el, parent_container);
		if (new_container==null) {
			cur_container=parent_container;
		} else {
			cur_container=new_container;
		}
		List my_mixed_content = el.getContent();
		Iterator i = my_mixed_content.iterator();
		while (i.hasNext()) {
			Object o = i.next();
			if (o instanceof org.jdom.Element) {
				my_process_element((org.jdom.Element)o, cur_container);
			} else if (o instanceof EntityRef) {
				
			} else if (o instanceof Text) {
				String my_text = ((org.jdom.Text) o).getTextTrim();
				//my_process_text((org.jdom.Text) o, cur_container);
				my_process_text(my_text, cur_container);
				//if (debug2) {System.out.println("202 hasNext():my_process_text{" + o.toString() + "}\n");	}
			}
		}
		my_end_element(el, cur_container);
		
		if (new_container!=null && parent_container!=null) {
			// Cell
			if (parent_container instanceof Cell) {
				com.lowagie.text.Element my_ele = (com.lowagie.text.Element) new_container;
				((Cell) parent_container).addElement(my_ele);
			// Document
			} else if (parent_container instanceof com.lowagie.text.Document) {
				if (new_container instanceof Paragraph) {
					((com.lowagie.text.Document) parent_container).add((Paragraph) new_container);
				} else if (new_container instanceof Table) {
					((com.lowagie.text.Document) parent_container).add((Table) new_container);
				}
			// Paragraph
			} else if (parent_container instanceof Paragraph) {
				if (new_container instanceof Phrase) {
					((Paragraph) parent_container).add((Phrase) new_container);
				} else if (new_container instanceof Table) {
					((Paragraph) parent_container).add((Table) new_container);
				}
			// Phrase
			} else if (parent_container instanceof Phrase) {
				((Phrase) parent_container).add(new_container);
			// Table
			} else if (parent_container instanceof Table) {
				if (new_container instanceof Cell) {
					if (first_cell_in_row) {						
						((Table) parent_container).addCell((Cell) new_container,row_in_table,0);
						first_cell_in_row=false;
					} else {
						((Table) parent_container).addCell((Cell) new_container);
					}
				}
			}

			new_container=null;
		}
		cur_container=null;
		new_container=null;
		my_nor = my_nor_save;
	}

	//void my_process_text(org.jdom.Text t, Object cur_container) {
	void my_process_text(String my_text, Object cur_container) {
		//String my_text = t.getTextTrim();		
		if (my_pass==0) {
			my_text = MyTextBuffer + my_text;
			if (!my_text.equalsIgnoreCase("")) {
				MyTextBuffer = "";
				Font f=null;
				if (cur_container instanceof Cell) {
					f = my_font_body;
				}
				my_add_chunk(my_text, f, cur_container);
				my_chunk=null;
				my_dirty_flag = true;
			}
			if (debug2) {System.out.println("261 my_text{" + my_text + "}   my_pass{" + my_pass + "}");}
		} else {
			MyTextBuffer += my_text;
		}
	}
	
	String my_lb;	
	Object my_start_element (org.jdom.Element el, Object parent_container) throws DocumentException {
		Object new_container=null;
		String my_element_name=el.getName();
		//log_writer.println("<"+my_element_name+">");

		Object p = el.getParent();
		org.jdom.Element my_parent;
		String my_parent_name=null;
		//if (p != null) {
		if (p instanceof org.jdom.Element) {
			my_parent = (org.jdom.Element) p;
			my_parent_name=my_parent.getName();
		}

		// <bibl>
		if (my_element_name.equalsIgnoreCase("bibl")) {
			if (my_parent_name.equalsIgnoreCase("sourceDesc")) {
				Phrase my_phrase = new Phrase("", my_font_footer);
				Paragraph my_para = new Paragraph(my_phrase);
				my_para.setIndentationLeft(100);
				new_container = my_para;
				MyTextBuffer = "";
			}
		}

		// <body>
		if (my_element_name.equalsIgnoreCase("body")) {
			my_pass=0;
			MyTextBuffer = "";
		}

		// <byline>
		if (my_element_name.equalsIgnoreCase("byline") && my_pass==0) {
			Paragraph my_para = new Paragraph("", my_font_byline);
			my_para.setIndentationLeft(48);
			new_container = my_para;
		}

		// <cell>
		if (my_element_name.equalsIgnoreCase("cell") && my_pass==0) {
			Phrase my_phrase = new Phrase("", my_font_body);
			Cell my_cell = new Cell(my_phrase);
			
			String s=el.getAttributeValue("rows");
			if (s!=null) {
				int i=Integer.parseInt(s);
				my_cell.setRowspan(i);
			}

			s=el.getAttributeValue("cols");
			if (s!=null) {
				int i=Integer.parseInt(s);
				my_cell.setColspan(i);
			} else {
				s="1";
			}

			if (debug2) {
				System.out.println("366|<cell cols=" + s + ">");
			}				

			//log_writer.println("New Phrase:" + Integer.toString(my_phrase.hashCode()));
			new_container=my_cell;
		}
		
		// <corr>
		if (my_element_name.equalsIgnoreCase("corr")) {
			Font my_font = new Font(my_base_font);
			my_font.setColor(255, 0, 0);
			Phrase my_phrase = new Phrase("", my_font);
			new_container=my_phrase;
		}

		// <date>
		if (my_element_name.equalsIgnoreCase("date")) {
			if (my_parent_name.equalsIgnoreCase("publicationStmt")) {
				Phrase my_phrase = new Phrase("", my_font_footer);
				Paragraph my_para = new Paragraph(my_phrase);
				my_para.setIndentationLeft(100);
				new_container = my_para;
				MyTextBuffer = "";
			}
		}

		// <edition>
		if (my_element_name.equalsIgnoreCase("edition")) {
			if (el.isAncestor(my_tei_header)) {
				Phrase my_phrase = new Phrase("", my_font_footer);
				Paragraph my_para = new Paragraph(my_phrase);
				my_para.setIndentationLeft(100);
				MyTextBuffer = "";
				new_container = my_para;
			}
		}
		
		// <entry> edith add 2005/3/22 X63n1252.xml、X63n1256.xml 漏掉辭典條目文字, 也是因為之前沒考慮到 <entry>、<form>
		if (my_element_name.equalsIgnoreCase("entry")) {			
			String entry_rend = el.getAttributeValue("rend");
			Font my_font = new Font(my_base_font, 12, Font.NORMAL);
			Phrase my_phrase = new Phrase("　", my_font);
			Paragraph my_para = new Paragraph(my_phrase);
			new_container = my_para;					
		}
		
		// <figure>
		if (my_element_name.equalsIgnoreCase("figure")) {
			// image 外用 table 包起來才能定位, 不然 PDF 會視圖形大小調整圖形位置
			Table my_table = new Table(1);
			my_table.setBorderWidth(0);
			my_table.setDefaultCellBorderWidth(0) ;
			String s=el.getAttributeValue("entity");
			
			// 2005/3/26 03:26下午 by Ray
			//String dir = figure_root + "\\" + s.substring(3) + ".png";
			String dir = figure_root + "\\" + s.substring(3,4) + "\\" + s.substring(3) + ".gif";
			System.out.print(" " + s.substring(3) + ".gif");
			try {
				Image my_img = Image.getInstance(dir);
				//my_img.scalePercent(50);
				//my_img.scaleToFit(640, 480);
				Cell my_cell = new Cell(my_img);
				my_table.addCell(my_cell);
				//System.out.println("388|<figure>|<lb n=" + my_lb + ">");
				if (parent_container instanceof Paragraph) {
					((Paragraph) parent_container).add(my_table);
					//System.out.println("391|<figure>" + dir);
				} else if (parent_container instanceof Phrase) {
					((Phrase) parent_container).add(my_table);
					//System.out.println("394|<figure>" + dir);
				} else {					
					//edith modfiy 2005/2/3 X86n1600.xml 底下的圖沒有包在<p>裡面
					//<lb ed="X" n="0172a01"/><figure entity="FigX86017201"/>
					//System.out.println("\n315|"+dir);
					//System.exit(1);
					Font my_font = new Font(my_base_font, 14, Font.NORMAL);					
					Phrase my_phrase = new Phrase("　　", my_font);
					Paragraph my_para = new Paragraph(my_phrase);
					new_container = my_para;
					((Paragraph) new_container).add(my_table);
					System.out.println("405|<figure>" + dir);
				}
			} catch(IOException ioe) {
				System.err.println("308 " + ioe.getMessage());
				System.exit(1);
			}
			//System.out.println("411|<figure>" + dir);
		}
		
		// <form> edith add 2005/3/22 X63n1252.xml、X63n1256.xml 漏掉辭典條目文字, 也是因為之前沒考慮到 <entry>、<form>
		if (my_element_name.equalsIgnoreCase("form")) {			
			Font my_font = new Font(my_base_font, 12, Font.BOLD); //變粗體
			Phrase my_phrase = new Phrase("", my_font);
			new_container = my_phrase;
		}
		
		// <gaiji>
		if (my_element_name.equalsIgnoreCase("gaiji")) {
			String t = my_start_gaiji(el, parent_container);
			my_process_text(t, parent_container);
			String cb=el.getAttributeValue("cb");	
			String s = search_array(cb);
			if (s==null) {
				put_cb_in_array(cb, t);
			}
			mulu_gaiji();
		}
		
		// <gloss>
		if (my_element_name.equalsIgnoreCase("gloss")) {
			my_pass++;
		}
			
		// <head>
		if (my_element_name.equalsIgnoreCase("head")) {
			String head_type = el.getAttributeValue("type");
			if (head_type!=null && head_type.equalsIgnoreCase("added")) {
				my_pass++;
			} else if (in_table>0) {
				new_row();
				Phrase my_phrase = new Phrase("", my_font_body);
				Cell my_cell = new Cell(my_phrase);
				my_cell.setColspan(cols_of_table);
				new_container=my_cell;
			} else {
				Font my_font = new Font(my_base_font, 16, Font.BOLD, new Color(0, 0, 255));
				Phrase my_phrase = new Phrase("", my_font);
				Paragraph my_para = new Paragraph(my_phrase);
				my_para.setLeading(24);
				my_para.setIndentationLeft(24);
				new_container = my_para;
			}
		}

		// <item>
		if (my_element_name.equalsIgnoreCase("item")) {
			String n = el.getAttributeValue("n");
			if (n==null) {
				n="";
			}
			int size = 14;
			if (note_inline) {
				size = 12;
			}
			Font my_font = new Font(my_base_font, size, Font.NORMAL, new Color(0, 0, 0));
			Phrase my_phrase = new Phrase(n, my_font);
			Paragraph my_para = new Paragraph(my_phrase);
			new_container = my_para;
		}

		// <jhead>
		if (my_element_name.equalsIgnoreCase("jhead")) {
			Font my_font = new Font(my_base_font, 14, Font.BOLD, new Color(51, 153, 102));
			Phrase my_phrase=new Phrase("",my_font);
			Paragraph my_para = new Paragraph(my_phrase);
			new_container = my_para;
		}

		// <juan>
		if (my_element_name.equalsIgnoreCase("juan")) {
			String fun=el.getAttributeValue("fun");
			if (fun!=null && fun.equalsIgnoreCase("open")) {
				String s = el.getAttributeValue("n");
				//edith modify: 2005/2/2 遇到 s="001a" 時, s1="001"
				//例如: T33n1708.xml <juan fun="open" n="001a">
				String s1="";
				for (int k=1,  j = s.length(); k <= j; k++)
				{
					//char ch = (char)k ;	
					//boolean _isdigit = Character.isDigit(ch);
					String s_tmp= s.substring(k-1,k) ;					
					 int bInt;
					try 
					{      
						bInt = Integer.parseInt(s_tmp);  
						s1 +=s_tmp;  //只取數字的部分
					} 
					catch (NumberFormatException e) 
					{      
						//System.out.println(s_tmp.toString() + "不是數字");    
					}				
				}
				//int i = Integer.parseInt(s);
				int i = Integer.parseInt(s1); //edith modify: 2005/2/2 遇到 s="001a" 時,  s1="001"
				
				s = Integer.toString(i);
				//System.out.print("679|<lb n=" + my_lb + ">");
				System.out.print(" " + s);
				//System.out.println("\n");
				
				// <juan> 不換頁, <milestone> 換頁就好, 不然 T85n2827 第一頁會空白
				//if (!s.equalsIgnoreCase("1") && my_dirty_flag) {					
				//	my_pdf_doc.newPage();
				//}
			}
			//System.out.println("693|<lb n=" + my_lb + ">");
			Font my_font = new Font(my_base_font, 16, Font.BOLD, new Color(51, 153, 102));
			Paragraph my_para = new Paragraph("", my_font);
			new_container = my_para;
		}

		// <l>
		if (my_element_name .equalsIgnoreCase("l")) {
			String s="　";
			if (MyTextBuffer.equalsIgnoreCase("(")) {
				s += MyTextBuffer;
				MyTextBuffer = "";
			}
			Chunk my_chunk = new Chunk(s);
			if (parent_container instanceof Paragraph) {
				((Paragraph) parent_container).add(my_chunk);
			} else {
				((Phrase) parent_container).add(my_chunk);
			}
		}

		// <lb>
		if (my_element_name.equalsIgnoreCase("lb")) {
			my_lb=el.getAttributeValue("n");
			/*
			T48n2025.xml:1120d08 <lb n="1120d08"/>領眾。懇請為眾告香。然後開堂<note place="inline">古法未預告香不許入室<note n="1120003" resp="Taisho" type="orig" place="foot text">圖揭上段</note></note></p></div3>
			*/
			if (my_lb.equalsIgnoreCase("0165a06")) {
				//debug=true;
				//debug2=true;
				//System.out.println("<lb n=" + my_lb + ">");
			}
			else
			{
				debug2=false;
			}
			
			//if (in_lg) {
			if (lb_newline) {
				//Paragraph my_para = new Paragraph("");
				//new_container = my_para;
				my_process_text("\n",parent_container); // 強迫換行
			} else {
				// added by Ray 2005/3/25 09:05下午
				String attr_ed = el.getAttributeValue("ed");
				if (attr_ed!=null && attr_ed.indexOf('C',0) != -1) {
					my_process_text("\n",parent_container); // 強迫換行
				}
			}
		}
				
		// <lg>
		if (my_element_name.equalsIgnoreCase("lg")) {
			Font my_font = new Font(my_base_font, 14, Font.NORMAL);
			Phrase my_phrase = new Phrase("", my_font);
			Paragraph my_para = new Paragraph(my_phrase);
			new_container = my_para;
			lb_newline = true;
		}
		
		// <milestone>
		if (my_element_name.equalsIgnoreCase("milestone")) {
			String unit=el.getAttributeValue("unit");
			if (unit.equalsIgnoreCase("juan")) {
				String s = el.getAttributeValue("n");
				//System.out.print(s+".");
				if (!s.equalsIgnoreCase("1") && my_dirty_flag) {
					my_pdf_doc.newPage();
				}
			}
		}

		// <mulu>
		if (my_element_name.equalsIgnoreCase("mulu")) {
			if (debug2) {System.out.println("683<mulu>\n");}
			if (my_mulu) {
				if (debug2) {System.out.println("686<mulu>\n");}
				String s = el.getAttributeValue("level");
				if (s!=null) {
					//System.out.print("<mulu level="+s+">");
					//int level = Integer.parseInt(s);
					level = Integer.parseInt(s);
					//String my_label = el.getAttributeValue("label");
					my_label = el.getAttributeValue("label");
					if (my_label==null) {
						my_label="";
					}
					//edith modify 2005/1/11 T01n0001.xml 在 label 取得 CB00145
					//<lb n="0066a09"/><mulu type="經" level="2" n="11" label="11 阿＆CB00145；夷經(一一)"/>
					String cb_tmp = null;
					if (debug2) {System.out.println("696|" + my_label +"\n");}
					if (debug2) {System.out.println("722<mulu label="+my_label+">\n");}
					//2005/1/11 edith modify
					my_write_mulu=false;		
					mulu_gaiji(); // 處理 mulu Labe 中的缺字
					if (my_label.indexOf("＆CB") ==-1) { // 如果 mulu label 裏沒有缺字了
						//System.out.println("800|" +my_lb+"\n<mulu level="+level+">\n");
						PdfDestination my_d = new PdfDestination(PdfDestination.FIT); 
						my_outline_mulu[level] = new PdfOutline(my_outline_mulu[level-1], my_d, my_label, false);
						my_pdf_cb.addOutline(my_outline_mulu[level]);
						my_write_mulu=true;
					}
					//否則就留到parse <gaiji> 再加到左邊目錄,因為有些CB仍沒被取代, 例如T01n0001.xml
					//<lb n="0102c24"/><div2 type="jing"><mulu type="經" level="2" n="6" label="6 ＆CB02031；形梵志經(一六)"/><head>（二五）<title><note n="0102022" resp="Taisho" type="orig" place="foot text">佛說長阿含＋（經）【宋】【元】，〔佛說長阿含〕－【明】</note><app n="0102022"><lem>佛說長阿含</lem><rdg wit="【宋】【元】" resp="Taisho">佛說長阿含經</rdg><rdg wit="【明】" resp="Taisho">&lac;</rdg></app></title>第三分<note n="0102023" resp="Taisho" type="orig" place="foot text">～D. 8. Kassapa-s&imacron;han&amacron;da-sutta.</note><note n="0102023" place="foot" type="equivalent">～D. 8. Kassapa-s&imacron;han&amacron;da-sutta.</note>&CB02031;形梵志經第六</head>
				}
			}
		}

		// start note
		// <note>
		if (my_element_name.equalsIgnoreCase("note") && my_pass==0) {
			String place = el.getAttributeValue("place");
			if (place!=null) {
				if (place.equalsIgnoreCase("inline") || place.equalsIgnoreCase("interlinear")) {
					//System.out.println("822|<note><lb n=" + my_lb + ">");
					Font my_font = new Font(my_base_font, 12, Font.NORMAL);
					if (my_parent_name.matches("^(p|l|cell)$")) {
						//Phrase my_phrase = new Phrase("(", my_font);
						Phrase my_phrase = new Phrase("", my_font);
						new_container = my_phrase;
					} else {
						Phrase my_phrase = new Phrase("", my_font);
						Paragraph my_para = new Paragraph(my_phrase);
						new_container = my_para;
					}
					MyTextBuffer += "(";
					note_inline = true;
				}
			}
		}

		
		// <p>
		if (my_element_name.equalsIgnoreCase("p")) 
		{
			//if (el.isAncestor(my_tei_header)) 
			//{
				String lang = el.getAttributeValue("lang");
				if ((my_parent_name.equalsIgnoreCase("projectDesc")) && lang!=null && lang.equalsIgnoreCase("chi")) {
					Phrase my_phrase = new Phrase("", my_font_footer);
					Paragraph my_para = new Paragraph(my_phrase);
					my_para.setIndentationLeft(100);
					MyTextBuffer = "原始資料: ";
					new_container = my_para;
				}
			//} 
			else if (my_pass==0) {
				int size = 14;
				if (note_inline) {
					size = 12;
				}
				Font my_font = new Font(my_base_font, size, Font.NORMAL);
				//edith modify 2005/1/3 
				//T01n0001.xml <lb n="0001a08"/>以契經。演幽微。則<note n="0001004" resp="Taisho" type="orig" place="foot text">辨＝辯【宋】＊</note><app n="0001004"><lem>辨</lem><rdg wit="【宋】" resp="Taisho">辯</rdg></app>之以法相。然則三藏
				//以契經。演幽微。則{前面多空"　　　　"}辨 ##會進來兩次, 所以空4格		
				Phrase my_phrase = new Phrase("　　", my_font);
				Paragraph my_para = new Paragraph(my_phrase);
				new_container = my_para;
				//System.out.println("844|<p><lb n=" + my_lb + ">");
			}
			//System.out.println("853<p>");
			String type1 = el.getAttributeValue("type");
			if (type1 != null) {
				if (type1.equalsIgnoreCase("pre")) {
					lb_newline = true;
				}
			}
		}
		
		
		// <pb>
		if (my_element_name.equalsIgnoreCase("pb")) {
			String n = el.getAttributeValue("n");
			//System.out.print("p"+n+" ");
		}
			
		// <rdg>
		if (my_element_name.equalsIgnoreCase("rdg")) {
			my_pass++;
		}

		// <row>
		if (my_element_name.equalsIgnoreCase("row")) {
			new_row();
		}
		
		// <sg> edith add 2005/3/23 T19n0922.xml
		//<lb n="0021c29"/><p type="dharani"><tt><t lang="san-sd"><note n="0021029" resp="Taisho" type="orig" place="foot text">梵字甲乙丙三本俱無</note>&SD-A5A9;</t><t lang="chi">曩</t></tt>
		//<tt><t lang="san-sd">&SD-A5ED;</t><t lang="chi"><yin><zi>謨</zi><sg>引</sg></yin></t></tt>
		if (my_element_name.equalsIgnoreCase("sg")) {			
			Font my_font = new Font(my_base_font, 12, Font.NORMAL);
			Phrase my_phrase = new Phrase("(", my_font);
			new_container = my_phrase;			
		}

		// <table>
		if (my_element_name.equalsIgnoreCase("table")) {
			//String cols = el.getAttributeValue("cols");
			// 計算這個 Table 有幾個 cols
			org.jdom.Element row = el.getChild("row");
			List cells = row.getChildren("cell");
			Iterator it = cells.iterator();
			cols_of_table = 0;
			while (it.hasNext()) {
				org.jdom.Element cell = (org.jdom.Element) it.next();
				String cols = cell.getAttributeValue("cols");
				if (cols == null) {
					cols_of_table++;
				} else {
					cols_of_table += Integer.parseInt(cols);
				}
			}
			//System.out.print("<table cols=" + Integer.toString(cols_of_table) + ">\n");
			
			Table my_table = new Table(cols_of_table);
			
			//my_table.setSpaceBetweenCells(10); //edith hide 2005/3/24
			my_table.setWidth(100);
			my_table.setCellsFitPage(true); // 不要把 cell 切開在不同頁
			new_container = my_table;
			row_in_table=-1;
			in_table++;
		}
		
		// <title>
		if (my_element_name.equalsIgnoreCase("title")) {
			if (el.isAncestor(my_tei_header)) {
				Font my_font = new Font(my_base_font, 16, Font.BOLD, new Color(51, 153, 102));
				Phrase my_phrase = new Phrase("", my_font);
				//my_pass=0;
				Paragraph my_para = new Paragraph(my_phrase);
				new_container = my_para;
			}
		}
		
		// <trailer> edith add 2005/3/22 T01n0026.xml 少了卷尾文字, 是之前沒考慮到 <trailer>
		if (my_element_name.equalsIgnoreCase("trailer")) {		
			Font my_font = new Font(my_base_font, 14, Font.BOLD, new Color(51, 153, 102));
			Paragraph my_para = new Paragraph("", my_font);
			new_container = my_para;
		}
		
		return new_container;
	}

	void my_end_element (org.jdom.Element el, Object cur_container) throws DocumentException {
		String my_element_name=el.getName();
		Object p = el.getParent();
		org.jdom.Element my_parent;
		String my_parent_name=null;
		if (p instanceof org.jdom.Element) {
			my_parent = (org.jdom.Element) p;
			my_parent_name=my_parent.getName();
		}
		
		// </bibl>
		if (my_element_name.equalsIgnoreCase("bibl")) {
			if (my_parent_name.equalsIgnoreCase("sourceDesc")) {
				int i=MyTextBuffer.indexOf("Vol");
				//MyTextBuffer = MyTextBuffer.substring(i);
				MyTextBuffer = MyTextBuffer.replaceAll("Taisho Tripitaka", "大正新脩大正藏經");
				MyTextBuffer = MyTextBuffer.replaceAll("卍 Xuzangjing","卍新纂續藏經");
				//MyTextBuffer = "資料底本: 大正新脩大正藏經 " + MyTextBuffer;
				MyTextBuffer = "資料底本: " + MyTextBuffer;
				if (cur_container instanceof Paragraph) {
					((Paragraph) cur_container).add(MyTextBuffer);
				}
				//my_pdf_doc.add(MyParagraph);
			}
		}

		// </byline>
		if (my_element_name.equalsIgnoreCase("byline")) {
		}
		
		// </cell>
		if (my_element_name.equalsIgnoreCase("cell")) {
			MyTextBuffer="";
		}
		
		// </corr>
		if (my_element_name.equalsIgnoreCase("corr")) {
			//MyTextBuffer="";
		}

		// </date>
		if (my_element_name.equalsIgnoreCase("date")) {
			if (my_parent_name.equalsIgnoreCase("publicationStmt")) {
				int i=MyTextBuffer.indexOf(' ');
				if (i != -1) {
					// T54 的日期格式跟其他冊不太一樣
					int j=MyTextBuffer.indexOf(' ',i+1);
					MyTextBuffer = MyTextBuffer.substring(i+1,j);
				}
				MyTextBuffer = "修訂日期: " + MyTextBuffer;
				//edith modify 2004/12/30 增加發行日期
				MyTextBuffer = MyTextBuffer + "  發行日期: " + today;
				if (cur_container instanceof Paragraph) {
					Paragraph my_para = (Paragraph) cur_container;
					my_para.add(MyTextBuffer);
					my_pdf_doc.add(my_para);					
					my_para.clear();					
					my_para.add("發行單位: 中華電子佛典協會 (CBETA) http://www.cbeta.org");
				}
				MyTextBuffer = "";
			}
		}

		// </edition>
		if (my_element_name.equalsIgnoreCase("edition")) {
			if (el.isAncestor(my_tei_header)) {
				int i=MyTextBuffer.indexOf(' ');
				int j=MyTextBuffer.indexOf(' ',i+1);
				MyTextBuffer = "版本記錄: " + MyTextBuffer.substring(i+1,j-1);
				if (cur_container instanceof Paragraph) {
					((Paragraph) cur_container).add(MyTextBuffer);
				}
				MyTextBuffer = "";
			}
		}
		
		// </entry> edith add 2005/3/22 X63n1252.xml、X63n1256.xml 漏掉辭典條目文字, 也是因為之前沒考慮到 <entry>、<form>
		if (my_element_name.equalsIgnoreCase("entry")) {			
		}
		
		
		// </form> edith add 2005/3/22 X63n1252.xml、X63n1256.xml 漏掉辭典條目文字, 也是因為之前沒考慮到 <entry>、<form>
		if (my_element_name.equalsIgnoreCase("form")) {			
		}
		
		// </gloss>
		if (my_element_name.equalsIgnoreCase("gloss")) {
			my_pass--;
		}

		// </head>
		if (my_element_name.equalsIgnoreCase("head")) {
			String head_type = el.getAttributeValue("type");
			if (head_type!=null && head_type.equalsIgnoreCase("added")) {
				my_pass--;
				MyTextBuffer = "";
			}
		}
		
		// </item>
		if (my_element_name.equalsIgnoreCase("item")) {
		}

		// </jhead>
		if (my_element_name.equalsIgnoreCase("jhead")) {
		}

		// </juan>
		if (my_element_name.equalsIgnoreCase("juan")) {
		}		

		// </l>
		if (my_element_name.equalsIgnoreCase("l")) {
			MyTextBuffer += "　";
			/*
			Chunk my_chunk = new Chunk("　");
			if (cur_container instanceof Paragraph) {
				((Paragraph) cur_container).add(my_chunk);
			} else {
				((Phrase) cur_container).add(my_chunk);
			}
			*/
		}
		
		// </lg>
		if (my_element_name.equalsIgnoreCase("lg")) {
			//MyTextBuffer = "";
			lb_newline = false;
		}

		// end note
		// </note>
		if (my_element_name.equalsIgnoreCase("note") && my_pass==0) {
			String place = el.getAttributeValue("place");
			if (place!=null) {
				if (place.equalsIgnoreCase("inline") || place.equalsIgnoreCase("interlinear")) {
					String s = ")";
					if (MyTextBuffer.equalsIgnoreCase("　")) {
						s += MyTextBuffer;
						MyTextBuffer = "";
					}
					//System.out.println("1029|</note><lb n=" + my_lb + ">");
					Chunk my_chunk = new Chunk(s);
					((Phrase) cur_container).add(my_chunk);
					//System.out.println("1027|</note>|<note place=" + place + ">");
					note_inline = false;
				}
			}
		}

		// </p>
		if (my_element_name.equalsIgnoreCase("p")) 
		{			
			//if (el.isAncestor(my_tei_header)) {				
				String lang = el.getAttributeValue("lang");				
				if ((my_parent_name.equalsIgnoreCase("projectDesc")) && lang!=null && lang.equalsIgnoreCase("chi")) {
					if (cur_container instanceof Paragraph) {
						((Paragraph) cur_container).add(MyTextBuffer);	
						//System.out.print("1040</p>MyTextBuffer:"+MyTextBuffer+"\n\n");						
					}		
				}
				//System.out.println("1044|lb=" +my_lb+"</p>\n");
				MyTextBuffer = "";
			//}
			lb_newline = false;
		}
		
		// </rdg>
		if (my_element_name.equalsIgnoreCase("rdg")) {
			my_pass--;
		}

		// </sg> edith add 2005/3/23 T19n0922.xml
		//<lb n="0021c29"/><p type="dharani"><tt><t lang="san-sd"><note n="0021029" resp="Taisho" type="orig" place="foot text">梵字甲乙丙三本俱無</note>&SD-A5A9;</t><t lang="chi">曩</t></tt>
		//<tt><t lang="san-sd">&SD-A5ED;</t><t lang="chi"><yin><zi>謨</zi><sg>引</sg></yin></t></tt>
		if (my_element_name.equalsIgnoreCase("sg")) {			
			Chunk my_chunk = new Chunk(")");
			((Phrase) cur_container).add(my_chunk);
		}		
		
		// </table>
		if (my_element_name.equalsIgnoreCase("table")) {
			//my_pdf_doc.add(my_table);
			in_table--;
		}
		
		// </title>
		if (my_element_name.equalsIgnoreCase("title")) {
			if (el.isAncestor(my_tei_header)) {
				String my_title = MyTextBuffer;
				MyTextBuffer = "";
				int i=my_title.indexOf("No.");
				if (i != -1) {
					my_title = "《" + my_title.substring(i+9) + "》CBETA 電子版";
				}
				if (cur_container instanceof Paragraph) {
					((Paragraph) cur_container).add(my_title);
				}
				//my_pdf_doc.add(MyParagraph);
			}
		}
		
		
		// </trailer> edith add 2005/3/22 T01n0026.xml 少了卷尾文字, 是之前沒考慮到 <trailer>
		if (my_element_name.equalsIgnoreCase("trailer")) {
		}
	}

	void new_row ()  {
		first_cell_in_row = true;
		row_in_table++;
	}
	
	String my_start_gaiji (org.jdom.Element el, Object cur_container) {
		//edith modify 2005/1/11將Unicode或通用字或組字式記錄在 array 裡, 以便在<mulu>中可以使用
		String cb=el.getAttributeValue("cb");	
		//edith modify 2005/3/8 *.ent 裡多一個欄位: uni_flag 
		//缺字的呈現順序:unicode、通用字、組字式 (以 uni_flag 值判斷要不要用unicode)
		
		String uniflag=el.getAttributeValue("uniflag");	
		// added by Ray 2005/3/24 08:06下午
		// jap.ent 裏的 gaiji 沒有 uniflag 屬性
		if (uniflag == null) {
			uniflag = "1";
		}
		
		if (debug2) {System.out.println("\n420|"+ cb +"[" + uniflag+"]\n");}
			
		String t="";
		boolean done=false;
		boolean xitan=false;
		Image my_png=null;
		String s;

		// 先處理悉曇字
		if (cb!=null && cb.startsWith("SD-")) { 
			xitan=true;
			s=cb.substring(3);
			int i=Integer.parseInt(s, 16);
			t += (char)i;
			my_process_text("", cur_container);
			my_add_chunk(t, my_font_xitan, cur_container);
			return "";
		}

		// 優先用 Unicode
		s=el.getAttributeValue("uni");
		//edith modify 2005/3/8 *.ent 裡多一個欄位: uni_flag 
		//若有unicode值, 但是uni_flag 值為0的話, 就不使用unicode碼
		if (s!=null && !uniflag.equalsIgnoreCase("0")) {
			// 2005/4/6 15:29 by Ray
			// X78n1539.ent
			// <!ENTITY CI0003 "<gaiji uniflag='1' cb='CBx00662' des='髣[髟/弗]' uni='9AE3;9AF4;' nor='彷彿' cx='髣＆CB00662；' mojikyo='M045414' mofont='Mojikyo M109' mochar='968E'/>" >
			if (s.indexOf(";") != -1) {
				String[] unis = s.split(";");
				for (int i=0; i<unis.length; i++) {
					t += (char) Integer.parseInt(unis[i], 16);
				}
			/*heaven modify 2005/3/21 start:目前可顯現的 unicode 都是四碼*/
			/*if (s!=null) {
				int i=Integer.parseInt(s, 16);*/
			} else {
				while (s!=null) {
					int i;
					if(s.length() > 5)
					{
						i=Integer.parseInt(s.substring(0,4), 16);
						s = s.substring(4);
						if(s.length() == 0) s= null;
					}
					else
					{
						i=Integer.parseInt(s, 16);
						s=null;
					}
					/*heaven modify 2005/3/21 end*/			    
					t += (char)i;
					if (debug2) {System.out.println("460_unicode["+done+"]\n");}	
				}
			}
			return t;
		}
		
		if (debug2) {System.out.println("\n464|"+ cb +"[" + uniflag+"]\n");}
		if (debug2) {System.out.println("465_unicode["+done+"]\n");}			
		
		// 其次用通用字
		if (!done && my_nor) {
			s=el.getAttributeValue("nor");
			if (s!=null) {
				return s;
			}
		}
		
		s=el.getAttributeValue("des");
		if (s!=null) {
			return s;
		} 

		
		//if (debug2) {System.out.println("488_s|" + s +"\n");}	
		//if (debug2) {System.out.println("489_cb|" + cb +"\n");}	
		String dir = null;
		// 其次用 M 碼圖檔
		/*
		if (!done) {
			String m=el.getAttributeValue("mojikyo");
			if (m!=null) {
				m = mojikyo_root + "\\" + m.substring(1) + ".png";
				File f = new File(m);
				if (f.exists()) {					
					dir = "file://" + m;
				}
			}
		}
		*/

		/*
		if (!done) {
			if (dir == null) {
				dir  = "file://" + cb_png_root + "\\" + cb.substring(2,4) + "\\" + cb + ".png";
			}				
			if (debug2) {System.out.println("549cb|" + cb +"\n");}
			if (debug2) {System.out.println("551s|" + s +"\n");}
			if (debug2) {System.out.println("552t|" + t +"\n");}	
			
			if (dir != null) {
				try {
					my_png = Image.getInstance(new URL(dir));
					my_png.scaleAbsolute(14,14);
				} catch(MalformedURLException mue) {
					//System.err.println("408 " + mue.getMessage());
					System.err.println("408 " + mue.toString());
					System.exit(1);
				} catch(IOException ioe) {
					System.err.println("\n411 " +dir);
					//System.err.println("412 " + ioe.getMessage());
					System.err.println("412 " + ioe.toString());
					System.exit(1);
				}
			}
		}
		*/
		
		/*
		if (my_pass==0) {
			if (parent_container instanceof Phrase) {
				if (my_png != null) {
					Chunk my_chunk = new Chunk(my_png,0,0);
					((Phrase) parent_container).add(my_chunk);
				} else {
					if (xitan) {
						Chunk my_chunk = new Chunk(t, my_font_xitan);
						((Phrase) parent_container).add(my_chunk);
						my_chunk=null;
					} else {						
						((Phrase) parent_container).add(t);
					}
				}
			} else if (parent_container instanceof Cell) {
				if (my_png != null) {
					Chunk my_chunk = new Chunk(my_png,0,0);
					((Cell) parent_container).add(my_chunk);
				} else {					
					Chunk my_chunk;
					if (xitan) {
						my_chunk = new Chunk(t, my_font_xitan);
					} else {
						my_chunk = new Chunk(t, my_font_body);
					}
					((Cell) parent_container).add(my_chunk);
					my_chunk=null;
				}
			}	
		} else {
			MyTextBuffer += t;
		} */
		return "";
	}

	// 將Unicode或通用字或組字式記錄在 array 裡, 以便在<mulu>中可以使用
	void put_cb_in_array (String cb, String t) {
		//edith modify 2005/2/1 避開cb是null的情況, 不然程式會中斷, 例如:T18n0854.ent
		if (cb == null) {
			return;
		}

		String des_temp=cb+ "→" +t;
		des_array[des_i] = des_temp;
		if (debug2) {System.out.println("471_des_array["+des_i+"]=" +des_array[des_i]+"\n");}
		//System.out.println("483|des_array["+des_i+"]=" +des_array[des_i]+"\n");
		des_i++;							
	}

	String search_array(String s) {
		if (des_i==0) {
			return null;
		}
		//System.out.println("1230| search_array(" + s + ")\n");
		
		for (int i = 0; i < des_i; i++) 
		{
			//cb="CB00145"	des_array[i]="CB00145→[少/兔]" 找到的時候
			//System.out.println("422|find or not find(" + s + ")" + des_array[i] +"\n");
			if (des_array[i].indexOf(s) !=-1)
			{
				//System.out.println("413|find(" + i + ")" + des_array[i] +"\n");
				return des_array[i];
			}
		}
		return null;
	}

	void mulu_gaiji () {
		if (my_write_mulu) {
			return;
		}
		
		if (!my_mulu) {
			return;
		}
		
		if (my_label==null) {
			return;
		}
		
		if (my_label.indexOf("＆CB") ==-1) {
			return;
		}

		if (debug2) {System.out.println("491|" + my_label +"\n");}
		String s;
		while (my_label.indexOf("＆")!=-1 && my_label.indexOf("；")!=-1) {
			//edith modify 2005/1/11  尚未寫到左邊目錄 && my_mulu && my_label有值 && my_label內含＆CB
			//cb_label="CB00145"	cb_tmp="CB00145→[少/兔]"
			String ent = my_label.substring( my_label.indexOf("＆")+1, my_label.indexOf("；"));
			if (debug2) {System.out.println("494|" + ent +"\n");}
			s = search_array(ent);
			if (s != null) {
				//cb_rep="[少/兔]"
				String cb_rep = s.substring( s.indexOf("→")+1);
				//label =label.replace('＆', ' ');
				//label =label.replace('；', ' ');
				ent = "＆" + ent + "；";
				my_label =my_label.replaceAll(ent, cb_rep);
				if (debug2) {System.out.println("508|" + my_label +"\n");}
			} else {
				break;
			}
		}
		if (my_label.indexOf("＆")==-1 && my_label.indexOf("；")==-1) {
			PdfDestination my_d = new PdfDestination(PdfDestination.FIT); 
			my_outline_mulu[level] = new PdfOutline(my_outline_mulu[level-1], my_d, my_label, false);
			my_pdf_cb.addOutline(my_outline_mulu[level]);
			my_write_mulu=true;
		}
	}
	
	/*
		s: 要寫進 pdf 的字串
		f: 指字的字型, 傳入 null 表示不指定
		o: 上層 pdf container
	*/
	void my_add_chunk (String s, Font f, Object o) {
		Chunk my_chunk;
		if (f==null) {
			my_chunk = new Chunk(s);
		} else {
			my_chunk = new Chunk(s, f);
		}
			
		if (o instanceof Phrase) {
			((Phrase) o).add(my_chunk);
		} else if (o instanceof Cell) {
			((Cell) o).add(my_chunk);
		}
	}
	
	class my_page_event_helper extends PdfPageEventHelper {
		public my_page_event_helper() {
		}

		public void onStartPage(PdfWriter writer, com.lowagie.text.Document document) {
			my_dirty_flag=false;
		}
	}
}