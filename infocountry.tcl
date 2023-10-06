bind pub - .co pub:country
proc pub:country {n u h c t} {
 set t [lindex [stripcodes bcruag $t] 0]
 if {$t == ""} {putnow "privmsg $c :Usage : .co <kode-negara>" ; return}
 if {[catch {set countrypage [http::geturl https://restcountries.com/v3.1/alpha/$t?fields=status,name,capital,currencies,languages -timeout 30000]} error]} {putnow "privmsg $c :$error" ; return}
 set countrydata [http::data $countrypage] ; http::cleanup $countrypage ; putlog "$countrydata"
 regexp -all -nocase {"status":(.*?),} $countrydata "" status
 regexp -all -nocase {"message":"(.*?)"} $countrydata "" message
 if {$status == "404"} { putnow "privmsg $c :[string toupper $t] \0034»»\003 $status \($message\)" ; return }
 if {$status == "400"} { putnow "privmsg $c :[string toupper $t] \0034»»\003 $status \($message\)" ; return }
 regexp -all -nocase {:\{"common":"(.*?)",} $countrydata "" names
 regexp -all -nocase {,"official":"(.*?)",} $countrydata "" office
 regexp -all -nocase {"currencies":\{"(.*?)"} $countrydata "" currency
 regexp -all -nocase {"capital":\["(.*?)"\]} $countrydata "" capital
 regexp -all -nocase {"name":"(.*?)",} $countrydata "" matauang
 putnow "PRIVMSG $c :[string toupper $t] \0034»»\003 $names \($office\) \0034-\003 \037Ibukota:\037 $capital \0034-\003 \037Mata Uang:\037 $matauang \($currency\)"
}
putlog "+++ Info Country TCL Loaded..."
