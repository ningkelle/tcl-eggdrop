bind pub - .wt pub:weather
proc pub:weather {n u h c t} {
 set t [stripcodes bcruag $t]; if { $t == "" } {putnow "privmsg $c :Usage: .wt </kab/kota/kec>"; return}
 set apikey "1234567890ABCDEFGHIJKLMNOPQRSTUVWQYZ"; # key : www.openweathermap.org
 if {[catch {set weatherurl [http::geturl http://api.openweathermap.org/data/2.5/weather?appid=$apikey&lang=id&units=metric&[http::formatQuery q $t] -timeout 3000]} error]} {putnow "privmsg $c :\0034ERROR:\003 $error"; return}
 set weatherdata [http::data $weatherurl]; set response [json::json2dict $weatherdata]; http::cleanup $weatherurl
 if {[dict get $response cod] == "404"} {putnow "privmsg $c :$t \0034»»\003 [dict get $response message]"; return}
 foreach var {name visibility sys main weather wind clouds dt} {set $var [dict get $response $var]}
 set visibility [expr $visibility /1000]
 set country [dict get $sys country]
 set temp [expr {round([dict get $main temp])}]
 set feels [expr {round([dict get $main feels_like])}]
 set cloud [string toupper [dict get [lindex $weather 0] description]]
 set cloud [capitalize $cloud]
 set humidity [dict get $main humidity]
 set pressure [dict get $main pressure]
 set windspeed [expr {double(round(10*[dict get $wind speed]))/10}]
 set cloudcover [dict get $clouds all]
 set dt [clock format $dt -format "%d-%b-%Y %H:%M %Z" -timezone :Asia/Jakarta]
 set sunrise [clock format [dict get $sys sunrise] -format "%H:%M:%S %Z" -timezone :Asia/Jakarta]
 set sunset [clock format [dict get $sys sunset] -format "%H:%M:%S %Z" -timezone :Asia/Jakarta]
 putnow "PRIVMSG $c :\037Cuaca:\037 $name ($country) \0034-\003 $temp\°C ($feels\°C) \0034-\003 $cloud \0034-\003 \037Awan:\037 $cloudcover\% \0034-\003 \037Angin:\037 $windspeed\m\/s \0034-\003 \037Tekanan:\037 $pressure\hPa"
 putnow "PRIVMSG $c :\037Jarak Pandang:\037 $visibility\km \0034-\003 \037Kelembapan:\037 $humidity\% \0034-\003 \037Sunrise:\037 $sunrise \0034-\003 \037Sunset:\037 $sunset \0034-\003 \037Updated:\037 $dt"
}
putlog "+++ Weather TCL Loaded..."
