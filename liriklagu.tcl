bind pub - .lirik pub:lirik
proc pub:lirik {n u h c t} {
 set t [stripcodes bcruag $t]; if {$t == ""} {putnow "privmsg $c :.lirik <judul lagu>"; return}; regsub -all {\s+} $t "%20" text
 catch {exec curl -X GET --connect-timeout 5 --max-time 60 --retry 5 --retry-delay 2 --retry-max-time 30 https://lyrics.lewdhutao.my.eu.org/v2/youtube/lyrics?title=$text 2>/dev/null} lirikdata;
 set lirikjson [json::json2dict $lirikdata]; set response [dict get $lirikjson data];
 if {[dict exists $response respone]} {set message [dict get $response message]; set error [dict get $response respone]; putnow "privmsg $c :$error \00304»\003 $message"; return}
 foreach var {artistName trackName trackId lyrics} {set $var [dict get $response $var]}
 putquick "privmsg $c :\037\00353Lirik Lagu:\003\037 $trackName \0034-\003 \002$artistName\002 \0034-\003 https://youtu.be/$trackId" 
 foreach line [split $lyrics "\n"] {putquick "privmsg $c :$line"}
}
putlog "+++ Lirik Lagu TCL Loaded..."
