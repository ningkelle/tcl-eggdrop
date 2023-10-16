bind pub - .gempa pub:gempa
proc pub:gempa {n u h c t} {
 if {[catch {set gempaurl [http::geturl https://cuaca-gempa-rest-api.vercel.app/quake -timeout 3000]} error]} {putnow "privmsg $c :$error" ; return}
 set response [::json::json2dict [http::data $gempaurl]] ; http::cleanup $gempaurl ; putlog "$response"
 set gempa [dict get $response data] ; foreach data {tanggal jam lintang bujur magnitude kedalaman wilayah potensi dirasakan shakemap} {set $data [dict get $gempa $data]}
 putnow "privmsg $c :\037Lokasi:\037 $wilayah \0034-\003 $lintang\, $bujur \0034-\003 $dirasakan"
 putnow "privmsg $c :\037Skala:\037 $magnitude Magnitudo \0034-\003 \037Kedalaman:\037 $kedalaman \0034-\003 \037Waktu:\037 $tanggal $jam \0034-\003 \037Potensi:\037 $potensi"
 putnow "privmsg $c :\037$shakemap\037"
}
putlog "+++ Info Gempa BMKG TCL Loaded..."
