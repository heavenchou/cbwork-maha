#
# setup.pl
# CBETA CD Setup
# written by Zhou, Ray
#
	if ($^O =~ /Win/) {
		push (@INC, "/setup/win");
	} elsif ($^O =~ /linux/) {
		my $path = `pwd`;
		push (@INC, $path);
		setInc($path);
	} elsif ($^O =~ /Mac/) {
		exec "mac/setup.pl";
	}

use Tk;
use File::Copy;
use Win32;
use Win32::Shortcut();
use Win32::TieRegistry(Delimiter => '/');

require Tk::Dialog;
require Tk::DirTree;
require "msgtc.plx";

$cbroot="C:/cbeta";
$ENV{'PATH'} = "/setup/pc/perl/bin;/setup/pc";
$regRoot = "CUser";

@selectedT = ();
@selectedS = ();
@selectedR = ();
@selectedH = ();

$screenX = 640;
$screenY = 480;

$mw=MainWindow->new(-background=>white);
my $w = 604;
my $h = 220;
$x = $screenX/2 - $w/2;
$y = $screenY/2 - $h/2;
$mw->geometry("${w}x$h+$x+$y");
$mw->title("CBETA 2001");
$image   = $mw->Photo(-file => 'title.gif');
$photo_c = $mw->Photo(-file => 'chinese.gif');
$photo_e = $mw->Photo(-file => 'english.gif');
$canvas = $mw->Canvas(-width=>$w, -height=>151);
$canvas->createImage(0,0,-image => $image, -anchor=>nw);
$canvas->pack();
$mw->Button(
	-image=>$photo_c, 
	-background=>white,
	-borderwidth=>0,
	-command=> sub { require 'msgtc.plx'; step0(); } 
	)->pack(-side=>'right', -padx=>110);
$mw->Button(
	-image=>$photo_e, 
	-background=>white,
	-borderwidth=>0,
	-command=> sub { require 'msgen.plx'; step0(); } 
	)->pack(-side=>'right');

MainLoop;

sub step0 {
	my $text = $msg{"textWelcome"};
	if (Exists($t0)) {
		myFocus($t0);
		return;
	}
	$t0 = $mw->Toplevel(-takefocus=>1);
	$t0->focus();
	$t0->raise();
	$t0->title($msg{"welcome"});
	
	my $w = 508;
	my $h = 220;
	$x = $screenX/2 - $w/2;
	$y = $screenY/2 - $h/2;
	$t0->geometry("${w}x$h+$x+$y");
	$t0->title("CBETA 2001");
	$image = $t0->Photo(-file => 'title.gif');
	$canvas = $t0->Canvas(-width=>508, -height=>158);
	$canvas->createImage(0,0,-image => $image, -anchor=>nw);
	$canvas->pack();
	$t0->Button(-text=>$msg{"installCBETA"}, -command=> \&step1)->pack(-expand=>1, -fill=>'x');
	$t0->Button(-text=>$msg{"exit"}, -command=> sub { exit } )->pack(-expand=>1, -fill=>'x');
}

sub step1 {
	my $text = $msg{"textWelcome"};
	if (Exists($t1)) {
		myFocus($t1);
		return;
	}
	$t1 = $mw->Toplevel(-takefocus=>1);
	$t1->focus();
	$t1->raise();
	$t1->title($msg{"welcome"});
	
	my $w = 300;
	my $h = 150;
	my $x = $screenX/2 - $w/2;
	my $y = $screenY/2 - $h/2;
	$t1->geometry("${w}x$h+$x+$y");
	$t1->Label(-text => $text, -wraplength => 300, -justify=>'left')->pack();
	$t1->Button(-text=>$msg{"cancel"}, -command => sub { if (confirmExit()) {$t1->withdraw} })   
		-> pack(-side=>'right', -padx=>5);
	$t1->Button(-text=>$msg{"next"}, -command => sub { $t1->withdraw; step2('n'); }) 
		-> pack(-side=>'right', -padx=>5);
}

sub step2 {
	if (Exists($t2)) {
		myFocus($t2);
		return;
	}
	
	$t2 = $mw->Toplevel();
	$t2->focus();
	$t2->title($msg{"license"});
	
	my $w = 500;
	my $h = 250;
	my $h2 = 10;
	if ($lang eq "en") {
		$h += 100;
		$h2 += 9;
	}
	my $x = $screenX/2 - $w/2;
	my $y = $screenY/2 - $h/2;
	$t2->geometry("${w}x$h+$x+$y");


	my $s = $msg{"readCopyright"};
	$t2->Label(-text => $s)->pack();
	$text2 = $t2->Scrolled(
		"Text",
		-scrollbars => "ose",
		height => $h2
		)->pack();
	$text2->insert("end",$msg{"textLicense"});
	$t2->Button(-text=>$msg{"cancel"},-command => sub { if (confirmExit()) {$t2->withdraw} })-> pack(-side=>'right', -padx=>5);
	$t2->Button(-text=>$msg{"accept"},-command => sub { $t2->withdraw; step3('n'); })-> pack(-side=>'right', -padx=>5);
	$t2->Button(-text=>$msg{"back"}, -command => sub { $t2->withdraw; step1(); })-> pack(-side=>'right', -padx=>5);
}

# 選擇要安裝的版本
sub step3 {
	if (Exists($t3)) {
		myFocus($t3);
		return;
	}
	
	$t3 = $mw->Toplevel();
	$t3->focus();
	$t3->title($msg{"title3"});

	$w = 200;
	my $h = 150;
	if ($lang eq "en") {
		$w += 50;
	}
	my $x = $screenX/2 - $w/2;
	my $y = $screenY/2 - $h/2;
	$t3->geometry("${w}x$h+$x+$y");

	$t3->Label(-text => $msg{"selectFormat"})->pack();
	$t3->Checkbutton(-text=>$msg{"plainTextFormat"},-anchor=>'w',-variable => \$chk_t)->pack(-expand=>1,-fill=>'x');
	$t3->Checkbutton(-text=>$msg{"rtfFormat"}      ,-anchor=>'w',-variable => \$chk_r)->pack(-expand=>1,-fill=>'x');
	$t3->Checkbutton(-text=>$msg{"hhFormat"}       ,-anchor=>'w',-variable => \$chk_h)->pack(-expand=>1,-fill=>'x');
	#$t3->Checkbutton(-text=>"Mojikyo字型",-anchor=>'w',-variable => \$chk_m)	->pack(-expand=>1,-fill=>'x');
	$t3->Button(-text=>$msg{"cancel"}, -command => sub { if (confirmExit()) {$t3->withdraw} })-> pack(-side=>'right', -padx=>5);
	$t3->Button(-text=>$msg{"next"}, -command => sub { $t3->withdraw; step4('n'); }) -> pack(-side=>'right', -padx=>5);
	$t3->Button(-text=>$msg{"back"}, -command => sub { $t3->withdraw; step2(); }) -> pack(-side=>'right', -padx=>5);
}

# 文字版選項
sub step4 {
	my $dir = shift;
	if (not $chk_t) {
		if ($dir eq 'n') { step5('n'); }
		else { step3(); }
		return; 
	}
	if (Exists($t4)) {
		myFocus($t4);
		return;
	}
	$t4 = $mw->Toplevel();
	$t4->focus();
	$t4->title($msg{"title4"});

	$w = 300;
	my $h = 280;
	if ($lang eq "en") {
		$w += 300;
	}
	
	my $x = $screenX/2 - $w/2;
	my $y = $screenY/2 - $h/2;
	$t4->geometry("${w}x$h+$x+$y");

	$fr40 = $t4->Frame()->pack();
	$fr41 = $fr40->Frame()->pack(-side=>'left');
	
	$fr41->Label(-text => $msg{"selectPlainTextFormat"},-anchor=>'w')->pack(-expand=>1,-fill=>'x');
	$fr41->Radiobutton(-anchor=>'w',-variable=>\$ptFormat,-text=>$msg{"normalFormat"} ,-value=>'normal')->pack(-expand=>1,-fill=>'x')->select();
	$fr41->Radiobutton(-anchor=>'w',-variable=>\$ptFormat,-text=>$msg{"compactFormat"},-value=>'trim')->pack(-expand=>1,-fill=>'x');
	$fr41->Radiobutton(-anchor=>'w',-variable=>\$ptFormat,-text=>$msg{"appFormat"}    ,-value=>'app')->pack(-expand=>1,-fill=>'x');
	
	$fr41->Label(-text => $msg{"selectTextEncoding"},-anchor=>'w')->pack(-expand=>1,-fill=>'x');
	$fr41->Radiobutton(-text=>"Big5",-anchor=>'w',-variable=>\$ptEncoding,-value=>'big5')->pack(-expand=>1,-fill=>'x')->select();
	$fr41->Radiobutton(-text=>"GBK" ,-anchor=>'w',-variable=>\$ptEncoding,-value=>'gbk')->pack(-expand=>1,-fill=>'x');
	$fr41->Radiobutton(-text=>"SJIS",-anchor=>'w',-variable=>\$ptEncoding,-value=>'sjis')->pack(-expand=>1,-fill=>'x');
	$fr41->Radiobutton(-text=>"UTF8",-anchor=>'w',-variable=>\$ptEncoding,-value=>'utf8')->pack(-expand=>1,-fill=>'x');
	
	$fr42 = $fr40->Frame()->pack(-side=>'left');
	$fr42->Label(-text => $msg{"QueZi"},-anchor=>'w')->pack(-expand=>1,-fill=>'x');
	$fr42->Checkbutton(-text=>$msg{"useNorChar"},-anchor=>'w',-variable=>\$ptNormalize)->pack(-expand=>1,-fill=>'x')->select();
	$fr42->Radiobutton(-text=>$msg{"useZuZiShi"},-anchor=>'w',-variable=>\$ptMissingChar,-value=>'e')->pack(-expand=>1,-fill=>'x')->select();
	$fr42->Radiobutton(-text=>$msg{"useMojikyo"},-anchor=>'w',-variable=>\$ptMissingChar,-value=>'m')->pack(-expand=>1,-fill=>'x');
	
	# 選擇安裝方式
	$fr42->Label(-text => $msg{"label4"},-anchor=>'w')->pack(-expand=>1,-fill=>'x');
	$fr42->Radiobutton(-text=>$msg{"installAll"},-anchor=>'w',-variable=>\$ptInstall,-value=>'a')->pack(-expand=>1,-fill=>'x')->select();
	$fr42->Radiobutton(-text=>$msg{"installByVol"},-anchor=>'w',-variable=>\$ptInstall,-value=>'t')->pack(-expand=>1,-fill=>'x');
	$fr42->Radiobutton(-text=>$msg{"installBySutra"},-anchor=>'w',-variable=>\$ptInstall,-value=>'s')->pack(-expand=>1,-fill=>'x');
	$fr42->Label(-text => "", -height=>2)->pack();

	$fr43 = $t4->Frame()->pack(-expand=>1,-fill=>'x');
	$fr43->Button(-text=>$msg{"cancel"}, -command => sub { if (confirmExit()) {$t4->withdraw} })-> pack(-side=>'right', -padx=>5);
	$fr43->Button(-text=>$msg{"next"}, -command => sub { $t4->withdraw; step5('n'); }) -> pack(-side=>'right', -padx=>5);
	$fr43->Button(-text=>$msg{"back"}, -command => sub { $t4->withdraw; step3(); }) -> pack(-side=>'right', -padx=>5);
}

# 文字版 選冊
sub step5 {
	my $dir = shift;
	if (not $chk_t or $ptInstall ne "t") { 
		if ($dir eq "n") { step5a('n'); }
		else { step4(); }
		return; 
	}
	if (Exists($t5)) {
		myFocus($t5);
		return;
	}
	$t5 = $mw->Toplevel();
	$t5->focus();
	$t5->title($msg{"title4"});

	my $w = 200;
	my $h = 250;
	my $x = $screenX/2 - $w/2;
	my $y = $screenY/2 - $h/2;
	$t5->geometry("${w}x$h+$x+$y");

	$t5->Label(-text => $msg{"selectPlainTextVol"})->pack();
	
	$fr5 = $t5->Frame()->pack();
	$fr5->Button(-text=>$msg{"selectAll"}, -command => sub { $lbt->selectionSet  (0,'end'); })-> pack(-side=>'left', -padx=>5);
	$fr5->Button(-text=>$msg{"cancelAll"}, -command => sub { $lbt->selectionClear(0,'end'); })-> pack(-side=>'left', -padx=>5);
	
	$lbt = $t5->Scrolled('Listbox',-scrollbars=>'e',-selectmode=>'multiple',width=>30)->pack();
	$lbt->insert('end',@msgVols);
	
	$t5->Button(-text=>$msg{"cancel"}, -command => sub { if (confirmExit()) {$t5->withdraw} })-> pack(-side=>'right', -padx=>5);
	$t5->Button(
		-text=>$msg{"next"}, 
		-command => sub { 
				@selectedT=$lbt->curselection;
				$t5->withdraw; 
				step6('n'); 
			}
		) -> pack(-side=>'right', -padx=>5);
	$t5->Button(-text=>$msg{"back"}, -command => sub { $t5->withdraw; step4(); }) -> pack(-side=>'right', -padx=>5);
}

# 文字版 選經
sub step5a {
	my $dir = shift;
	if (not $chk_t or $ptInstall ne "s") { 
		if ($dir eq "n") { step6('n'); }
		else { step5(); }
		return; 
	}
	
	if (Exists($t5a)) {
		myFocus($t5a);
		return;
	}

	$t5a = $mw->Toplevel(-takefocus=>1);
	$t5a->focus();
	$t5a->title($msg{"title4"});

	my $w = 580;
	my $h = 260;
	my $x = $screenX/2 - $w/2;
	my $y = $screenY/2 - $h/2;
	$t5a->geometry("${w}x$h+$x+$y");

	$t5a->Label(-text => $msg{"label5a"})->pack();
	$fr5a0 = $t5a->Frame()->pack();
	$entry5a = $fr5a0->Entry(-textvariable=>\$keyword,-takefocus=>1)->pack(-side=>'left');
	$entry5a->bind("<Return>",\&searchSutra);
	$entry5a->focus();
	$fr5a0->Button(-text=>$msg{"search"},-command=>\&searchSutra)->pack(-side=>'left');
	
	$fr5a = $t5a->Frame()->pack();
	$fr5a1 = $fr5a->Frame()->pack(-side=>'left');
	$fr5a2 = $fr5a->Frame()->pack(-side=>'left');
	$fr5a3 = $fr5a->Frame()->pack(-side=>'left');
	
	$lb5a1 = $fr5a1->Scrolled('Listbox',-scrollbars=>'e',-selectmode=>'multiple',width=>30)->pack();
	$lb5a1->bind("<Double-Button-1>",\&dbSelect5);
	
	$fr5a2->Button(-text=>$msg{"select"} . "=>", -command => \&select5)-> pack(-padx=>5);
	$fr5a2->Button(-text=>"<=" . $msg{"remove"}, -command => \&remove5)-> pack(-padx=>5);
	
	$lb5a2 = $fr5a3->Scrolled('Listbox',-scrollbars=>'e',-selectmode=>'multiple',width=>30)->pack();
	
	$fr5a4 = $t5a->Frame()->pack();
	$fr5a4->Button(-text=>$msg{"cancel"}, -command => sub { if (confirmExit()) {$t5a->withdraw} })-> pack(-side=>'right', -padx=>5);
	$fr5a4->Button(
		-text=>$msg{"next"}, 
		-command => sub { 
				@selectedS = $lb5a2->get(0,'end');
				$t5a->withdraw; 
				step6('n'); 
			}
		) -> pack(-side=>'right', -padx=>5);
	$fr5a4->Button(-text=>$msg{"back"}, -command => sub { $t5a->withdraw; step5(); }) -> pack(-side=>'right', -padx=>5);
}

sub searchSutra {
	my $s;
	$lb5a1->delete(0,'end');
	open I, "<sutralst.txt";
	while (<I>) {
		chomp;
		if (/$keyword/) {
			s/##/ /g;
			s/ $//;
			$lb5a1->insert('end', $_ . $msg{"juan"});
		}
	}
	close I;
}

sub dbSelect5 {
	my $s = $lb5a1->get('active');
	$lb5a1->delete('active');
	$lb5a2->insert('end',$s);
}

sub select5 {
	my @selected = $lb5a1->curselection();
	my $i;
	foreach $i (@selected) {
		my $s = $lb5a1->get($i);
		$lb5a2->insert('end',$s);
	}
	foreach $i (@selected) {
		$lb5a1->delete($i);
	}
}

sub remove5 {
	my @selected = $lb5a2->curselection();
	my $i;
	foreach $i (@selected) {
		my $s = $lb5a2->get($i);
		$lb5a2->delete($i);
		$lb5a1->insert('end',$s);
	}
}

# RTF版 選項
sub step6 {
	my $dir = shift;
	if (not $chk_r) {
		if ($dir eq 'n') { step7('n'); }
		else { step5(); }
		return; 
	}
	
	if (Exists($t6)) {
		myFocus($t6);
		return;
	}
	
	$t6 = $mw->Toplevel();
	$t6->focus();
	$t6->title($msg{"title6"});
	
	if ($lang eq "en") { $w = 300; }
	else { $w = 200; }
	my $h = 310;
	my $x = $screenX/2 - $w/2;
	my $y = $screenY/2 - $h/2;
	$t6->geometry("${w}x$h+$x+$y");
	
	# 缺字處理方式 選項
	$t6->Label(-text => "\n".$msg{"QuiZi"},-anchor=>'w')->pack(-expand=>1,-fill=>'x');
	$t6->Checkbutton(-text=>$msg{"useUnicode"},-anchor=>'w',-variable=>\$rtfUnicode)->pack(-expand=>1,-fill=>'x')->select();
	$t6->Checkbutton(-text=>$msg{"useNorChar"},-anchor=>'w',-variable=>\$rtfNormalize)->pack(-expand=>1,-fill=>'x')->select();
	$t6->Checkbutton(-text=>$msg{"useMojikyoTTF"},-anchor=>'w',-variable=>\$rtfMojikyo)->pack(-expand=>1,-fill=>'x')->select();
	$t6->Radiobutton(-text=>$msg{"useZuZiShi"},-anchor=>'w',-variable=>\$rtfMissingChar,-value=>'e')->pack(-expand=>1,-fill=>'x')->select();
	$t6->Radiobutton(-text=>$msg{"useMojikyo"},-anchor=>'w',-variable=>\$rtfMissingChar,-value=>'m')->pack(-expand=>1,-fill=>'x');
	$t6->Checkbutton(-text=>$msg{"useMarkup"},-anchor=>'w',-variable=>\$rtfTag)->pack(-expand=>1,-fill=>'x');
	
	# 全部安裝 或 分冊安裝
	$t6->Label(-text => $msg{"label4"},-anchor=>'w')->pack(-expand=>1,-fill=>'x');
	$t6->Radiobutton(-text=>$msg{"installAll"},-anchor=>'w',-variable=>\$rtfInstall,-value=>'a')->pack(-expand=>1,-fill=>'x')->select();
	$t6->Radiobutton(-text=>$msg{"installByVol"},-anchor=>'w',-variable=>\$rtfInstall,-value=>'t')->pack(-expand=>1,-fill=>'x');

	$t6->Button(-text=>$msg{"cancel"}, -command => sub { if (confirmExit()) {$t6->withdraw} })-> pack(-side=>'right', -padx=>5);
	$t6->Button(-text=>$msg{"next"}, -command => sub { $t6->withdraw; step7('n'); }) -> pack(-side=>'right', -padx=>5);
	$t6->Button(-text=>$msg{"back"}, -command => sub { $t6->withdraw; step5(); }) -> pack(-side=>'right', -padx=>5);
}

# RTF版 選冊安裝
local $lb7;
sub step7 {
	my $dir = shift;
	if (not $chk_r or $rtfInstall ne "t") { 
		if ($dir eq "n") { step8('n'); }
		else { step6(); }
		return; 
	}
	if (Exists($t7)) {
		myFocus($t7);
		return;
	}
	
	$t7 = $mw->Toplevel();
	$t7->focus();
	$t7->title($msg{"title6"});

	if ($lang eq "en") { $w=300; }
	else { $w = 200; }
	my $h = 250;
	my $x = $screenX/2 - $w/2;
	my $y = $screenY/2 - $h/2;
	$t7->geometry("${w}x$h+$x+$y");

	$t7->Label(-text => $msg{"label7"})->pack();
	
	$fr7 = $t7->Frame()->pack();
	$fr7->Button(-text=>$msg{"selectAll"}, -command => sub { $lb7->selectionSet  (0,'end'); })-> pack(-side=>'left', -padx=>5);
	$fr7->Button(-text=>$msg{"cancelAll"}, -command => sub { $lb7->selectionClear(0,'end'); })-> pack(-side=>'left', -padx=>5);
	
	$lb7 = $t7->Scrolled('Listbox',-scrollbars=>'e',-selectmode=>'multiple',width=>30)->pack();
	$lb7->insert('end',@msgVols);
	
	$t7->Button(-text=>$msg{"cancel"}, -command => sub { if (confirmExit()) {$t7->withdraw} })-> pack(-side=>'right', -padx=>5);
	$t7->Button(
		-text=>$msg{"next"}, 
		-command => sub { 
				@selectedR = $lb7->curselection;
				$t7->withdraw; 
				step8('n'); 
			}
		) -> pack(-side=>'right', -padx=>5);
	$t7->Button(-text=>$msg{"back"}, -command => sub { $t7->withdraw; step6(); }) -> pack(-side=>'right', -padx=>5);
}

# HTML Help 版選項
sub step8 {
	my $dir = shift;
	if (not $chk_h) {
		if ($dir eq 'n') { step9('n'); }
		else { step7(); }
		return; 
	}
	
	if (Exists($t8)) {
		myFocus($t8);
		return;
	}
	
	$t8 = $mw->Toplevel();
	$t8->focus();
	$t8->title($msg{"title8"});
	
	if ($lang eq "en") { $w=200; }
	else { $w = 200; }
	my $h = 130;
	my $x = $screenX/2 - $w/2;
	my $y = $screenY/2 - $h/2;
	$t8->geometry("${w}x$h+$x+$y");
	
	$t8->Label(-text => $msg{"label4"},-anchor=>'w')->pack(-expand=>1,-fill=>'x');
	$t8->Radiobutton(-text=>$msg{"installAll"},-anchor=>'w',-variable=>\$hhInstall,-value=>'a')->pack(-expand=>1,-fill=>'x')->select();
	$t8->Radiobutton(-text=>$msg{"installByBu"},-anchor=>'w',-variable=>\$hhInstall,-value=>'b')->pack(-expand=>1,-fill=>'x');

	$t8->Button(-text=>$msg{"cancel"},-command=>sub{if(confirmExit()) {$t8->withdraw} })-> pack(-side=>'right', -padx=>5);
	$t8->Button(-text=>$msg{"next"},-command=>sub{$t8->withdraw;step9('n'); }) -> pack(-side=>'right', -padx=>5);
	$t8->Button(-text=>$msg{"back"},-command=>sub{$t8->withdraw;step7(); }) -> pack(-side=>'right', -padx=>5);
}

# HTML Help版 選部安裝
sub step9 {
	my $dir = shift;
	
	if (not $chk_h or $hhInstall eq "a") { 
		if ($dir eq "n") { step10('n'); }
		else { step8(); }
		return;
	}
	
	if (Exists($t9)) {
		myFocus($t9);
		return;
	}
	
	$t9 = $mw->Toplevel();
	$t9->focus();
	$t9->title($msg{"title8"});
	
	if ($lang eq "en") { $w=350; }
	else { $w = 220; }
	my $h = 250;
	my $x = $screenX/2 - $w/2;
	my $y = $screenY/2 - $h/2;
	$t9->geometry("${w}x$h+$x+$y");

	$t9->Label(-text => $msg{"label9"})->pack();
	
	$fr9 = $t9->Frame()->pack();
	$fr9->Button(-text=>$msg{"selectAll"}, -command => sub { $lb9->selectionSet  (0,'end'); })-> pack(-side=>'left', -padx=>5);
	$fr9->Button(-text=>$msg{"cancelAll"}, -command => sub { $lb9->selectionClear(0,'end'); })-> pack(-side=>'left', -padx=>5);
	
	$lb9 = $t9->Scrolled('Listbox',-scrollbars=>'e',-selectmode=>'multiple',width=>30)->pack();
	$lb9->insert('end',@msgParts);
	
	$t9->Button(-text=>$msg{"cancel"}, -command => sub { if (confirmExit()) {$t9->withdraw} })-> pack(-side=>'right', -padx=>5);
	$t9->Button(
		-text=>$msg{"next"}, 
		-command => sub { 
				@selectedH = $lb9->curselection();
				$t9->withdraw; 
				step10('n'); 
			}
		) -> pack(-side=>'right', -padx=>5);
	$t9->Button(-text=>$msg{"back"}, -command => sub { $t9->withdraw; step8(); }) -> pack(-side=>'right', -padx=>5);
}

# 選擇安裝路徑
sub step10 {
	if (Exists($t10)) {
		myFocus($t10);
		return;
	}
	$t10 = $mw->Toplevel();
	$t10->focus();
	$t10->title($msg{"title10"});
	
	my $w = 200;
	my $h = 400;
	my $x = $screenX/2 - $w/2;
	my $y = $screenY/2 - $h/2;
	$t10->geometry("${w}x$h+$x+$y");

	$t10->Label(-text => $msg{"label10"})->pack(-side=>'top');
	$frame10 = $t10->Frame()->pack(-pady=>3);
	$curDrive = "C:";
	$frame10->Button(
		-text=>"C:",
		-command=>sub{ 
				$dirtree->chdir("C:/"); 
				if ($curDrive ne "C:") { $dirtree->close($curDrive); }
				$curDrive = "C:";
				$cbroot = "$curDrive/";
			}
		)->pack(-side=>'left',-padx=>5);
	$frame10->Button(
		-text=>"D:",
		-command=>sub{ 
				$dirtree->chdir("D:/"); 
				if ($curDrive ne "D:") { $dirtree->close($curDrive); }
				$curDrive = "D:";
				$cbroot = "$curDrive/";
			}
		)->pack(-side=>'left',-padx=>5);
	$frame10->Button(
		-text=>"E:",
		-command=>sub{ 
				$dirtree->chdir("E:/"); 
				if ($curDrive ne "E:") { $dirtree->close($curDrive); }
				$curDrive = "E:";
				$cbroot = "$curDrive/";
			}
		)->pack(-side=>'left',-padx=>5);
	$frame10->Button(
		-text=>"F:",
		-command=>sub{ 
				$dirtree->chdir("F:/"); 
				if ($curDrive ne "F:") { $dirtree->close($curDrive); }
				$curDrive = "F:";
				$cbroot = "$curDrive/";
			}
		)->pack(-side=>'left',-padx=>5);
	$t10->Entry(-textvariable => \$cbroot)->pack(-side=>'top');
	$dirtree = $t10->Scrolled(
		"DirTree",
		-width => 200,
		-height => 20,
		-scrollbars => "se",
		-directory => "C:/",
		-command => sub { ($cbroot)= @_; }
		)->pack(-side=>'top');
	$t10->Button(-text=>$msg{"cancel"},-command=>sub{if(confirmExit()){$t10->withdraw}})->pack(-side=>'right',-padx=>5);
	$t10->Button(-text=>$msg{"next"}, -command => sub { $t10->withdraw; step11('n'); }) -> pack(-side=>'right', -padx=>5);
	$t10->Button(-text=>$msg{"back"}, -command => sub { $t10->withdraw; step9(); }) -> pack(-side=>'right', -padx=>5);
}

# 確認安裝項目
sub step11 {
	if (Exists($t11)) {
		confirmInstall();
		myFocus($t11);
	} else {
		$t11 = $mw->Toplevel();
		$t11->focus();
		$t11->title($msg{"title11"});
	
		if ($lang eq "en") { $w = 400; }
		else { $w = 300; }
		my $h = 210;
		my $x = $screenX/2 - $w/2;
		my $y = $screenY/2 - $h/2;
		$t11->geometry("${w}x$h+$x+$y");
	
		$t11->Label(-text => $msg{"label11"})->pack();
		$text11 = $t11->Scrolled(
			"Text",
			-scrollbars => "se",
			-height => 10
			)->pack();
		confirmInstall();
		$t11->Button(-text=>$msg{"cancel"},-command=>sub{if(confirmExit()){$t11->withdraw}})->pack(-side=>'right', -padx=>5);
		$t11->Button(-text=>$msg{"start"},-command=>sub{$t11->withdraw; install();})->pack(-side=>'right', -padx=>5);
		$t11->Button(-text=>$msg{"back"},-command=>sub{$t11->withdraw;step10();})->pack(-side=>'right', -padx=>5);
	}
	
}

local $folderPath;
local $fontsDir;
sub install {
	my $i, $vol, $lnkPath;
	mkdir("$cbroot", MODE);
	
	my $reg = "$regRoot/Software/Microsoft/Windows/CurrentVersion/Explorer/Shell Folders/Fonts";
	$fontsDir = $Registry->{$reg};
	print STDERR "Fonts Directory: $fontsDir\n";
	$fontsDir =~ /^(.*)\\Fonts$/;
	$winDir = $1;
	print STDERR "Windows Directory: $winDir\n";
	
	if ($chk_t or $chk_r or $chk_h) {
		createCbFolder();
		# 安裝字型
		copy("/tools/setup/cbdia.ttf", "$fontsDir\\cbdia.ttf");
		copy("/tools/setup/ITUnicod.ttf", "$fontsDir\\ITUnicod.ttf");
		
		# 複製解除安裝程式
		mkdir("$cbroot/setup", MODE);
		copy("/tools/setup/uninst.exe", "$cbroot/setup/uninst.exe");
		copy("/tools/setup/remove.exe", "$cbroot/setup/remove.exe");
		$lnkPath = $folderPath . "\\" . $msg{"uninstall"};
		createShortcut("$cbroot/setup/uninst.exe", $lnkPath, '', "");
		
		# 複製說明檔
		copyDir("/cbeta/help", "$cbroot/help");
		$lnkPath = $folderPath . "\\" . $msg{"help"};
		createShortcut("$cbroot/help/index.htm", $lnkPath, '', "$cbroot/help");
	}
	if ($chk_t) { installT(); }
	if ($chk_r) { installR(); }
	if ($chk_h) { installH(); }
	if ($chk_t or $chk_r or $chk_h) {
		# 複製辭典
		mkdir("$cbroot/htmlhelp", MODE);
		copy("/cbeta/htmlhelp/dfb.chm", "$cbroot/htmlhelp/dfb.chm");
		copy("/cbeta/htmlhelp/combdict.chm", "$cbroot/htmlhelp/combdict.chm");
		
		# 建立辭典捷徑
		$lnkPath = $folderPath . "\\" . $msg{"reference"};
		mkdir($lnkPath, MODE);
		my $wd = "$cbroot/htmlhelp";
		my $path = $lnkPath . "\\" . $msg{"dfb"};
		createShortcut("$cbroot/htmlhelp/dfb.chm", $path, '', $wd);
		$path = $lnkPath . "\\" . $msg{"combdict"};
		createShortcut("$cbroot/htmlhelp/combdict.chm", $path, '', $wd);
		
		# 將 CBETA Root 記錄在 Registry
		$Registry->{"CUser/Software/CBETA/"} = { "" => $cbroot };
	}
	#if ($chk_r and $rtfMojikyo) {
	#	insertDisc2();
	#	copyMojikyo();
	#}
	print STDERR "Installation completed!\n";
}

sub installT {
	my $prog='';
	if ($ptFormat eq 'app') { $prog = "app1"; }
	else { $prog = "/setup/win/normal.bat"; }
	
	my $option = '';
	$option = "-c /setup/win";
	if ($ptFormat eq 'trim') { $option .= ' -s'; }
	$option .= " -e $ptEncoding";
	if (not $ptNormalize) { $option .= ' -z'; } # 不用通用字
	if ($ptMissingChar eq 'm') { $option .= ' -m'; } # 用 M 碼
	
	if ($ptInstall eq 'a') {  # 全部安裝
		for ($i=1; $i<=85; $i++) {
			$vol = "T" . sprintf("%2.2d",$i);
			if (not -e "/cbeta/xml/$vol") { next; }
			system "perl $prog -v $vol -i /cbeta/xml -o $cbroot $option";
		}
	} elsif ($ptInstall eq 't') {  # 只安裝選取的部份
		foreach (@selectedT) {
			if ($_ eq 55) { $_ = 85; }
			else { $_++; }
			my $vol = "T" . sprintf("%2.2d",$_);
			system "perl $prog -v $vol -i /cbeta/xml -o $cbroot $option";
		}
	} else {  # 選經安裝
		my $i = @selectedS;
		foreach (@selectedS) {
			($vol,$n,$temp) = split / /;
			$n =~ /(\d\d\d\d)(\S?)/;
			if ($2 eq '') {
				$c = 'n';
			} else {
				$c = $2;
			}
			#$n = "$c$1";
			#chdir("/cbeta/xml/$vol");
			system "perl $prog -n ${vol}n$n.xml -i /cbeta/xml -o $cbroot $option";
		}
	}
}

sub installR {
	local $option = '';
	if ($rtfTag) { $option = '-t'; }
	if (not $rtfUnicode) { $option .= " -x"; }
	if (not $rtfNormalize) { $option .= " -z"; }
	if (not $rtfMojikyo) { $option .= " -y"; }
	if ($rtfMissingChar eq "m") { $option .= " -m"; }
	mkdir("$cbroot/doc", MODE);
	my $lnkPath = $folderPath . "\\" . $msg{"rtfFormat"};
	mkdir($lnkPath, MODE);
	open O,">$cbroot/doc/index.rtf" or die "open error $cbroot/doc/index.rtf";
	select O;
	rtfIndexHeader();
	if ($rtfInstall eq 'a') {  # 全部安裝
		for ($i=1; $i<=85; $i++) {
			$vol = "T" . sprintf("%2.2d",$i);
			if (not -e "/cbeta/xml/$vol") { next; }
			rtf1vol($vol);
		}
	} else {  # 只安裝選取的部份
		foreach (@selectedR) {
			if ($_ eq 55) { $_ = 85; }
			else { $_++; }
			my $vol = "T" . sprintf("%2.2d",$_);
			rtf1vol($vol);
		}
	}
	print O '{\par }}';
	close O;
	$lnkPath .= "\\" . $msg{"rtfIndex"};
	createShortcut("$cbroot/doc/index.rtf", $lnkPath, '', "$cbroot/doc");
	
	# 安裝字型
	print STDERR "/tools/setup/siddam.ttf => $fontsDir\\siddam.ttf\n";
	copy("/tools/setup/siddam.ttf", "$fontsDir\\siddam.ttf");
	print STDERR "/tools/setup/ITUnicod.ttf => $fontsDir\\ITUnicod.ttf\n";
	copy("/tools/setup/ITUnicod.ttf", "$fontsDir\\ITUnicod.ttf");
	copyDot();
}

sub rtf1vol {
	my $vol = shift;
	print STDERR "rtf1vol $vol\n";
	mkdir("$cbroot/doc/$vol", MODE);
	chdir("/setup/win");
	system "perl/bin/perl x2rtf.pl -v $vol -i /cbeta/xml -o $cbroot $option";
	writeRTFIndex($vol);
}

local $lnkPath;
sub installH {
	local @chms = qw(01AHan 02BenYuan 03BoRuo 04FaHua 05HuaYan 06BaoJi 07NiePan 08DaJi 09JingJi 10MiJiao 11Vinaya 12PiTan 13ZhonGuan 14YogaCara 15LunJi 16PureLand 17Chan 18History 19Misc 20Apoc);
	my $file;
	mkdir("$cbroot/htmlhelp", MODE);
	$lnkPath = $folderPath . "\\" . $msg{"hhFormat"};
	mkdir($lnkPath, MODE);
	copy("/cbeta/htmlhelp/book02.ico", "$cbroot/htmlhelp/book02.ico");
	if ($hhInstall eq "a") {  # 全部安裝
		copy("/cbeta/htmlhelp/books04.ico", "$cbroot/htmlhelp/books04.ico");
		for ($i=1; $i<=20; $i++) {
			hh1bu($i);
		}
		my $path = "$cbroot/htmlhelp/cbeta.chm";
		copy("/cbeta/htmlhelp/cbeta.chm", $path);
		my $icon = "$cbroot/htmlhelp/books04.ico";
		createShortcut($path, "$lnkPath\\# $cbetaFolder", $icon, "$cbroot/htmlhelp");
	} else {
		foreach (@selectedH) {
			hh1bu($_+1);
		}
	}
	copy("/cbeta/htmlhelp/CbetaCit.htm", "$cbroot/htmlhelp/CbetaCit.htm");
	writeCbetaDfb();
	writeCbetaDea();
	setupContextMenu($msg{"contextMenu1"},"CbetaCit.htm");
	setupContextMenu($msg{"contextMenu2"},"CbetaDfb.htm");
	setupContextMenu($msg{"contextMenu3"},"CbetaDea.htm");
}

# 安裝一部 HTML Help 版
sub hh1bu {
	my $bu = shift;
	local @chms = qw(01AHan 02BenYuan 03BoRuo 04FaHua 05HuaYan 06BaoJi 07NiePan 08DaJi 09JingJi 10MiJiao 11Vinaya 12PiTan 13ZhonGuan 14YogaCara 15LunJi 16PureLand 17Chan 18History 19Misc 20Apoc);
	
	my $file = $chms[$bu-1] . ".chm";
	my $path = "$cbroot/htmlhelp/$file";
	print STDERR "/cbeta/htmlhelp/$file => $path\n";
	copy("/cbeta/htmlhelp/$file", $path);
	
	$file = $chms[$bu-1] . ".hhc";
	$path = "$cbroot/htmlhelp/$file";
	copy("/cbeta/htmlhelp/$file", $path);
	
	my $name = $msgParts[$bu-1];
	my $icon = "$cbroot/htmlhelp/book02.ico";
	my $wd = "$cbroot/htmlhelp";
	createShortcut($path, "$lnkPath\\$name", $icon, $wd);
}

# 在 開始功能表 程式集 中建立 CBETA資料夾
sub createCbFolder {
	my $post = "Programs";
	my $reg = "$regRoot/Software/Microsoft/Windows/CurrentVersion/Explorer/Shell Folders/Programs";
	if (Win32::IsWinNT) {
		my $priv = `perl priv.pl`;
		if ($priv eq "2") { # 如果有 Administrator 的權限
			$regRoot = "LMachine";
			$reg = "$regRoot/Software/Microsoft/Windows/CurrentVersion/Explorer/Shell Folders/Common Programs";
		}
	}
	$pFilesDir = $Registry->{$reg};
	$folderPath ="$pFilesDir\\$cbetaFolder"; 
	mkdir($folderPath,MODE);
}

sub createShortcut {
	my ($path, $name, $icon, $wd) = @_;
	my $link = new Win32::Shortcut();
	$link->{'Path'} = $path;
	$link->{'IconLocation'} = $icon;
	$link->{'WorkingDirectory'} = $wd;
	$link->Save("$name.lnk");
}

sub confirmExit {
	my @buttons = ($msg{"continueSetup"},$msg{"exitSetup"});
	my $default_button = $msg{"continueSetup"};
	my $dialog1 = $mw->Dialog(
		-title => $msg{"titleExit"},
		-text => $msg{"textConfirmExit"},
		-bitmap => "question",
		-default_button => 'Yes', 
		-buttons => \@buttons
		);
	my $answer = $dialog1->Show();
	if ($answer eq $buttons[1]) { exit; }
	else { return 0; }
}

sub myFocus {
	my $w = shift;
	$w->deiconify();
	$w->raise();
	$w->focus();
}

# 確認 純文字版 的 安裝選項
sub confirmT {
	$text11->insert("end",$msg{"plainTextFormat"}."\n"); 
	if ($ptInstall eq 'a') { 
		$text11->insert("end", "  " . $msg{"installAll"}."\n");
	} elsif ($ptInstall eq 't') {  # 分冊安裝
		$text11->insert("end", "  " . $msg{"volsSelected"} . ":\n");
		foreach (@selectedT) {
			my $s = $lbt->get($_);
			$text11->insert("end","    $s\n");
		}
	} else { # 選經安裝
		$text11->insert("end", "  " . $msg{"installBySutra"}.":\n");
		foreach (@selectedS) {
			$text11->insert("end","    $_\n");
		}
	}
	
	if ($ptFormat eq "normal") {
		$text11->insert("end", "  " . $msg{"normalFormat"} . "\n");
	} elsif ($ptFormat eq "trim") {
		$text11->insert("end", "  " . $msg{"compactFormat"}."\n");
	} else {
		$text11->insert("end", "  " . $msg{"appFormat"} . "\n");
	}
	
	$text11->insert("end", "  " . $msg{"charEncoding"} . ":$ptEncoding\n");
	
	$fr42 = $fr40->Frame()->pack(-side=>'left');
	$text11->insert("end", "  " . $msg{"QueZiMode"} . ":\n");
	if ($ptNormalize) {
		$text11->insert("end", "    ".$msg{"useNorChar"}."\n"); 
	}
	if ($ptMissingChar eq 'e') {
		$text11->insert("end","    ".$msg{"useZuZiShi"}."\n");
	} else {
		$text11->insert("end","    ".$msg{"useMojikyo"}."\n");
	}
}

# 確認 RTF版 的 安裝選項
sub confirmR {
	$text11->insert("end",$msg{"rtfFormat"}."\n");
	if ($rtfInstall eq 'a') { $text11->insert("end","  ".$msg{"installAll"}."\n"); }
	else {
		$text11->insert("end","  ".$msg{"volsSelected"}.":\n");
		foreach (@selectedR) {
			my $s = $lb7->get($_);
			$text11->insert("end","    $s\n");
		}
	}
	if ($rtfTag) { $text11->insert("end","  ".$msg{"useMarkup"}."\n"); }
}

sub confirmH {
	$text11->insert("end",$msg{"hhFormat"}."\n");
	if ($hhInstall eq 'a') { $text11->insert("end","  ".$msg{"installAll"}."\n"); }
	else {
		$text11->insert("end","  ".$msg{"installByBu"}.":\n");
		foreach (@selectedH) {
			my $s = $lb9->get($_);
			$text11->insert("end","    $s\n");
		}
	}
}

sub confirmInstall {
	$text11->delete('1.0','end');
	if ($chk_t) { confirmT(); }
	if ($chk_r) { confirmR(); }
	if ($chk_h) { confirmH(); }
	$text11->insert("end","\n".$msg{"destPath"}.":$cbroot");
}


# 設定搜尋路徑
sub setInc {
	my $path, @temp;
	# 判斷作業系統
}

sub rtfIndexHeader {
print <<'HEADER';
{\rtf1\ansi\ansicpg950\uc2 \deff0\deflang1033\deflangfe1028{\fonttbl{\f0\froman\fcharset0\fprq2{\*\panose 02020603050405020304}Times New Roman;}
{\f18\froman\fcharset136\fprq2{\*\panose 02020300000000000000}\'b7\'73\'b2\'d3\'a9\'fa\'c5\'e9{\*\falt PMingLiU};}{\f34\froman\fcharset136\fprq2{\*\panose 02020300000000000000}@\'b7\'73\'b2\'d3\'a9\'fa\'c5\'e9;}
{\f299\froman\fcharset238\fprq2 Times New Roman CE;}{\f300\froman\fcharset204\fprq2 Times New Roman Cyr;}{\f302\froman\fcharset161\fprq2 Times New Roman Greek;}{\f303\froman\fcharset162\fprq2 Times New Roman Tur;}
{\f304\froman\fcharset177\fprq2 Times New Roman (Hebrew);}{\f305\froman\fcharset178\fprq2 Times New Roman (Arabic);}{\f306\froman\fcharset186\fprq2 Times New Roman Baltic;}{\f445\froman\fcharset0\fprq2 PMingLiU Western{\*\falt PMingLiU};}
{\f573\froman\fcharset0\fprq2 @\'b7\'73\'b2\'d3\'a9\'fa\'c5\'e9 Western;}}{\colortbl;\red0\green0\blue0;\red0\green0\blue255;\red0\green255\blue255;\red0\green255\blue0;\red255\green0\blue255;\red255\green0\blue0;\red255\green255\blue0;
\red255\green255\blue255;\red0\green0\blue128;\red0\green128\blue128;\red0\green128\blue0;\red128\green0\blue128;\red128\green0\blue0;\red128\green128\blue0;\red128\green128\blue128;\red192\green192\blue192;}{\stylesheet{
\ql \li0\ri0\nowidctlpar\aspalpha\aspnum\faauto\adjustright\rin0\lin0\itap0 \fs24\lang1033\langfe1028\kerning2\loch\f0\hich\af0\dbch\af18\cgrid\langnp1033\langfenp1028 \snext0 Normal;}{\*\cs10 \additive Default Paragraph Font;}{\*\cs15 \additive \ul\cf2 
\sbasedon10 Hyperlink;}}{\info{\title aaa}{\author Zhou Ray}{\operator Zhou Ray}{\creatim\yr2001\mo3\dy16\hr11\min49}{\revtim\yr2001\mo3\dy16\hr11\min50}{\version1}{\edmins1}{\nofpages1}{\nofwords0}{\nofchars0}{\*\company DDM}{\nofcharsws0}{\vern8249}}
\paperw11906\paperh16838\margl1800\margr1800\margt1440\margb1440\gutter0 \deftab480\ftnbj\aenddoc\formshade\horzdoc\dgmargin\dghspace180\dgvspace180\dghorigin1800\dgvorigin1440\dghshow0\dgvshow2\jcompress\lnongrid
\viewkind1\viewscale100\splytwnine\ftnlytwnine\htmautsp\useltbaln\alntblind\lytcalctblwd\lyttblrtgr\lnbrkrule {\upr{\*\fchars 
!),.:\'3b?]\'7d\'a2\'46\'a1\'50\'a1\'56\'a1\'58\'a1\'a6\'a1\'a8\'a1\'45\'a1\'4c\'a1\'4b\'a1\'45\'a1\'ac\'a1\'5a\'a1\'42\'a1\'43\'a1\'72\'a1\'6e\'a1\'76\'a1\'7a\'a1\'6a\'a1\'66\'a1\'aa\'a1\'4a\'a1\'57\'a1\'59\'a1\'5b\'a1\'60\'a1\'64\'a1\'68\'a1\'6c
\'a1\'70\'a1\'74\'a1\'78\'a1\'7c\'a1\'5c\'a1\'4d\'a1\'4e\'a1\'4f\'a1\'51\'a1\'52\'a1\'53\'a1\'54\'a1\'7e\'a1\'a2\'a1\'a4\'a1\'49\'a1\'5e\'a1\'41\'a1\'44\'a1\'47\'a1\'46\'a1\'48\'a1\'55\'a1\'62\'a1\'4e}{\*\ud\uc0{\*\fchars 
!),.:\'3b?]\'7d{\uc2\u162 \'a2F\'a1P\'a1V\'a1X\'a1\'a6\'a1\'a8\u8226 \'a1E\'a1L\'a1K\'a1E\'a1\'ac\'a1Z\'a1B\'a1C\'a1r\'a1n\'a1v\'a1z\'a1j\'a1f\'a1\'aa\'a1J\'a1W\'a1Y\'a1[\'a1`\'a1d\'a1h\'a1l\'a1p\'a1t\'a1x\'a1|\'a1\'5c\'a1M\'a1N\'a1O}
\'a1Q\'a1R\'a1S\'a1T\'a1~\'a1\'a2\'a1\'a4\'a1I\'a1^\'a1A\'a1D\'a1G\'a1F\'a1H\'a1U\'a1b{\uc2\u-156 \'a1N}}}}{\upr{\*\lchars 
([\'7b\'a2\'47\'a2\'44\'a1\'a5\'a1\'a7\'a1\'ab\'a1\'71\'a1\'6d\'a1\'75\'a1\'79\'a1\'69\'a1\'65\'a1\'a9\'a1\'5f\'a1\'63\'a1\'67\'a1\'6b\'a1\'6f\'a1\'73\'a1\'77\'a1\'7b\'a1\'7d\'a1\'a1\'a1\'a3\'a1\'5d\'a1\'61}{\*\ud\uc0{\*\lchars 
([\'7b{\uc2\u163 \'a2G\u165 \'a2D\'a1\'a5\'a1\'a7\'a1\'ab\'a1q\'a1m\'a1u\'a1y\'a1i\'a1e\'a1\'a9\'a1_\'a1c\'a1g\'a1k\'a1o\'a1s\'a1w\'a1\'7b\'a1\'7d\'a1\'a1\'a1\'a3\'a1]\'a1a}}}}\fet0\sectd 
\linex0\headery851\footery992\colsx425\endnhere\sectlinegrid360\sectspecifyl {\*\pnseclvl1\pnucrm\pnstart1\pnindent720\pnhang{\pntxta \dbch .}}{\*\pnseclvl2\pnucltr\pnstart1\pnindent720\pnhang{\pntxta \dbch .}}{\*\pnseclvl3
\pndec\pnstart1\pnindent720\pnhang{\pntxta \dbch .}}{\*\pnseclvl4\pnlcltr\pnstart1\pnindent720\pnhang{\pntxta \dbch )}}{\*\pnseclvl5\pndec\pnstart1\pnindent720\pnhang{\pntxtb \dbch (}{\pntxta \dbch )}}{\*\pnseclvl6\pnlcltr\pnstart1\pnindent720\pnhang
{\pntxtb \dbch (}{\pntxta \dbch )}}{\*\pnseclvl7\pnlcrm\pnstart1\pnindent720\pnhang{\pntxtb \dbch (}{\pntxta \dbch )}}{\*\pnseclvl8\pnlcltr\pnstart1\pnindent720\pnhang{\pntxtb \dbch (}{\pntxta \dbch )}}{\*\pnseclvl9\pnlcrm\pnstart1\pnindent720\pnhang
{\pntxtb \dbch (}{\pntxta \dbch )}}\pard\plain \ql \li0\ri0\nowidctlpar\aspalpha\aspnum\faauto\adjustright\rin0\lin0\itap0 \fs24\lang1033\langfe1028\kerning2\loch\af0\hich\af0\dbch\af18\cgrid\langnp1033\langfenp1028 
HEADER
}

sub writeRTFIndex {
	local $vol = shift;
	my $dir = "/cbeta/xml/$vol";
	if (not -e $dir) { next; }
	opendir INDIR, $dir or die "opendir $dir error: $dir";
	my @allfiles = grep(/\.xml$/i, readdir(INDIR));
	closedir INDIR;

	select O;
	foreach $file (sort @allfiles)	{
		do1file("$dir/$file");
	}
}

sub do1file {
	my $file = shift;
	print STDERR "$file\n";
	open I, "<$file" or die "open error";
	while (<I>) {
		if (/title.*No. (\d+)([A-Za-z])? (.*)<\/title/) {
			$num = sprintf("%4.4d",$1) . $2;
			$name = $3;
			last;
		}
	}
	close I;
	while ($name =~ /&(CB\d{4});/) {
		my $cb = $1;
		$file =~ s/\.xml$/\.ent/;
		open I, "<$file" or die "open error";
		while (<I>) {
			if (/$cb/) {
				my $temp;
				if (/uni=\'(.*?)\'/) {
					$temp = '{\uc1\u' . hex($1) . "\\'3f}";
				} elsif (/nor=\'(.*?)\'/) {
					$temp = $1;
				} else {
					/des=\'(.*?)\'/;
					$temp = $1;
				}
				$name =~ s/&$cb;/$temp/g;
				last;
			}
		}
		close I;
	}
	print "$vol, n$num ";
	print '{\field{\*\fldinst {\hich\af0\dbch\af18\loch\f0 \hich\af0\dbch\af18\loch\f0 HYPERLINK "';
	print $vol,"\\" x 4,"${vol}n$num.rtf",'" \hich\af0\dbch\af18\loch\f0 }}';
	print '{\fldrslt {\cs15\ul\cf2 \loch\af0\hich\af0\dbch\f18 ';
	print $name,"}}}",'{\par }',"\n";
}

#----------------------------------------------------------------------
sub copyDir {
	my ($dir1, $dir2) = @_;
	opendir THISDIR, $dir1 or die "opendir error: $dir1";
	my @allfiles = grep !/^\.\.?$/, readdir THISDIR;
	closedir THISDIR;
  
	mkdir($dir2,MODE);
	my $file;
	foreach $file (@allfiles) {
		my $path1 = $dir1 . "/" . $file;
		my $path2 = $dir2 . "/" . $file;
		if (-d $path1) { copyDir($path1, $path2); }
		else { copy($path1, $path2); }
	}
}

# 設定 HTML Help 版的右鍵功能表
sub setupContextMenu {
	my ($name, $file) = @_;
	
	my $reg = "CUser/Software/Microsoft/Internet Explorer/MenuExt/";
	$Registry->{$reg} = {};
	$reg .= "$name/";
	$Registry->{$reg} = { 
		"" => "$cbroot\\htmlhelp\\$file" , 
		"Contexts" => [pack("H8","10"),"REG_BINARY"]
		};
	
	$reg = "LMachine/Software/Microsoft/Internet Explorer/MenuExt/";
	$Registry->{$reg} = {};
	$reg .= "$name/";
	$Registry->{$reg} = { 
		"" => "$cbroot\\htmlhelp\\$file" , 
		"Contexts" => [pack("H8","10"),"REG_BINARY"]
		};
}


sub writeCbetaDfb {
	open O, ">$cbroot/htmlhelp/CbetaDfb.htm";
print O <<'EOF';
<HTML>
<SCRIPT LANGUAGE="JavaScript" defer>

var parentwin = external.menuArguments;
var doc = parentwin.document;
var sel = doc.selection;
var rng = sel.createRange();
var str = new String(rng.text);
while (str.substr(str.length-1)=="　") {
  str = str.substr(0,str.length-1);
}
var pattern = /MSIE 5\.5/;
if (navigator.appVersion.match(pattern)) {
EOF

	print O 'doc.location="mk:@MSITStore:';
	my $s = $cbroot;
	$s =~ s#\\#\\\\#g;
	$s =~ s#/#\\\\#g;
	print O $s;
	print O '\\\\htmlhelp\\\\dfb.chm::/" + escape(str) +".htm"',"\n";

	print O <<'EOF';
} else {
	doc.location="dfb.chm::/"+ escape(str) +".htm";
}

</SCRIPT>
</HTML>
EOF
	close O;
}

sub writeCbetaDea {
	open O, ">$cbroot/htmlhelp/CbetaDea.htm";
	select O;
	print <<'EOF';
<HTML>
<SCRIPT LANGUAGE="JavaScript" defer>
/*
  Check Dictionary of East Asia Buddhist Terms
  Modified by Ray at CBETA 1999/12/2 04:44PM
*/
var parentwin = external.menuArguments;
var doc = parentwin.document;
var sel = doc.selection;
var rng = sel.createRange();
var str = new String(rng.text);
while (str.substr(str.length-1)=="　") {
  str = str.substr(0,str.length-1);
}
var encstr = escape(str);
var re = /%u/g;
encstr = encstr.replace(/%u/,  "b");
basstr = encstr.substr(0,5);
encstr = encstr.replace(/%u/g,  "-");
EOF

	print 'doc.location="mk:@MSITStore:';
	my $s = $cbroot;
	$s =~ s#\\#\\\\#g;
	$s =~ s#/#\\\\#g;
	print $s;
	print '\\\\htmlhelp\\\\combdict.chm::/dicts/deabt/data/" + basstr + ".htm#" + encstr;',"\n";
	print "</SCRIPT>\n";
	print "</HTML>";
	close O;
}

sub insertDisc2 {
	my @buttons = ($msg{"continueSetup"},$msg{"exitSetup"});
	my $default_button = $msg{"continueSetup"};
	my $dialog1 = $mw->Dialog(
		-title => $msg{"insertDisc2"},
		-text => $msg{"insertDisc2"},
		-bitmap => "question",
		-default_button => 'Yes', 
		-buttons => \@buttons
		);
	my $answer = $dialog1->Show();
	if ($answer eq $buttons[1]) { exit; }
	else { return 0; }
}

#----------------------------------------------------------------------
sub copyMojikyo
{
	my $dir1 = "/mojikyo";
	my $dir2 = $fontsDir;
	opendir THISDIR, $dir1 or die "opendir error: $dir1";
	my @allfiles = grep /\.ttf$/i, readdir THISDIR;
	closedir THISDIR;
  
	my $file;
	foreach $file (@allfiles) {
		my $path1 = $dir1 . "/" . $file;
		my $path2 = $dir2 . "/" . $file;
		if (not -e $path2 or (-M $path1) < (-M $path2)) { # 只覆蓋舊檔
			print STDERR "Copy $path1 => $path2\n";
			copy($path1, $path2);
		}
	}
}

sub copyDot {
	# 取得 word 97 目錄
	my $reg = $Registry->{"CUser/Software/Microsoft/Office/8.0/Common/FileNew/LocalTemplates"};
	my $dir = $reg->{""};
	if ($dir ne '') {
		if ($lang eq 'tc') {
			print STDERR "/cbeta/doc/cbeta8c.dot => $dir\\cbeta.dot\n";
			copy("/cbeta/doc/cbeta8c.dot","$dir/cbeta.dot");
		} else {
			print STDERR "/cbeta/doc/cbeta8e.dot => $dir\\cbeta.dot\n";
			copy("/cbeta/doc/cbeta8e.dot","$dir/cbeta.dot");
		}
	}
	
	# 取得 word 2000 目錄
	$reg = $Registry->{"CUser/Software/Microsoft/Office/9.0/Common/General/"};
	$dir = $reg->{"UserTemplates"};
	if ($dir eq '') {
		if ($reg->{"ApplicationData"} ne '' and $reg->{"Templates"} ne '') {
			$dir = $winDir . "\\" . $reg->{"ApplicationData"} . "\\Microsoft\\" . $reg->{"Templates"};
		}
	}
	if ($dir ne '') {
		if ($lang eq 'tc') {
			print STDERR "/cbeta/doc/cbeta9c.dot => $dir\\cbeta.dot\n";
			copy("/cbeta/doc/cbeta9c.dot","$dir/cbeta.dot");
		} else {
			print STDERR "/cbeta/doc/cbeta9e.dot => $dir\\cbeta.dot\n";
			copy("/cbeta/doc/cbeta9e.dot","$dir/cbeta.dot");
		}
	}
}