bind pub - .cekresi pub:cekresi
proc pub:cekresi {n u h c t} {
 set t [stripcodes bcruag $t] ; set kurir [lindex $t 0] ; set noresi [lindex $t 1]
 if {$t == ""} {putnow "notice $n :Usage: .cekresi <code.kurir> <no.resi>" ; putnow "notice $n :Usage: .cekresi kurir \0034=\003 jasa kurir yang tersedia" ; return}
 if {$t == "kurir"} {pub:kurir $n $u $h $c $t ; return}
 set apikey "1234567890ABCDEFGHIJKLMNOPQRSTUVWQYZ" ; # https://api.binderbyte.com
 if {[catch {set cekresipage [http::geturl "https://api.binderbyte.com/v1/track?api_key=$apikey&courier=$kurir&awb=$noresi" -timeout 30000]} error]} {putnow "privmsg $c :$error" ; return}
 set response [::json::json2dict [http::data $cekresipage]] ; http::cleanup $cekresipage
 if {[dict get $response message] == "Parameters `courier` and `awb` is required"} {putnow "privmsg $c :Usage: .cekresi <code.kurir> <no.resi>" ; return 0}
 if {[dict get $response status] == "400"} {putnow "privmsg $c :\([dict get $response status]\) [dict get $response message]" ; return 0}
 set data [dict get $response data summary] ; foreach inforesi {awb courier service status date desc amount weight} {set $inforesi [dict get $data $inforesi]}
 set detail [dict get $response data detail] ; foreach detailresi {origin destination shipper receiver} {set $detailresi [dict get $detail $detailresi]}
 set history [dict get $response data history] ; foreach line $history {set date [dict get $line date] ; set date [clock scan $date -format {%Y-%m-%d %H:%M:%S}] ; set date [clock format $date -format {%d %b %Y - %H:%M:%S}] ; set descs [dict get $line desc] ; set loca [dict get $line location] ; set item "\n$date \0034-\003 $descs \0034-\003 $loca" ; append result $item}
 putnow "privmsg $c :\037CekResi:\037 \00359$awb\003 \0034»»\003 $courier \0034-\003 $service \0034-\003 $status \0034-\003 $desc \0034-\003 $amount \0034-\003 $weight \0034-\003 $origin \0034-\003 $destination \0034-\003 $shipper \0034-\003 $receiver"
 foreach output [split $result "\n"] {putnow "privmsg $c :$output"}
}
proc pub:kurir {n u h c t} {
 set apikey "1234567890ABCDEFGHIJKLMNOPQRSTUVWQYZ" ; # https://api.binderbyte.com
 if {[catch {set kurirpage [http::geturl "https://api.binderbyte.com/v1/list_courier?api_key=$apikey" -timeout 30000]} error]} {putnow "privmsg $c :$error" ; return}
 set response [::json::json2dict [http::data $kurirpage]] ; http::cleanup $kurirpage
 foreach line $response {set code [dict get $line code] ; set descr [dict get $line description] ; set item "\n$descr \0034»»\003 $code" ; append result $item}
 foreach output [split $result "\n"] {putnow "notice $n :$output"}
}
putlog "+++ CekResi TCL Loaded..."
