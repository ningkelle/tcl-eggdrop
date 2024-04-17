bind pub - .kurs pub:currency
proc pub:currency {n u h c t} {
 set t [string tolower [stripcodes bcruag $t]]; if {$t == ""} {putnow "privmsg $c :.kurs <mata-uang> <mata-uang-target> <jumlah> \0034-\003 .kurs kwd idr 5"; return}
 set from [lindex [split $t] 0]; set to [lindex [split $t] 1]; set value [lindex [split $t] 2]; set kursdef "idr"
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
 catch {exec curl --connect-timeout 5 -X POST https://www.floatrates.com/daily/$to.json} kursdata; set kursjson [json::json2dict $kursdata]
 regexp -all -nocase {\{\".*?(.*?)\":\"} $kursdata "" code; if {![info exists code]} {putnow "privmsg $c :\0034ERROR:\003 \002[string toupper $to]\002 tidak tersedia"; return}
 if {![dict exists $kursjson $from]} {putnow "privmsg $c :\0034ERROR:\003 \002[string toupper $from]\002 tidak tersedia"; return} else {set kursfrom [dict get $kursjson $from inverseRate]}
 set for_one [expr {round($kursfrom)}]; set hasil [expr $for_one*$value]
 if {$value == "1"} {putnow "privmsg $c :$value [string toupper $from] \0034=\003 $hasil [string toupper $to]"} else {
  putnow "privmsg $c :$value [string toupper $from] \0034=\003 $hasil [string toupper $to] (1 [string toupper $from] \0034=\003 $for_one [string toupper $to])"
 }
}
putlog "+++ KURS TCL Loaded..."
