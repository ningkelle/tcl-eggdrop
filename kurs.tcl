bind pub - .kurs pub:exchange
proc pub:exchange {n u h c t} {
 set t [string toupper [stripcodes bcruag $t]]; if {$t == ""} {putnow "privmsg $c :.kurs <mata-uang> <mata-uang-target> <jumlah> \0034-\003 .kurs kwd idr 5"; return}
 set from [lindex [split $t] 0]; set to [lindex [split $t] 1]; set value [lindex [split $t] 2]; set kursdef "IDR"
 if {[regexp {^[0-9]} $to]} {
  set value $to; set kurs ""; if {$kurs == ""} {set to $kursdef} else {set to $kurs}
 } elseif {$to == ""} {
  set kurs ""; if {$kurs == ""} {set to $kursdef} else {set to $kurs}
 }
 if {$value != ""} {
  if {![regexp {^[0-9]} $value]} {putnow "privmsg $c :\0034ERROR:\003 format salah. Contoh: .kurs kwd idr 5"; return}
  if {[regexp {[,]} $value]} {putnow "privmsg $c :\0034ERROR:\003 format salah. Contoh: .kurs kwd idr 5.21"; return}
 } else {set value 1}
 if {$value == "0"} {putnow "privmsg $c :Apa kamu tidak punya uang?"; return}
 if {[regexp {^[0-9]} $from]} {putnow "privmsg $c :\0034ERROR:\003 format salah. Contoh: .kurs kwd idr 5"; return}
 if {[string equal -nocase $to $from]} {putnow "privmsg $c :\0034ERROR:\003 format salah. Contoh: .kurs kwd idr 5"; return}
 set apikey "1234567890ABCDEFGHIJKLMNOPQRSTUVWQYZ"; # apikey : www.fixer.io
 catch {exec curl --connect-timeout 5 -X POST http://data.fixer.io/api/latest?access_key=$apikey&format=1} curdata; set curson [json::json2dict $curdata]
 if {![dict exists $curson rates $to]} {putnow "privmsg $c :\0034ERROR:\003 \002$to\002 tidak tersedia"; return} else {set curto [dict get $curson rates $to]}
 if {![dict exists $curson rates $from]} {putnow "privmsg $c :\0034ERROR:\003 \002$from\002 tidak tersedia"; return} {set curfrom [dict get $curson rates $from]}
 set for_one [expr {round($curto/$curfrom)}]; set hasil [expr $for_one*$value]
 if {$value == "1"} {putnow "privmsg $c :$value $from \0034=\003 $hasil $to"} else {
  putnow "privmsg $c :$value $from \0034=\003 $hasil $to (1 $from \0034=\003 $for_one $to)"
 }
}
putlog "+++ KURS TCL Loaded..."
