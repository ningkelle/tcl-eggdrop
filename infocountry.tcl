bind pub - .co pub:country
proc pub:country {n u h c t} {
 set t [lindex [stripcodes bcruag $t] 0]
 if {$t == ""} {putnow "privmsg $c :Usage: .co <kode-negara>" ; return}
 if {[catch {set countrypage [http::geturl https://restcountries.com/v3.1/alpha/$t?fields=status,name,capital,currencies -timeout 30000]} error]} {putnow "privmsg $c :$error" ; return}
 set response [::json::json2dict [http::data $countrypage]] ; set countrydata [http::data $countrypage] ; http::cleanup $countrypage ; putlog "$countrydata"
 if {[dict get $response status] == "404"} { putnow "privmsg $c :[string toupper $t] \0034»»\003 [dict get $response message]" ; return }
 if {[dict get $response status] == "400"} { putnow "privmsg $c :[string toupper $t] \0034»»\003 [dict get $response message]" ; return }
 foreach var {name currencies capital} {set $var [dict get $response $var]} ; regsub -all "\{" $capital "" capital ; regsub -all "\}" $capital "" capital
 foreach names {common official} {set $names [dict get $name $names]}
 regexp -all -nocase {"currencies":\{"(.*?)":} $countrydata "" currency
 set matauang [dict get $currencies $currency name]
 putnow "PRIVMSG $c :[string toupper $t] \0034»»\003 $common \($official\) \0034-\003 \037Ibukota:\037 $capital \0034-\003 \037Mata Uang:\037 $matauang \($currency\)"
}
putlog "+++ Info Country TCL Loaded..."
