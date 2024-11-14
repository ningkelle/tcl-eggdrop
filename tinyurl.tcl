bind pub - .tiny pub:tiny
proc pub:tiny {n u h c t} {
 set t [lindex [stripcodes bcruag $t] 0]; if {$t == ""} {putquick "privmsg $c :.tiny <url>"; return}
 if {![string match -nocase "*.*" $t]} {putquick "privmsg $c :\0034ERROR:\003 Invalid URL"; return}
 set apitoken "1234567890ABCDEFGHIJKLMNOPQRSTUVWQYZ"; ## apikey : https://tinyurl.com/app/register
 set apiurl "https://api.tinyurl.com/create?api_token=$apitoken";
 set header "Content-Type: application/json"; set headers "accept: application/json"
 set body "\{\"url\": \"$t\",\"domain\": \"tinyurl.com\",\"description\"\: \"shortly\"\}"
 catch {exec curl --connect-timeout 5 -X POST $apiurl -H $headers -H $header -d $body 2> /dev/null} data; regexp {"code":(.*?),} $data x code
 if {$code == 1} {regexp {"errors":\["(.*?)"\]} $data x error; putquick "privmsg $c :\0034ERROR:\003 $error"; return}
 set response [json::json2dict $data]; set tiny [dict get $response data tiny_url];
 putquick "privmsg $c :$tiny"
}
putlog "+++ Tiny Short URL TCL Loaded..."
