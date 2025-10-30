set cmds ". ! ` -"
foreach cmd $cmds {bind pub - ${cmd}dwhois pub:domainwhois}
proc pub:domainwhois {n u h c t} {
 set t [lindex [stripcodes bcruag $t] 0]; if {$t == ""} {putnow "privmsg $c :Usage: .dwhois <domain>"; return}
 if {[catch {set domainchk [exec whois -I $t]} error]} {
  if {[string match "*IANA WHOIS server*" $error]} {putnow "privmsg $c :\0034ERROR:\003 You queried for \002$t\002 but this server does not have any data for \002$t\002"; return} else {putnow "privmsg $c :\0034ERROR:\003 $error"; return}
 } 
 if {[string match -nocase "*Server too busy*" $domainchk]} {putnow "PRIVMSG $c :\0034ERROR:\003 [string range $domainchk [expr [string last ":" $domainchk] + 2] end]"; return}
 regexp -nocase {Domain Name: (.*?)\n} $domainchk t dname
 if {![info exists dname]} {putlog "next 1"; pub:domainwhois2 $n $c $t; return}
 regexp -nocase {Created On: (.*?) } $domainchk t dcreate; regexp -nocase {Creation Date: (.*?)T} $domainchk t dcreate2
 if {![info exists dcreate]} {
  if {[info exists dcreate2]} {
   set dcreate $dcreate2
  } else {putlog "next 1"; pub:domainwhois2 $n $c $t; return}
 }; putquick "privmsg $c :\037Domain\037 \00304\u00bb\003 $dname \($dcreate\)"
 regexp -nocase {Last Updated On: (.*?) } $domainchk t dupdate; regexp -nocase {Updated Date: (.*?)T} $domainchk t dupdate2
 if {[info exists dupdate]} {set dupdate [clock scan $dupdate -format {%Y-%m-%d}]; set dupdate [clock format $dupdate -format {%d-%b-%Y}]}
 if {![info exists dupdate]} {
  if {[info exists dupdate2]} {
   set dupdate $dupdate2
   set dupdate [clock scan $dupdate -format {%Y-%m-%d}]; set dupdate [clock format $dupdate -format {%d-%b-%Y}]
  } else {set dupdate "N/A"}
 }
 regexp -nocase {Expiration Date: (.*?) } $domainchk t dexpire; regexp -nocase {Registry Expiry Date: (.*?)T} $domainchk t dexpire2
 if {[info exists dexpire]} {set dexpire [clock scan $dexpire -format {%Y-%m-%d}]; set dexpire [clock format $dexpire -format {%d-%b-%Y}]}
 if {![info exists dexpire]} {
  if {[info exists dexpire2]} {
   set dexpire $dexpire2
   set dexpire [clock scan $dexpire -format {%Y-%m-%d}]; set dexpire [clock format $dexpire -format {%d-%b-%Y}]
  } else {set dexpire "N/A"}
 }; putquick "privmsg $c :\037Updated\037 \00304\u00bb\003 $dupdate \0034\u2014\003 $dexpire"
 foreach line [split $domainchk "\n"] {if {[string match -nocase "*Name Server*" $line]} {putquick "PRIVMSG $c :\037NS\037 \00304\u00bb\003 [string range $line [expr [string last "Server:" $line] + 8] end]"}}
 regexp -nocase {DNSSEC: (.*?)\n} $domainchk t dnssec
 if {![info exists dnssec]} {return}
 putquick "privmsg $c :\037DNSSEC\037 \00304\u00bb\003 $dnssec"
}
proc pub:domainwhois2 {n c t} {
 catch {exec whois $t} domainchk2
 regexp -nocase {Domain: (.*?)\n} $domainchk2 t dname
 if {![info exists dname]} {set dname $t}
 regexp -nocase {Changed: (.*?)T} $domainchk2 t dcreate
 regexp -nocase {Created:         (.*?)\n} $domainchk2 t dcreate2
 if {![info exists dcreate]} {
  if {[info exists dcreate2]} {set dcreate $dcreate2} else {putlog "next 2"; whoisapi:xml $n $c $t; return}
 }
 putquick "privmsg $c :\037Domain\037 \00304\u00bb\003 $dname \($dcreate\)"
 regexp -nocase {Last updated:    (.*?)\n} $domainchk2 t dupdate
 if {[info exists dupdate]} {putquick "privmsg $c :\037Updated\037 \00304\u00bb\003 $dupdate"}
 foreach line [split $domainchk2 "\n"] {if {[string match -nocase "*Nserver:*" $line]} {putquick "PRIVMSG $c :\037NS\037 \00304\u00bb\003 [string range $line [expr [string last "Server:" $line] + 9] end]"}}
}
proc whoisapi:xml {n c t} {
 set apikey "at_9tc4ElemAxInWclrO6ZRirZASlaLv";
 set url "https://www.whoisxmlapi.com/whoisserver/WhoisService?apiKey=$apikey&domainName=$t"
 catch {exec curl --connect-timeout 5 --max-time 60 --retry 5 --retry-delay 2 --retry-max-time 30 -s -A "IRCCloud/4.32.1 (iPhone; en-ID; iOS 18.6.2)" -X GET $url 2>/dev/null} data
 regsub -all "\n" $data "" data
 regexp {<dataError>(.*?)</dataError>} $data x error; if {[info exists error]} {putquick "privmsg $c :\00304ERROR:\003 $error"; return}
 regexp {<registryData>(.*?)</registryData>} $data x list; if {![info exists list]} {putquick "privmsg $c :\00304ERROR:\003 No data found"; return}
 regexp {<domainName>(.*?)</domainName>} $list x dname
 regexp {<createdDateNormalized>(.*?)</createdDateNormalized>} $list x create
 regexp {<createdDate>(.*?)</createdDate>} $list x create2
 if {![info exists create]} {set create $create2}
 set create [clock scan $create -format {%Y-%m-%d %H:%M:%S %Z}]; set created [clock format $create -format {%Y-%m-%d}]
 putquick "privmsg $c :\037Domain\037 \00304\u00bb\003 $dname ($created)"
 regexp {<updatedDateNormalized>(.*?)</updatedDateNormalized>} $list x update
 if {[info exists update]} {set update [clock scan $update -format {%Y-%m-%d %H:%M:%S %Z}]; set updated [clock format $update -format {%Y-%m-%d}]} else {set updated "N/A"};
 regexp {<expiresDateNormalized>(.*?)</expiresDateNormalized>} $list x expire
 if {[info exists expire]} {set expire [clock scan $expire -format {%Y-%m-%d %H:%M:%S %Z}]; set expired [clock format $create -format {%Y-%m-%d}]} else {set expired "N/A"};
 putquick "privmsg $c :\037Updated\037 \00304\u00bb\003 $updated \0034\u2014\003 $expired"
 regsub "/Address>" $list "\n" nserver
 foreach line [split $nserver "\n"] {
  regexp {<Address>(.*?)<} $line x ns
  if {![info exists ns]} {return}
  putquick "privmsg $c :\037NS\037 \00304\u00bb\003 $ns"
 }
}
putlog "+++ Domain Whois TCL Loaded..."
