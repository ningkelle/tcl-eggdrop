set cmds ". ! ` -"
foreach cmd $cmds {bind pub - ${cmd}ip pub:ipapi}
proc pub:ipapi {n u h c t} {
 set t [lindex [formattedTXT $t] 0]; if {$t == ""} {putquick "privmsg $c :Usage: .ip <ip/host>"; return};
 if {[onchan $t $c] || (![string match *.* $t] && ![string match *:* $t])} {check:nick $n $c $t; return}
 check:domain $n $c $t; return
}
proc check:nick {n c t} {set ::ipchan $c; set ::ipnick $n; putquick "USERHOST $t"; bind RAW - 302 check:nick:host;}
proc check:nick:host {from key args} {
 set c $::ipchan; set n $::ipnick; set raw_str [lindex $args 0]; set u [lindex $raw_str 1]; unbind RAW - 302 check:nick:host; 
 set u [string trimleft $u :]; if {$u == "" || [string length $u] < 5} {putquick "privmsg $c :Ga ada nicknya"; return}
 set host [lindex [split $u @] 1]; check:domain $n $c $host;
}
proc check:domain {n c t} {
 array set ip_list {}; set index 0
 set is_ipv4 [regexp {^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$} $t]; set is_ipv6 [regexp {:} $t]
 if {$is_ipv4 || $is_ipv6} {set ip_list(0) $t; incr index} else {
  if {[catch {exec host $t} dnslist]} {putquick "privmsg $c :\0034ERROR:\003 $t \00304\u00bb\003 Gjls"; return}
  foreach line [split $dnslist "\n"] {
   if {[regexp {has address ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)} $line x ip]} {set ip_list($index) $ip; incr index
   } elseif {[regexp {has IPv6 address ([a-fA-F0-9:]+)} $line x ip]} {set ip_list($index) $ip; incr index}
  }
 }
 if {$index == 0} {putquick "privmsg $c :\0034ERROR:\003 $t \00304\u00bb\003 Gjls"; return}
 for {set i 0} {$i < $index} {incr i} {set t $ip_list($i); ipapi:whois $n $c $t}
}
proc ipapi:whois {n c t} {
 if {[catch {set ipapiurl [http::geturl http://ip-api.com/json/$t?fields=4253247 -timeout 10000]} error]} {putquick "privmsg $c :\0034ERROR:\003 $error"; return}
 set ipapidata [http::data $ipapiurl]; set response [json::json2dict $ipapidata]; http::cleanup $ipapiurl
 if {[dict get $response status] == "fail"} {putquick "privmsg $c :[dict get $response query] \00304\u00bb\003 [dict get $response message]"; return}
 foreach var {status country countryCode region regionName city zip isp org asname query} {set $var [dict get $response $var]}
 if {$country == ""} {putnow "privmsg $c :$t \0034»»\003 Invalid IP address"; return}
 if {$zip == "" && $org == ""} {putquick "PRIVMSG $c :$query \00304\u00bb\003 $isp ($asname) \0034-\003 $city \0034-\003 $regionName \0034-\003 $country"; return}
 if {$zip == ""} {putquick "PRIVMSG $c :$query \00304\u00bb\003 $isp ($org) \0034-\003 $city \0034-\003 $regionName \0034-\003 $country" ; return}
 if {$org == ""} {putquick "PRIVMSG $c :$query \00304\u00bb\003 $isp ($asname) \0034-\003 $city \0034-\003 $regionName \0034-\003 $zip \0034-\003 $country"; return}
 putquick "PRIVMSG $c :$query \00304\u00bb\003 $isp ($org) \0034-\003 $city \0034-\003 $regionName \0034-\003 $zip \0034-\003 $country"
}
putlog "+++ IPAPI Info TCL Loaded..."
