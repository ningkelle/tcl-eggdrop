bind pub - .adzan pub:adzan
proc pub:adzan {n u h c t} {
 set t [stripcodes bcruag $t]; if {$t == ""} {putnow "privmsg $c :.adzan <desa/kel/kec/kota> - Ex: .adzan kebon jeruk"; return}
 regsub -all {\s+} $t "%20" text; set time [unixtime]; set waktu [clock format $time -format "%d-%m-%Y"]
 set apikey "1234567890ABCDEFGHIJKLMNOPQRSTUVWQYZ"; # apikey : www.developer.accuweather.com
 catch {exec curl -X GET --connect-timeout 5 https://dataservice.accuweather.com/locations/v1/cities/search?apikey=$apikey&offset=1&language=id&q=$text} keydata; set keyjson [json::json2dict $keydata];
 if {[dict exists $keyjson Code]} {set code [dict get $keyjson Code]; set message [dict get $keyjson Message]; putnow "privmsg $c :\0034ERROR\:\003 $code \0034-\003 $message"; return}
 if {![dict exists [lindex $keyjson 0] Key]} {putnow "privmsg $c :\0034ERROR\:\003 Not Found"; return}
 foreach var {LocalizedName AdministrativeArea Country GeoPosition TimeZone} {set $var [dict get [lindex $keyjson 0] $var]};
 set State [dict get $AdministrativeArea LocalizedName]; set Country [dict get $Country ID];
 set lati [dict get $GeoPosition Latitude]; set longi [dict get $GeoPosition Longitude]; set waktuzona [dict get $TimeZone Name];
 if {[catch {set adzanpage [http::geturl https://api.aladhan.com/v1/timings/$waktu?latitude=$lati&longitude=$longi&method=20&tune=1,1,2,2,2,2,2,1,2 -timeout 30000]} error]} {putnow "privmsg $c :$error"; return}
 set adzandata [http::data $adzanpage]; set adzanjson [json::json2dict $adzandata]; http::cleanup $adzanpage
 if {[dict get $adzanjson code] != "200"} {set error [dict get $adzanjson data]; putnow "privmsg $c :\0034ERROR:\003 $error"; return}
 set data [dict get $adzanjson data]; foreach var {timings date meta} {set $var [dict get $data $var]}; foreach shalat {Fajr Dhuhr Asr Maghrib Isha Imsak} {set $shalat [dict get $timings $shalat]}
 set jam [dict get $date timestamp]; set zonawaktu [clock format $jam -format "%Z" -timezone :$waktuzona]; set utc [clock format $jam -format "%z" -timezone :$waktuzona]
 set tanggal [dict get $date hijri day]; set bulan [dict get $date hijri month en]; set tahun [dict get $date hijri year]
 putnow "privmsg $c :\00353\037Info Adzan:\037\003 $LocalizedName, $State, $Country \0034-\003 \037https://google.com/maps?q=$lati,$longi\037"
 putnow "privmsg $c :\037TimeZone\037 \0034»»\003 $waktuzona ($utc)"
 putnow "privmsg $c :\037Subuh\037 \0034»»\003 $Fajr $zonawaktu" 
 putnow "privmsg $c :\037Zhuhur\037 \0034»»\003 $Dhuhr $zonawaktu"
 putnow "privmsg $c :\037Ashar\037 \0034»»\003 $Asr $zonawaktu"
 putnow "privmsg $c :\037Magrib\037 \0034»»\003 $Maghrib $zonawaktu"
 putnow "privmsg $c :\037Isya\037 \0034»»\003 $Isha $zonawaktu"
 putnow "privmsg $c :\037Updated\037 \0034»»\003 $tanggal $bulan $tahun \($waktu\)"
}
putlog "+++ Waktu Adzan TCL Loaded..."
