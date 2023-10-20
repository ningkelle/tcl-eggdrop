bind pub - .yt pub:ytsearch
proc pub:ytsearch {n u h c t} {
 set t [stripcodes bcruag $t]
 if {$t == ""} {putnow "privmsg $c :Usage: .yt <keyword>" ; return 0}
 set apikey "1234567890ABCDEFGHIJKLMNOPQRSTUVWQYZ" ; #YouTube Data API v3 : https://developers.google.com/youtube/v3/getting-started
 if {[catch {set ytpage [http::geturl "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=5&regionCode=id&safeSearch=none&type=video&key=$apikey&[http::formatQuery q $t]" -timeout 60000]} error]} {putnow "privmsg $c :$error" ; return}
 set response [::json::json2dict [http::data $ytpage]] ; http::cleanup $ytpage
 foreach var {pageInfo items} {set $var [dict get $response $var]} ; set totalResults [dict get $pageInfo totalResults]
 if {$totalResults == 0} {putnow "privmsg $c :\037YouTube:\037 \00359$t\003 \0034»»\003 hasil tidak ditemukan" ; return} else {putnow "privmsg $c :\037YouTube:\037 \00359$t\003 \0034»»\003 \002$totalResults\002 hasil ditemukan"}
 foreach line $items {if {[dict exists [dict get $line id] videoId]} {set videoid [dict get [dict get $line id] videoId]} ; set title [dict get [dict get $line snippet] title] ; set chtitle [dict get [dict get $line snippet] channelTitle] ; set items "\nhttps://youtu.be/$videoid \0034»»\003 $title \0034-\003 \00353by\003 $chtitle" ; append result $items}
 foreach output [split $result "\n"] {putnow "privmsg $c :$output"}
}
putlog "+++ YouTube Search TCL Loaded..."
