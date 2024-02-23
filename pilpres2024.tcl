bind pub - .pilpres pub:pilpres
proc pub:pilpres {n u h c t} {
 if {[catch {set pilprespage [http::geturl https://sirekap-obj-data.kpu.go.id/pemilu/hhcw/ppwp.json -timeout 3000]} error]} {putnow "privmsg $c :$error"; return}
 set pilpresdata [http::data $pilprespage]; set response [json::json2dict $pilpresdata]; http::cleanup $pilprespage
 foreach var {ts chart progres} {set $var [dict get $response $var]}
 set ts [clock scan $ts -format {%Y-%m-%d %H:%M:%S}]; set tms [clock format $ts -format {%d-%b-%Y %H:%M}]
 set pas01 [dict get $chart 100025]; set pas02 [dict get $chart 100026]; set pas03 [dict get $chart 100027]
 set persenprogres [dict get $chart persen]; set tps [dict get $progres total]; set tpsprogres [dict get $progres progres]; set totalsuara [expr $pas01+$pas02+$pas03]
 set persen01 [expr {double(round(10000*$pas01)/$totalsuara)/100}]; set persen02 [expr {double(round(10000*$pas02)/$totalsuara)/100}]; set persen03 [expr {double(round(10000*$pas03)/$totalsuara)/100}]
 putnow "privmsg $c :\037Progres\037 \0034»\003\002 $tpsprogres \002dari\002\00353 $tps \003\002TPS \002\($persenprogres%\)\002"
 putnow "privmsg $c :\037PASLON 01\037 \0034»\003 $pas01 \002\($persen01%)\002"
 putnow "privmsg $c :\037PASLON 02\037 \0034»\003 $pas02 \002\($persen02%)\002"
 putnow "privmsg $c :\037PASLON 03\037 \0034»\003 $pas03 \002\($persen03%)\002"
 putnow "privmsg $c :\037Updated\037 \0034»\003 $tms"
}
putlog "+++ Pilpres 2024 TCL Loaded..."
