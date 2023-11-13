bind pub - .google pub:ggl
proc pub:ggl {n u h c t} {
 set t [stripcodes bcruag $t] ; if { $t == "" } {putnow "privmsg $c :Usage: .google <keyword> \| .google image <keyword>" ; return 0} ; set gimg [lindex $t 0]
 set apikey "1234567890ABCDEFGHIJKLMNOPQRSTUVWQYZ" ; # Google Custom Search API : https://developers.google.com/custom-search/v1/overview
 set sEngine "1234567890ABCDEFGHIJKLMNOPQRSTUVWQYZ" ; # Google Programmable Search Engine : https://programmablesearchengine.google.com/controlpanel/all
 if {$gimg == "image"} {set url "https://www.googleapis.com/customsearch/v1?key=$apikey&cx=$sEngine&searchType=image&lr=lang_id&safe=active&num=5&[http::formatQuery q $t]"} else {set url "https://www.googleapis.com/customsearch/v1?key=$apikey&cx=$sEngine&lr=lang_id&safe=active&num=5&[http::formatQuery q $t]"}
 if {[catch {set gglpage [http::geturl $url -timeout 60000]} error]} {putnow "privmsg $c :$error" ; return}
 set response [::json::json2dict [http::data $gglpage]] ; http::cleanup $gglpage
 if {[dict exists $response error code]} {putnow "privmsg $c :[dict get $response error message]" ; return}
 set formattedTotalResults [dict get $response searchInformation formattedTotalResults]
 if {$formattedTotalResults == "0"} {putnow "privmsg $c :\037Google:\037 \00359$t\003 \0034»»\003 hasil tidak ditemukan" ; return} else {putnow "privmsg $c :\037Google:\037 \00359$t\003 \0034»»\003 \002$formattedTotalResults\002 hasil ditemukan"}
 foreach line [dict get $response items] {set title [dict get $line title] ; set link [dict get $line link] ; set items "\n$link \0034»»\003 $title" ; append result $items}
 foreach output [split $result "\n"] {putnow "privmsg $c :$output"}
}
putlog "+++ Google Custom Search TCL Loaded..."
