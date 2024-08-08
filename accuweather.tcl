bind pub - .aw pub:accuweather
proc pub:accuweather {n u h c t} {
 set t [stripcodes bcruag $t]; if {$t == ""} {putnow "privmsg $c :.aw <kel/kec/kota>"; return}
 regsub -all {\s+} $t "%20" text
 set apikey "1234567890ABCDEFGHIJKLMNOPQRSTUVWQYZ"; # apikey : https://developer.accuweather.com/
 catch {exec curl -X GET --connect-timeout 5 https://dataservice.accuweather.com/locations/v1/cities/search?apikey=$apikey&offset=1&language=id&q=$text} keydata; set keyjson [json::json2dict $keydata];
 if {[dict exists $keyjson Code]} {set code [dict get $keyjson Code]; set message [dict get $keyjson Message]; putnow "privmsg $c :\0034ERROR\:\003 $code \0034-\003 $message"; return}
 if {![dict exists [lindex $keyjson 0] Key]} {putnow "privmsg $c :\0034ERROR\:\003 Not Found"; return} else {set Key [dict get [lindex $keyjson 0] Key]};
 catch {exec curl -X GET --connect-timeout 5 https://dataservice.accuweather.com/currentconditions/v1/$Key?apikey=$apikey&language=id&details=true} accuwtdata; set accuwtjson [json::json2dict $accuwtdata];
 catch {exec curl -X GET --connect-timeout 5 https://dataservice.accuweather.com/forecasts/v1/daily/1day/$Key?apikey=$apikey&language=id&details=true&metric=true} forecastdata; set forecastjson [json::json2dict $forecastdata];
 foreach key {LocalizedName AdministrativeArea Country GeoPosition TimeZone} {set $key [dict get [lindex $keyjson 0] $key]};
 foreach accu {EpochTime Temperature RealFeelTemperature WeatherText Visibility Wind Pressure PressureTendency CloudCover Ceiling RelativeHumidity DewPoint UVIndex UVIndexText Link} {set $accu [dict get [lindex $accuwtjson 0] $accu]};
 set State [dict get $AdministrativeArea LocalizedName]; set Country [dict get $Country ID];
 set lati [dict get $GeoPosition Latitude]; set longi [dict get $GeoPosition Longitude]; set waktuzona [dict get $TimeZone Name];
 set temp [dict get $Temperature Metric Value]; set tempf [dict get $RealFeelTemperature Metric Value]; 
 set visib [dict get $Visibility Metric Value]; set Wind [dict get $Wind Speed Metric Value]; set pres [dict get $Pressure Metric Value];
 set presten [dict get $PressureTendency LocalizedText]; set ceiling [dict get $Ceiling Metric Value]; set dewpoint [dict get $DewPoint Metric Value];
 set DailyForecasts [dict get $forecastjson DailyForecasts]; set sunrise [dict get [lindex $DailyForecasts 0] Sun EpochRise]; set sunset [dict get [lindex $DailyForecasts 0] Sun EpochSet];
 set moonrise [dict get [lindex $DailyForecasts 0] Moon EpochRise]; set moonset [dict get [lindex $DailyForecasts 0] Moon EpochSet]; set moonage [dict get [lindex $DailyForecasts 0] Moon Age];
 if {$presten == "Naik"} {set presten "\u2191"}; if {$presten == "Turun"} {set presten "\u2193"}; if {$presten == "Tetap"} {set presten "\u2194"}
 set update [clock format $EpochTime -format "%d-%b-%Y %H:%M %Z" -timezone :$waktuzona]; set temp [expr {round($temp)}]; set tempf [expr {round($tempf)}]; set visib [expr {round($visib)}]; set Wind [expr {double(round(10000*$Wind)/3600)/10}]; set pres [expr {round($pres)}]; set ceiling [expr {double(round(10*($ceiling/1000)))/10}]; set dewpoint [expr {round($dewpoint)}]
 set sunrise [clock format $sunrise -format "%H:%M %Z" -timezone :$waktuzona]; set sunset [clock format $sunset -format "%H:%M %Z" -timezone :$waktuzona]; if {$moonrise == "null"} {set moonrise "N/A"} else {set moonrise [clock format $moonrise -format "%H:%M %Z" -timezone :$waktuzona]}; if {$moonset == "null"} {set moonset "N/A"} else {set moonset [clock format $moonset -format "%H:%M %Z" -timezone :$waktuzona]}
 putnow "privmsg $c :\00353\037Info Cuaca:\037\003 $LocalizedName, $State, $Country \0034-\003 \037https://google.com/maps?q=$lati,$longi\037"
 putnow "privmsg $c :\037Cuaca:\037 $temp°C ($tempf°C) \0034-\003 [capitalize $WeatherText] \0034-\003 \037Awan:\037 $CloudCover\% \0034-\003 \037Ketinggian Awan:\037 $ceiling\km \0034-\003 \037Angin:\037 $Wind\m/s \0034-\003 \037Jarak Pandang:\037 $visib\km"
 putnow "privmsg $c :\037UV Index:\037 $UVIndexText \($UVIndex\) \0034-\003 \037Tekanan:\037 $presten $pres\hPa \0034-\003 \037Kelembapan:\037 $RelativeHumidity\% \0034-\003 \037Titik Embun:\037 $dewpoint°C \0034-\003 \037Updated:\037 $update"
 putnow "privmsg $c :\037Sunrise:\037 $sunrise \0034-\003 \037Sunset:\037 $sunset \0034-\003 \037Moonrise:\037 $moonrise \0034-\003 \037Moonset:\037 $moonset \0034-\003 \037Moon-age:\037 $moonage hari"
 #putnow "privmsg $c :\037$Link\037"
}
putlog "+++ AccuWeather TCL Loaded..."
