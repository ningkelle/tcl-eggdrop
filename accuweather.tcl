bind pub - .aw pub:accuweather
proc pub:accuweather {n u h c t} {
 set t [stripcodes bcruag $t]; if {$t == ""} {putnow "privmsg $c :.aw <kel/kec/kota>"; return}
 regsub -all {\s+} $t "%20" text
 set apikey "1234567890ABCDEFGHIJKLMNOPQRSTUVWQYZ"; # apikey : https://developer.accuweather.com/
 catch {exec curl -X GET --connect-timeout 5 https://dataservice.accuweather.com/locations/v1/cities/search?apikey=$apikey&offset=1&language=id&q=$text} keydata
 regexp -all -nocase {Unavailable.*?Message\":\"(.*?)\",} $keydata "" error; if {[info exists error]} {putnow "privmsg $c :\0034ERROR\:\003 $error"; return}
 regexp -all -nocase {\[\{\"Version.*?Key\":\"(.*?)\",\"} $keydata "" Key; if {![info exists Key]} {putnow "privmsg $c :\0034ERROR\:\003 Not Found"; return}
 catch {exec curl -X GET --connect-timeout 5 https://dataservice.accuweather.com/currentconditions/v1/$Key?apikey=$apikey&language=id&details=true} accuwtdata
 catch {exec curl -X GET --connect-timeout 5 https://dataservice.accuweather.com/forecasts/v1/daily/1day/$Key?apikey=$apikey&language=id&details=true&metric=true} forecastdata
 regexp -all -nocase {\[\{\"Version.*?Rank.*?\"LocalizedName\":\"(.*?)\",\"} $keydata "" LocalizedName
 regexp -all -nocase {\[\{\"Version.*?Country\":\{\"ID\":\"(.*?)\",\"} $keydata "" Country
 regexp -all -nocase {\[\{\"Version.*?AdministrativeArea.*?\"ID\":\"(.*?)\",\"LocalizedName\":\"(.*?)\",\"} $keydata "" StateID State
 regexp -all -nocase {\[\{\"Version.*?GeoPosition.*?\"Latitude\":(.*?),\"Longitude\":(.*?),\"} $keydata "" lati longi
 regexp -all -nocase {\[\{\"Version.*?TimeZone.*?\"Name\":\"(.*?)\",\"} $keydata "" waktuzona
 regexp -all -nocase {\"EpochTime\":(.*?),\"} $accuwtdata "" update
 regexp -all -nocase {\"Temperature\":.*?Value\":(.*?),\"} $accuwtdata "" temp
 regexp -all -nocase {\"RealFeelTemperature\":.*?Value\":(.*?),\"} $accuwtdata "" tempf
 regexp -all -nocase {\"WeatherText\":\"(.*?)\",\"} $accuwtdata "" WeatherText
 regexp -all -nocase {\"Visibility\":.*?Value\":(.*?),\"} $accuwtdata "" visib
 regexp -all -nocase {\"Wind\".*?\"Speed\":.*?Value\":(.*?),\"} $accuwtdata "" Wind
 regexp -all -nocase {\"Pressure\":.*?Value\":(.*?),\"} $accuwtdata "" pres
 regexp -all -nocase {\"PressureTendency\":\{\"LocalizedText\":\"(.*?)\",\"} $accuwtdata "" presten
 regexp -all -nocase {\"CloudCover\":(.*?),\"} $accuwtdata "" CloudCover
 regexp -all -nocase {\"Ceiling\":.*?Value\":(.*?),\"} $accuwtdata "" ceiling
 regexp -all -nocase {\"RelativeHumidity\":(.*?),\"} $accuwtdata "" RelativeHumidity
 regexp -all -nocase {\"DewPoint\":.*?Value\":(.*?),\"} $accuwtdata "" dewpoint
 regexp -all -nocase {\"UVIndex\":(.*?),\"} $accuwtdata "" uvindex
 regexp -all -nocase {\"UVIndexText\":\"(.*?)\",\"} $accuwtdata "" uvindextx
 regexp -all -nocase {\"Link\":\"(.*?)\"\}} $accuwtdata "" link
 regexp -all -nocase {\"Sun\".*?\"EpochRise\":(.*?),\"} $forecastdata "" sunrise
 regexp -all -nocase {\"Sun\".*?\"EpochSet\":(.*?)\},\"} $forecastdata "" sunset
 regexp -all -nocase {\"Moon\".*?\"EpochRise\":(.*?),\"} $forecastdata "" moonrise
 regexp -all -nocase {\"Moon\".*?\"EpochSet\":(.*?),\"} $forecastdata "" moonset
 regexp -all -nocase {\"Moon\".*?\"Age\":(.*?)\},\"} $forecastdata "" moonage
 regexp -all -nocase {\"AirQuality\",\"Value\":(.*?),\"} $forecastdata "" airquality
 regexp -all -nocase {\"AirQuality.*?Category\":\"(.*?)\",\"} $forecastdata "" airqualitytxt
 if {$presten == "Naik"} {set presten "\u2191"}; if {$presten == "Turun"} {set presten "\u2193"}; if {$presten == "Tetap"} {set presten "\u2194"}
 set update [clock format $update -format "%d-%b-%Y %H:%M %Z" -timezone :$waktuzona]; set temp [expr {round($temp)}]; set tempf [expr {round($tempf)}]; set visib [expr {round($visib)}]; set Wind [expr {double(round(10000*$Wind)/3600)/10}]; set pres [expr {round($pres)}]; set ceiling [expr {double(round(10*($ceiling/1000)))/10}]; set dewpoint [expr {round($dewpoint)}]
 set sunrise [clock format $sunrise -format "%H:%M %Z" -timezone :$waktuzona]; set sunset [clock format $sunset -format "%H:%M %Z" -timezone :$waktuzona]; if {$moonrise == "null"} {set moonrise "N/A"} else {set moonrise [clock format $moonrise -format "%H:%M %Z" -timezone :$waktuzona]}; if {$moonset == "null"} {set moonset "N/A"} else {set moonset [clock format $moonset -format "%H:%M %Z" -timezone :$waktuzona]}
 putnow "privmsg $c :\00353\037Info Cuaca:\037\003 $LocalizedName, $State, $Country \0034-\003 \037https://google.com/maps?q=$lati,$longi\037"
 putnow "privmsg $c :\037Cuaca:\037 $temp°C ($tempf°C) \0034-\003 [capitalize $WeatherText] \0034-\003 \037Awan:\037 $CloudCover\% \0034-\003 \037Ketinggian Awan:\037 $ceiling\km \0034-\003 \037Angin:\037 $Wind\m/s \0034-\003 \037Jarak Pandang:\037 $visib\km"
 putnow "privmsg $c :\037UV Index:\037 $uvindextx \($uvindex\) \0034-\003 \037Tekanan:\037 $presten $pres\hPa \0034-\003 \037Kelembapan:\037 $RelativeHumidity\% \0034-\003 \037Titik Embun:\037 $dewpoint°C \0034-\003 \037Updated:\037 $update"
 putnow "privmsg $c :\037Sunrise:\037 $sunrise \0034-\003 \037Sunset:\037 $sunset \0034-\003 \037Moonrise:\037 $moonrise \0034-\003 \037Moonset:\037 $moonset \0034-\003 \037Moon-age:\037 $moonage hari"
 #putnow "privmsg $c :\037$link\037"
}
putlog "+++ Weather TCL Loaded..."
