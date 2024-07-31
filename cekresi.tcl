bind pub - .cekresi pub:cekresi
set apicekresi "1234567890ABCDEFGHIJKLMNOPQRSTUVWQYZ" ; # https://api.binderbyte.com
proc pub:cekresi {n u h c t} {
 set t [stripcodes bcruag $t]; set kurir [string tolower [lindex $t 0]]; set noresi [lindex $t 1]
 if {$t == ""} {
  putnow "privmsg $c :.cekresi <code.kurir> <no.resi> \0034»\003 status pengiriman";
  putnow "privmsg $c :.cekresi all/kurir \0034»\003 jasa kurir yang tersedia";
  putnow "privmsg $c :.cekresi tarif/harga <code.kurir> <kota.asal> <kota.tujuan> <berat/kg> \0034»\003 cek tarif";
  return
 }
 if {$kurir == "all" || $kurir == "kurir"} {pub:kurir $n $c $t; return}
 if {$kurir == "tarif" || $kurir == "harga"} {pub:cektarif $n $c $t; return}
 catch {exec curl --connect-timeout 5 -X GET https://api.binderbyte.com/v1/track?api_key=$::apicekresi&courier=$kurir&awb=$noresi} cekresidata; set response [json::json2dict $cekresidata]
 regexp -all -nocase {\{\"status\"} $cekresidata "" status; if {![info exists status]} {putnow "privmsg $c :\0034ERROR:\003 tidak tersedia"; return}
 if {[dict get $response status] != "200"} {putnow "privmsg $c :\0034ERROR:\003 [dict get $response message]"; return 0}
 set data [dict get $response data summary]; foreach inforesi {awb courier service status date desc amount weight} {set $inforesi [dict get $data $inforesi]}
 set detail [dict get $response data detail]; foreach detailresi {origin destination shipper receiver} {set $detailresi [dict get $detail $detailresi]}
 set history [dict get $response data history]; foreach line $history {set date [dict get $line date]; set date [clock scan $date -format {%Y-%m-%d %H:%M:%S} -timezone :UTC]
 if {$kurir == "jnt" || $kurir == "sicepat" || $kurir == "anteraja"} {set date [clock format $date -format {%d-%b-%Y %H:%M} -timezone :UTC]} else {set date [clock format $date -format {%d-%b-%Y %H:%M} -timezone :Asia/Jakarta]}; set descs [dict get $line desc] ; set loca [dict get $line location] ; set item "\n$date \0034-\003 $descs \0034-\003 $loca" ; append result $item}
 putnow "privmsg $c :\037CekResi:\037 \00359$awb\003 \0034»»\003 $courier \0034-\003 $service \0034-\003 $status \0034-\003 $desc \0034-\003 $amount \0034-\003 $weight \0034-\003 $origin \0034-\003 $destination \0034-\003 $shipper \0034-\003 $receiver"
 foreach output [split $result "\n"] {putnow "privmsg $c :$output"}
}
proc pub:kurir {n c t} {
 if {[catch {set kurirpage [http::geturl "https://api.binderbyte.com/v1/list_courier?api_key=$::apicekresi" -timeout 30000]} error]} {putnow "privmsg $c :\0034ERROR:\003 $error" ; return}
 set kurirdata [http::data $kurirpage] ; set response [json::json2dict $kurirdata] ; http::cleanup $kurirpage
 foreach line $response {set code [dict get $line code] ; set descr [dict get $line description] ; set item "\n$descr \0034»»\003 $code" ; append result $item}
 foreach output [split $result "\n"] {putnow "privmsg $c :$output"}
}
proc pub:cektarif {n c t} {
 set t [stripcodes bcruag $t]; set kurir [lindex $t 1]; set ori [lindex $t 2]; set desti [lindex $t 3]; set berat [lindex $t 4];
 if {$desti == ""} {putnow "privmsg $c :.cekresi tarif <code.kurir> <kota.asal> <kota.tujuan> <berat/kg>"; return}
 if {$berat != ""} {
  if {![regexp {^[0-9]} $berat]} {putnow "privmsg $c :\0034ERROR:\003 format salah. Contoh: .cekresi tarif jne jakarta surabaya 5"; return}
  if {[regexp {[,]} $berat]} {putnow "privmsg $c :\0034ERROR:\003 format salah. Contoh: .cekresi tarif jne jakarta surabaya 5.5"; return}
 } else {set berat "1"}
 catch {exec curl --connect-timeout 5 -X GET https://api.binderbyte.com/v1/cost?api_key=$::apicekresi&courier=$kurir&origin=$ori&destination=$desti&weight=$berat} cektarifdata; set response [json::json2dict $cektarifdata]
 regexp -all -nocase {\{\"status\"} $cektarifdata "" status; if {![info exists status]} {putnow "privmsg $c :\0034ERROR:\003 tidak tersedia"; return}
 if {[dict get $response status] != "200"} {putnow "privmsg $c :\0034ERROR:\003 [dict get $response message]"; return 0}
 set data [dict get $response data summary];
 foreach datapaket {origin destination weight} {set $datapaket [dict get $data $datapaket]}
 set cost [dict get $response data costs];
 foreach line $cost {
  if {[dict exists $line name]} {set name [dict get $line name]} else {set name [dict get $line courier]}; set service [dict get $line service]; set type [dict get $line type]; set harga [dict get $line price]; set estimasi [dict get $line estimated];
  set item "\n$name \0034-\003 $service \0034-\003 $type \0034-\003 Rp [commify $harga] \0034-\003 $estimasi"; append result $item
 }
 putnow "privmsg $c :\00353\037CekTarif:\037\003 \0034[capitalize $origin]\003 \002\u21d2\002 \00359[capitalize $destination]\003 \0034-\003 \037Berat:\037 $weight"
 foreach output [split $result "\n"] {putnow "privmsg $c :$output"}
}
putlog "+++ CekResi TCL Loaded..."
