bind pub - .ip pub:ipapi
proc pub:ipapi {n u h c t} {
 set t [lindex [stripcodes bcruag $t] 0]
 if { $t == "" } {putnow "privmsg $c :Usage: .ip <ip/host>" ; return 0}
 if {![string match -nocase "*:*" $t] && ![string match -nocase "*.*" $t]} {putnow "USERHOST :$t" ; set ::ipchan $c ; set ::ip_search $t ; bind RAW - 302 check:for:nick ; return}
 if {[catch {set ipapiurl [http::geturl http://ip-api.com/json/$t?fields=4253247 -timeout 30000]} error]} {putnow "privmsg $c :$error" ; return}
 set response [::json::json2dict [http::data $ipapiurl]] ; http::cleanup $ipapiurl ; putlog "$response"
 if {[dict get $response status] == "fail"} {putnow "privmsg $c :[dict get $response query] \0034»»\003 [dict get $response message]" ; return}
 foreach var { status country countryCode region regionName city zip isp org asname query } { set $var [dict get $response $var] }
 if {$country == ""} {pub:geoip $n $u $h $c $t ; set t $query ; return}
 if {$country == "Indonesia" && $org == ""} {putnow "PRIVMSG $c :$query \0034»»\003 $isp ($asname) \0034-\003 $city \0034-\003 $regionName \0034-\003 $country" ; return}
 if {$country == "Indonesia"} {putnow "PRIVMSG $c :$query \0034»»\003 $isp ($org) \0034-\003 $city \0034-\003 $regionName \0034-\003 $country" ; return}
 if {$zip == ""} {putnow "PRIVMSG $c :$query \0034»»\003 $isp ($org) \0034-\003 $city \0034-\003 $regionName \0034-\003 $country" ; return}
 if {$org == ""} {putnow "PRIVMSG $c :$query \0034»»\003 $isp ($asname) \0034-\003 $city \0034-\003 $regionName \0034-\003 $zip \0034-\003 $country" ; return}
 putnow "PRIVMSG $c :$query \0034»»\003 $isp ($org) \0034-\003 $city \0034-\003 $regionName \0034-\003 $zip \0034-\003 $country"
}
proc check:for:nick { from keyword arguments } {
 set t $::ip_search ; set c $::ipchan ; set u [lindex [split $arguments] 1]
 set hostname [lindex [split $u "="] 1]
 regsub {^[-+]} $hostname "" h
 set nickname [lindex [split $u "="] 0]
 regsub {^:} $nickname "" n
 if {$n == ""} {putnow "privmsg $c :Ga ada nicknya" ; unbind RAW - 302 check:for:nick ; return}
 set h [lindex [split $h @] 1] ; pub:ipapi "" $n $t $c $h ; unbind RAW - 302 check:for:nick
}
proc pub:geoip {n u h c t} {
 set ip [lindex [stripcodes bcruag $t] 0]
 putnow "privmsg $c :[geoip:whois $ip]"
 return 0
}
proc geoip:whois {ip} {
 catch {exec whois $ip} ipres
 foreach line [split $ipres "\n"] {
  if {[string index $line 0]!="#" && [string index $line 0]!="%"} {
   if {[string match -nocase *netname:* $line]} {regexp -nocase {netname:(.*)} $line x netname}
   if {[string match -nocase *owner-c:* $line]} {regexp -nocase {owner-c:(.*)} $line x netname}
   if {[string match -nocase *descr:* $line]} {regexp -nocase {descr:(.*)} $line x orgname}
   if {[string match -nocase *orgname:* $line]} {regexp -nocase {orgname:(.*)} $line x orgname}
   if {[string match -nocase *owner:* $line]} {regexp -nocase {owner:(.*)} $line x orgname}
   if {[string match -nocase *inetnum:* $line]} {regexp -nocase {inetnum:(.*)} $line x range}
   if {[string match -nocase *inet6num:* $line]} {regexp -nocase {inet6num:(.*)} $line x range}
   if {[string match -nocase *netrange:* $line]} {regexp -nocase {netrange:(.*)} $line x range}
   if {[string match -nocase *custname:* $line]} {regexp -nocase {custname:(.*)} $line x custname}
   if {[string match -nocase *city:* $line]} {regexp -nocase {city:(.*)} $line x city}
   if {[string match -nocase *stateprov:* $line]} {regexp -nocase {stateprov:(.*)} $line x stateprov}
   if {[string match -nocase *postalcode:* $line]} {regexp -nocase {postalcode:(.*)} $line x postalcode}
   if {[string match -nocase *country:* $line]} {regexp -nocase {country:(.*)} $line x country}
  }
 }
 if {![info exists orgname]} {return "$ip \0034»»\003 Invalid IP address"}
 return "$ip \0034»»\003 [string trim $range] - [string trim $netname] \([string trim $orgname]\) - [string trim $country]"
}
putlog "+++ IP Info TCL Loaded..."
