##### Auto Jadwal Adzan
setudef flag autoadzan
## .chanset <#channel> +autoadzan
bind cron - "* * * * *" autoadzan
proc autoadzan {1 2 3 4 5} {
 set timezone "Asia/Jakarta"; ### ganti sesuai wilayah
 set lati "-6.175"; set longi "106.827"; set lokasi "Jakarta"; ### ganti sesuai lokasi/kota
 set time [unixtime]; set waktu [clock format $time -format "%d-%m-%Y" -timezone :$timezone]; set adztime [clock format $time -format "%H:%M" -timezone :$timezone]; set jumat [clock format $time -format "%a" -timezone :$timezone];
 catch {exec curl -X GET --connect-timeout 5 https://api.aladhan.com/v1/timings/$waktu?latitude=$lati&longitude=$longi&method=20&tune=1,1,2,2,1,3,2,1,2 2>/dev/null} adzandata;
 set adzanjson [json::json2dict $adzandata]; if {![dict exists $adzanjson code]} {return}; if {[dict get $adzanjson code] != "200"} {return}
 set data [dict get $adzanjson data timings]; foreach shalat {Fajr Dhuhr Asr Maghrib Isha} {set $shalat [dict get $data $shalat]}
 foreach chans [channels] {
  if {[channel get $chans autoadzan] == 1} {
   if {$adztime == $Dhuhr} {if {$jumat == "Fri"} {putnow "privmsg $chans :Sekarang waktu \002\00304Adzan Jum'at\003\002 untuk wilayah \002$lokasi\002"} else {putnow "privmsg $chans :Sekarang waktu \002\00304Zhuhur\003\002 untuk wilayah \002$lokasi\002"}
   } elseif {$adztime == $Asr} {putnow "privmsg $chans :Sekarang waktu \002\00304Ashar\003\002 untuk wilayah \002$lokasi\002"
   } elseif {$adztime == $Maghrib} {putnow "privmsg $chans :Sekarang waktu \002\00304Maghrib\003\002 untuk wilayah \002$lokasi\002"
   } elseif {$adztime == $Isha} {putnow "privmsg $chans :Sekarang waktu \002\00304Isya\003\002 untuk wilayah \002$lokasi\002"
   } elseif {$adztime == $Fajr} {putnow "privmsg $chans :Sekarang waktu \002\00304Shubuh\003\002 untuk wilayah \002$lokasi\002"
   } else {return}
  }
 }
}
putlog "+++ AutoAdzan TCL Loaded..."
