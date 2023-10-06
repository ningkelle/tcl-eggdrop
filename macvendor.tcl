bind pub - .mac pub:macvendor
proc pub:macvendor {n u h c t} {
 set t [lindex [stripcodes bcruag $t] 0]
 if {$t == ""} {putnow "privmsg $c :Usage : .mac <mac-addr>" ; return}
 if {[catch {set macvendorurl [http::geturl https://api.macvendors.com/$t -timeout 30000]} error]} {putnow "privmsg $c :$error" ; return}
 set macvendordata [http::data $macvendorurl] ; http::cleanup $macvendorurl ; putlog "$macvendordata"
 set macvendorresult [lindex [split $macvendordata \"] 0]
 if { $macvendorresult == "\{" } {set macvendorresult [lindex [split $macvendordata \"] 5]}
 putnow "PRIVMSG $c :[string toupper $t] \0034»»\003 $macvendorresult"
}
putlog "+++ MAC Vendors TCL Loaded..."
