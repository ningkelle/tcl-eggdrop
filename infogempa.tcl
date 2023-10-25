bind pub - .gempa pub:gempa
proc pub:gempa {n u h c t} {
 if {[catch {set gempaurl [http::geturl https://data.bmkg.go.id/DataMKG/TEWS/autogempa.json -timeout 3000]} error]} {putnow "privmsg $c :$error" ; return}
 set response [::json::json2dict [http::data $gempaurl]] ; http::cleanup $gempaurl ; putlog "$response"
 set gempa [dict get $response Infogempa gempa] ; foreach data {Tanggal Jam Lintang Bujur Magnitude Kedalaman Wilayah Potensi Dirasakan Shakemap} {set $data [dict get $gempa $data]}
 putnow "privmsg $c :\037Lokasi:\037 $Wilayah \($Lintang\, $Bujur\) \0034-\003 $Dirasakan"
 putnow "privmsg $c :\037Skala:\037 $Magnitude Magnitudo \0034-\003 \037Kedalaman:\037 $Kedalaman \0034-\003 \037Waktu:\037 $Tanggal $Jam \0034-\003 \037Potensi:\037 $Potensi"
 putnow "privmsg $c :\037https://data.bmkg.go.id/DataMKG/TEWS/$Shakemap\037"
}
putlog "+++ Info Gempa BMKG TCL Loaded..."
