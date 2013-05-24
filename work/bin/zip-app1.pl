$p1 = 'c:\\release\\app1\\';
$p2 = 'c:\\cbeta\\cbeta\\app\\';
for ($i=1; $i<=32; $i++) {
  $s = sprintf("%2.2d", $i);
  $command = "pkzip ${p2}T$s.zip ${p1}T$s\\*.txt";
  system $command;
}
#system "j:";
