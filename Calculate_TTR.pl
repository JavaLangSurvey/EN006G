#!/usr/bin/perl

use DBI;

$|=1;
my $db=DBI->connect("DBI:mysql:database=sbc;host=localhost","root","");

my ($wordcount,@ttr);

print "SBC,Token Count,Type Count,TTR\n";
for (my $sbcid=1; $sbcid<=60; $sbcid++) {
  my %words={};
  ($tokencount,$typecount)=(0,0);
  my $st=$db->prepare("select * from dialogs where sbcid=$sbcid");
  $st->execute();
  while (my $rs=$st->fetchrow_hashref()) {
    my $ln=$rs->{'line'};
    $ln=~s/[^a-zA-Z ]//g;
    $ln=$1 if ($ln=~/^\s+(.+)$/);
    $ln=$1 if ($ln=~/^(.+)\s+$/);
    next if (length($ln)<1);
    $ln=lc($ln);
    my @words=split(/ /,$ln);
    my $wc=0;
    foreach $w (@words) {
      $words{$w}++; $tokencount++; $wordcount++; $wc++;
    }
    my $st2=$db->prepare("update dialogs set wordcount=$wc where dlgid=$rs->{'dlgid'}");
    $st2->execute(); $st2->finish();
  }
  $st->finish();
  $db->disconnect();
  foreach $w (keys %words) {
    $typecount++;
    #print "$w freq: $words{$w}\n";
  }
  printf ("SBC%3.3d,",$sbcid);
  print "$tokencount,$typecount,";
  print $typecount/$tokencount."\n";
  @ttr[$sbcid]=$typecount/$tokencount;
}
my $totalttr=0;
for (my $i=1; $i<=60; $i++) {
  $totalttr+=@ttr[$i];
  $totalttr/=2;
}
#print "Word count: $wordcount\n";
#print "Average TTR: $totalttr\n";
