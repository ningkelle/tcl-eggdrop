bind pub - .kurs pub:exchange
proc pub:exchange {n u h c t} {
 set t [string toupper [stripcodes bcruag $t]]; if {$t == ""} {putnow "privmsg $c :.kurs <mata-uang> <mata-uang-target> <jumlah> \0034-\003 .kurs kwd idr 5"; return}
 set from [lindex [split $t] 0]; set to [lindex [split $t] 1]; set value [lindex [split $t] 2]; set kursdef "IDR"
 if {$value != ""} {
  if {![regexp {^[0-9]} $value]} {putnow "privmsg $c :\0034ERROR:\003 format salah. Contoh: .kurs kwd idr 5"; return}
  if {[regexp {[,]} $value]} {putnow "privmsg $c :\0034ERROR:\003 format salah. Contoh: .kurs kwd idr 5.21"; return}
 } else {set value 1}
 if {[regexp {^[0-9]} $to]} {
  set value $to; set kurs ""; if {$kurs == ""} {set to $kursdef} else {set to $kurs}
 } elseif {$to == ""} {
  set kurs ""; if {$kurs == ""} {set to $kursdef} else {set to $kurs}
 }
 if {$value == "0"} {putnow "privmsg $c :Apa kamu tidak punya uang?"; return}
 if {[regexp {[,]} $to] || [regexp {[,]} $value]} {putnow "privmsg $c :\0034ERROR:\003 format salah. Contoh: .kurs kwd idr 5.21"; return}
 if {[regexp {^[0-9]} $from]} {putnow "privmsg $c :\0034ERROR:\003 format salah. Contoh: .kurs kwd idr 5"; return}
 if {[string equal -nocase $to $from]} {putnow "privmsg $c :\0034ERROR:\003 format salah. Contoh: .kurs kwd idr 5"; return}
 set apikey "1234567890ABCDEFGHIJKLMNOPQRSTUVWQYZ"; # apikey : https://apilayer.com/marketplace/fixer-api
 catch {exec curl --connect-timeout 5 -X GET https://api.apilayer.com/fixer/latest?base=$from&symbols=$to -H "apikey: $apikey"} curdata; set curson [json::json2dict $curdata]
 if {[dict exists $curson error type]} {
  set error [dict get $curson error type]
  if {$error == "invalid_base_currency"} {
   putnow "privmsg $c :\0034ERROR:\003 \002$from\002 tidak tersedia"; return
  } elseif {$error == "invalid_currency_codes"} {
   putnow "privmsg $c :\0034ERROR:\003 \002$to\002 tidak tersedia"; return
  } else {putnow "privmsg $c :\0034ERROR:\003 $error"; return}
 }
 set curto [dict get $curson rates $to]; set result [expr $curto/$curfrom]; set for_one [expr round($curto/$curfrom)]; set hasil [expr {round($result*$value)}]
 if {$value == "1"} {putnow "privmsg $c :[commify $value] $from \0034=\003 [commify $for_one] $to"} else {
  putnow "privmsg $c :[commify $value] $from \0034=\003 [commify $hasil] $to (1 $from \0034=\003 [commify $for_one] $to)"
 }
}
putlog "+++ KURS TCL Loaded..."
