bind pub - .adzan pub:adzan
proc pub:adzan {n u h c t} {
 set t [stripcodes bcruag $t]; if {$t == ""} {putnow "privmsg $c :.adzan <kel/desa/kec> <kota> - Ex: .adzan Kebon Jeruk Jakarta"; return}
 regsub -all {\s+} $t "%20" text; set time [unixtime]; set waktu [clock format $time -format "%d-%m-%Y"]
 catch {exec curl -X GET --connect-timeout 5 https://api.aladhan.com/v1/timingsByAddress/$waktu?address=$text&method=20&tune=1,1,2,2,1,2,2,1,2} adzandata; set adzanjson [json::json2dict $adzandata]
 if {[dict get $adzanjson code] != "200"} {set error [dict get $adzanjson data]; putnow "privmsg $c :\0034ERROR:\003 $error"; return}
 set data [dict get $adzanjson data]; foreach var {timings date meta} {set $var [dict get $data $var]}
 foreach lokasi {latitude longitude timezone} {set $lokasi [dict get $meta $lokasi]}
 foreach shalat {Fajr Dhuhr Asr Maghrib Isha Imsak} {set $shalat [dict get $timings $shalat]}
 set jam [dict get $date timestamp]; set zonawaktu [clock format $jam -format "%Z" -timezone :$timezone]
 set tanggal [dict get $date hijri day]; set bulan [dict get $date hijri month en]; set tahun [dict get $date hijri year]
 putnow "privmsg $c :\037Adzan:\037 [capitalize $t] \0034-\003 \037https://google.com/maps?q=$latitude,$longitude\037"
 putnow "privmsg $c :\037Subuh\037 \0034»»\003 $Fajr $zonawaktu" 
 putnow "privmsg $c :\037Zhuhur\037 \0034»»\003 $Dhuhr $zonawaktu"
 putnow "privmsg $c :\037Ashar\037 \0034»»\003 $Asr $zonawaktu"
 putnow "privmsg $c :\037Magrib\037 \0034»»\003 $Maghrib $zonawaktu"
 putnow "privmsg $c :\037Isya\037 \0034»»\003 $Isha $zonawaktu"
 putnow "privmsg $c :\037Updated\037 \0034»»\003 $tanggal $bulan $tahun \($waktu\)"
}
putlog "+++ Waktu Adzan TCL Loaded..."
