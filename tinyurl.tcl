bind pub - .tiny pub:tiny
proc pub:tiny {n u h c t} {
 set t [lindex [stripcodes bcruag $t] 0]; if {$t == ""} {putquick "privmsg $c :.tiny <url>"; return}
 if {![string match -nocase "*.*" $t]} {putquick "privmsg $c :\0034ERROR:\003 Invalid URL"; return}
 set apitoken "1234567890ABCDEFGHIJKLMNOPQRSTUVWQYZ"; ## apikey : https://tinyurl.com/app/register
 set apiurl "https://api.tinyurl.com/create?api_token=$apitoken";
 set header "Content-Type: application/json"; set headers "accept: application/json"
 set body "\{\"url\": \"$t\",\"domain\": \"tinyurl.com\",\"description\"\: \"beritadetik\"\}"
 catch {exec curl -X POST $apiurl -H $headers -H $header -d $body } data; putlog $data;
 regexp {"domain":"(.*?)","alias":"(.*?)","} $data x tiny short
 if {![info exists tiny]} {putquick "privmsg $c :\0034ERROR\003"; return} 
 putquick "privmsg $c :https://$tiny/$short"
}
putlog "+++ Tiny Short URL TCL Loaded..."
