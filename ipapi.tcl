bind pub - .ip pub:ipapi
proc pub:ipapi {n u h c t} {
 set t [lindex [stripcodes bcruag $t] 0]
 if {$t == ""} {putnow "privmsg $c :Usage: .ip <ip/host>" ; return 0}
 if {![string match -nocase "*:*" $t] && ![string match -nocase "*.*" $t]} {putnow "USERHOST :$t" ; set ::ipchan $c ; set ::ipnick $n ; set ::iphand $h ; bind RAW - 302 check:for:nick ; return}
 if {[catch {set ipapiurl [http::geturl http://ip-api.com/json/$t?fields=4253247 -timeout 30000]} error]} {putnow "privmsg $c :$error" ; return}
 set response [::json::json2dict [http::data $ipapiurl]] ; http::cleanup $ipapiurl ; putlog "$response"
 if {[dict get $response status] == "fail"} {putnow "privmsg $c :[dict get $response query] \0034»»\003 [dict get $response message]" ; return}
 foreach var { status country countryCode region regionName city zip isp org asname query } { set $var [dict get $response $var] }
 if {$country == ""} {putnow "privmsg $c :$t \0034»»\003 Invalid IP address" ; return}
 if {$zip == "" && $org == ""} {putnow "PRIVMSG $c :$query \0034»»\003 $isp ($asname) \0034-\003 $city \0034-\003 $regionName \0034-\003 $country" ; return}
 if {$zip == ""} {putnow "PRIVMSG $c :$query \0034»»\003 $isp ($org) \0034-\003 $city \0034-\003 $regionName \0034-\003 $country" ; return}
 if {$org == ""} {putnow "PRIVMSG $c :$query \0034»»\003 $isp ($asname) \0034-\003 $city \0034-\003 $regionName \0034-\003 $zip \0034-\003 $country" ; return}
 putnow "PRIVMSG $c :$query \0034»»\003 $isp ($org) \0034-\003 $city \0034-\003 $regionName \0034-\003 $zip \0034-\003 $country"
}
proc check:for:nick { from keyword args } {
 set c $::ipchan ; set n $::ipnick ; set h $::iphand ; set u [lindex [split $args] 1]
 set hostname [lindex [split $u "="] 1] ; regsub {^[-+]} $hostname "" host
 set nickname [lindex [split $u "="] 0] ; regsub {^:} $nickname "" nicksearch
 if {$nicksearch == ""} {putnow "privmsg $c :Ga ada nicknya" ; unbind RAW - 302 check:for:nick ; return}
 set t [lindex [split $host @] 1] ; pub:ipapi $n $u $h $c $t; unbind RAW - 302 check:for:nick
}
putlog "+++ IPAPI Info TCL Loaded..."
