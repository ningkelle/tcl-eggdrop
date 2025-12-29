setudef flag chanlimit; # .chanset #channel +chanlimit
bind cron - "* * * * *" chanlimit
proc chanlimit {1 2 3 4 5} {
 foreach c [channels] {
  if {[channel get $c chanlimit] == 1 && [botisop $c] == 1} {
   set newlimit [expr [llength [chanlist $c]] + 5]
   set currentlimit [currentlimit $c]
   if {$currentlimit < [expr $newlimit - 1] || $currentlimit > [expr $newlimit + 1]} {putquick "mode $c +l $newlimit"}
  }
 }
}
proc currentlimit {c} {
 set currentmodes [getchanmode $c]
 if {[string match "*l*" [lindex $currentmodes 0]]} {return [lindex $currentmodes end]}
 return 0
}
putlog "ChanLimit TCL Loaded..."
