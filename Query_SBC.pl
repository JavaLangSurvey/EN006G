#!/usr/bin/perl

use DBI;

$|=1;
my $db=DBI->connect("DBI:mysql:database=sbc;host=localhost","root","");
my $st=$db->prepare("
select * from dialogs,sbc,speakers where (line like '%fuck%'
                                       or line like '%shit%'
                                      and line not like '%dipshit%'
                                      and line not like '%bullshit%'
                                       or line like '%damn%'
                                      and line not like '%damnation%'
                                      and line not like '%damndest%') and speakers.speakerid=dialogs.speakerid
                                                                      and sbc.sbcid=dialogs.sbcid
and speakers.gender='f' and sbc.speakers!='mix'
");
$st->execute();
my ($cnt,%speakers)=(0,{});
while (my $rs=$st->fetchrow_hashref()) {
  next if ($speakers{$rs->{'speakerid'}});
  print "$rs->{'line'}\n";
  $speakers{$rs->{'speakerid'}}="DONE";
  $cnt++;
}
$st->finish();
$db->disconnect();
print "\n$cnt result(s)\n\n";
