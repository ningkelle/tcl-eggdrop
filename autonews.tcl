##### Auto News
setudef flag autonews
## .chanset <#channel> +autonews
proc tinyurl {url} {
 set apitoken "1234567890ABCDEFGHIJKLMNOPQRSTUVWQYZ"; ## apikey : https://tinyurl.com/app/register
 set apiurl "https://api.tinyurl.com/create?api_token=$apitoken";
 set header "Content-Type: application/json"; set headers "accept: application/json"
 set body "\{\"url\": \"$url\",\"domain\": \"tinyurl.com\",\"description\"\: \"shortly\"\}"
 catch {exec curl --connect-timeout 5 -X POST $apiurl -H $headers -H $header -d $body 2> /dev/null} data;
 regexp {"code":(.*?),} $data x code; if {$code == 1} {regexp {"errors":\["(.*?)"\]} $data x error; return $error}
 set response [json::json2dict $data]; set tiny [dict get $response data tiny_url]; return $tiny
}
## detiknews
bind cron - "* * * * *" detiknews
proc detiknews {1 2 3 4 5} {
 foreach c [channels] {
  if {[channel get $c autonews] == 1} {
   set lastpub [exec cat news.detik]
   catch {exec curl --connect-timeout 5 -X GET https://news.detik.com/rss 2> /dev/null} data;
   regexp {</image>(.*?)<description>} $data x list
   regexp {<guid>(.*?)<.*<pubDate>(.*?)<.*<!\[CDATA\[(.*?)\]\]} $list x link update title
   if {$update == $lastpub} {return} else {exec echo $update > news.detik}; set link [tinyurl $link]
   putquick "privmsg $c :\002\detik.com\002 ($update) \0034-\003 $title \0034-\003 $link"
  }
 }
}
putlog "+++ news.detik.com TCL Loaded..."
## totabuan
bind cron - "* * * * *" totabuan
proc totabuan {1 2 3 4 5} {
 foreach c [channels] {
  if {[channel get $c autonews] == 1} {
   set lastpub [exec cat news.totabuan]
   catch {exec curl --connect-timeout 5 -X GET http://totabuan.co/feed/ 2> /dev/null} data;
   regexp {<channel>.*<item>(.*?)<category>} $data x list;
   regexp {<title>(.*?)</.*<link>(.*?)</.*<pubDate>(.*?)</} $list x title link update
   if {$update == $lastpub} {return} else {exec echo $update > news.totabuan}; set link [tinyurl $link]
   putquick "privmsg $c :\002\00304totabuan.co\003\002 ($update) \0034-\003 $title \0034-\003 $link"
  }
 }
}
putlog "+++ totabuan.co TCL Loaded..."
## seleb.tempo
bind cron - "* * * * *" selebtempo
proc selebtempo {1 2 3 4 5} {
 foreach c [channels] {
  if {[channel get $c autonews] == 1} {
   set lastseleb [exec cat news.tempo.seleb]
   catch {exec curl -X GET https://api-berita-indonesia.vercel.app/tempo/seleb/ 2> /dev/null} seleb;
   set selebjson [json::json2dict $seleb]; if {![dict exists $selebjson success]} {return}
   set post [dict get $selebjson data posts]; if {![dict exists [lindex $post 0] link]} {return}
   foreach var {link title pubDate} {set $var [dict get [lindex $post 0] $var]};
   if {$pubDate == $lastseleb} {return} else {exec echo $pubDate > news.tempo.seleb}
   set link [tinyurl $link]
   set update [clock scan $pubDate -format {%Y-%m-%dT%H:%M:%S.000Z} -timezone :UTC];
   set newsupdate [clock format $update -format {%d-%m-%y %H:%M %Z} -timezone :Asia/Jakarta];
   putnow "privmsg $c :\002seleb.\0034tempo.co\003\002 \($newsupdate\) \0034-\003 $title \0034-\003 $link"
  }
 }
}
putlog "+++ SELEB.tempo.co TCL Loaded..."
## bola.tempo
bind cron - "* * * * *" newssport
proc newssport {1 2 3 4 5} {
 foreach c [channels] {
  if {[channel get $c autonews] == 1} {
   set lastsport [exec cat news.tempo.sport]
   catch {exec curl -X GET https://api-berita-indonesia.vercel.app/tempo/bola/ 2> /dev/null} sport;
   set sportjson [json::json2dict $sport]; if {![dict exists $sportjson success]} {return}
   set post [dict get $sportjson data posts]; if {![dict exists [lindex $post 0] link]} {return}
   foreach var {link title pubDate} {set $var [dict get [lindex $post 0] $var]};
   if {$pubDate == $lastsport} {return} else {exec echo $pubDate > news.tempo.sport}
   set link [tinyurl $link]
   set update [clock scan $pubDate -format {%Y-%m-%dT%H:%M:%S.000Z} -timezone :UTC];
   set newsupdate [clock format $update -format {%d-%m-%y %H:%M %Z} -timezone :Asia/Jakarta];
   putnow "privmsg $c :\002bola.\0034tempo.co\003\002 \($newsupdate\) \0034-\003 $title \0034-\003 $link"
  }
 }
}
putlog "+++ BOLA.tempo.co TCL Loaded..."
## metro.tempo
bind cron - "* * * * *" metrotempo
proc metrotempo {1 2 3 4 5} {
 foreach c [channels] {
  if {[channel get $c autonews] == 1} {
   set lastmetro [exec cat news.tempo.metro]
   catch {exec curl -X GET https://api-berita-indonesia.vercel.app/tempo/metro/ 2> /dev/null} metro;
   set metrojson [json::json2dict $metro]; if {![dict exists $metrojson success]} {return}
   set post [dict get $metrojson data posts]; if {![dict exists [lindex $post 0] link]} {return}
   foreach var {link title pubDate} {set $var [dict get [lindex $post 0] $var]};
   if {$pubDate == $lastmetro} {return} else {exec echo $pubDate > news.tempo.metro}
   set link [tinyurl $link]
   set update [clock scan $pubDate -format {%Y-%m-%dT%H:%M:%S.000Z} -timezone :UTC];
   set newsupdate [clock format $update -format {%d-%m-%y %H:%M %Z} -timezone :Asia/Jakarta];
   putnow "privmsg $c :\002metro.\0034tempo.co\003\002 \($newsupdate\) \0034-\003 $title \0034-\003 $link"
  }
 }
}
putlog "+++ metro.tempo.co TCL Loaded..."
## GSMArena
bind cron - "* * * * *" gsmarenanews
proc gsmarenanews {1 2 3 4 5} {
 foreach c [channels] {
  if {[channel get $c autonews] == 1} {
   set lastpub [exec cat news.gsmarena]
   catch {exec curl -X GET https://www.gsmarena.com/rss-news-reviews.php3 2> /dev/null} data;
   regexp {<item>.*?<title><!\[CDATA\[([^<]+)\]\]></title>} $data x title
   regexp {<item>.*?<link>([^<]+)</link>} $data x link
   regexp {<item>.*?<pubDate>([^<]+)</pubDate>} $data x pubdate
   if {$pubdate == $lastpub} {return} else {exec echo $pubdate > news.gsmarena}
   set link [tinyurl $link]
   set time [clock scan $pubdate -format {%a, %d %b %Y %H:%M:%S %z}];
   set update [clock format $time -format {%d-%m-%y %H:%M %Z} -timezone :Asia/Jakarta]
   putquick "privmsg $c :\002\00304GSM\003Arena.com\002 ($update) \0034-\003 $title \0034-\003 $link"
  }
 }
}
putlog "+++ GSMArena.com TCL Loaded..."
