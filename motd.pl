#!/usr/bin/perl -w

use strict;
use Sys::Hostname;
use IO::Socket;

sub uptime {
  open FILE, "< /proc/uptime" or die return ("Cannot open /proc/uptime: $!");
  my($uptime, undef)=split(/ /, <FILE>);
  close FILE;
  return($uptime);
}

sub loadavg {
  open FILE, "< /proc/loadavg" or die return ("Cannot open /proc/loadavg: $!");
  my(@loadavg)=split(/ /, <FILE>);
  close FILE;
  return(@loadavg);
}

sub convert_time { 
  my $time = shift; 
  my $days = int($time / 86400); 
  $time -= ($days * 86400); 
  my $hours = int($time / 3600); 
  $time -= ($hours * 3600); 
  my $minutes = int($time / 60); 
  my $seconds = $time % 60; 
  
  $days = $days < 1 ? '' : $days .'d '; 
  $hours = $hours < 1 ? '' : $hours .'h '; 
  $minutes = $minutes < 1 ? '' : $minutes . 'm '; 
  $time = $days . $hours . $minutes . $seconds . 's'; 
  return $time; 
}

sub figlet {
  system("figlet -c -w 80 -f big $_[0]");
}

sub head {
  print "  ____________________________________________________________________________ \n";
  $~ = 'HEAD';
  write;
  print "||____________________________________________________________________________|\n";
  print "||                                                                            |\n";
}

sub body {
  $~ = 'BODY';
  write;
}

sub foot {
  print "\\\\____________________________________________________________________________/\n";
}

sub main {
  format HEAD =
@<<@|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||@>
  "//", $_[0], "\\"
.

  format BODY =
@<<@|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||@>
  "||", $_[0].": ".$_[1] , "|"
.

  my($hostname)=hostname;
  figlet($hostname);

  # SYSTEM

  my($addr)=inet_ntoa((gethostbyname($hostname))[4]);
  my($rawmem)=`free | grep Mem:`;
  my(@ar)=split(/ +/,$rawmem);
  my($totalmem)=int($ar[1]/1024)."MB";
  my($usedmem)=int(($ar[2]-$ar[5]-$ar[6])/1024)."MB";
  my(@loadavg)=&loadavg();
  my($users)=(int(`w | wc -l`)-2);

  &head("SYSTEM");
  &body("Hostname", $hostname);
  &body("IP", $addr);
  &body("Kernel", `uname -r`);
  &body("Uptime", convert_time(uptime()));
  &body("Used memory", $usedmem." / ".$totalmem);
  &body("Load", $loadavg[0]." ".$loadavg[1]." ".$loadavg[2]);
  &body("Users", $users);
  &foot();

}

main();
