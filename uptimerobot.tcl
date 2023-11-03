# .ruptime / .ruptime <monitors id>
bind pub - .ruptime pub:ruptime
proc pub:ruptime {n u h c t} {
 set monitorid [lindex [stripcodes bcruag $t] 0]
 set apikey "1234567890ABCDEFGHIJKLMNOPQRSTUVWQYZ" ; #https://uptimerobot.com/api/
 if {$t == ""} {set query [http::formatQuery api_key $apikey custom_uptime_ratios 90 format json]} else {set query [http::formatQuery api_key $apikey custom_uptime_ratios 90 monitors $monitorid format json]}
 if {[catch {set ruptimepages [http::geturl https://api.uptimerobot.com/v2/getMonitors -query $query -timeout 30000]} error]} {putnow "privmsg $c :$error" ; return}
 set response [::json::json2dict [http::data $ruptimepages]] ; http::cleanup $ruptimepages
 if {[dict get $response stat] == "fail"} {putnow "privmsg $c :[dict get $response error message]" ; return}
 set monitors [dict get $response monitors] ; if {![llength $monitors] == 1} {putnow "privmsg $c :Not Found" ; return}
 foreach line $monitors {
  set fname [dict get $line friendly_name] ; set status [dict get $line status]
  if {$status == "0"} {set status "Paused"} ; if {$status == "1"} {set status "not checked yet"} ; if {$status == "2"} {set status "Up"} ; if {$status == "8"} {set status "seems down"} ; if {$status == "9"} {set status "Down"}
  set id [dict get $line id] ; set host [dict get $line url] ; set dtime [dict get $line create_datetime] ; set idtime [clock format $dtime -format "%d %b %Y %H:%M:%S %Z" -timezone :Asia/Jakarta] ; set uptime [dict get $line custom_uptime_ratio]
  set items "\n$fname ($id) \0034-\003 \037Status:\037 $status \0034-\003 \037Uptime:\037 $uptime\% \0034-\003 \037Created:\037 $idtime" ; append result $items
 }
 foreach output [split $result "\n"] {putnow "privmsg $c :$output"}
}
putlog "+++ UptimeRobot TCL Loaded..."
