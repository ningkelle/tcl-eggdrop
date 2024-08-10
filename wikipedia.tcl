bind pub - .wiki pub:wiki
proc pub:wiki {n u h c t} {
 set t [stripcodes bcruag $t]; set targetlang [lindex $t 0]; set wikisearch [lrange $t 1 end]
 if {$t == "" || $wikisearch == ""} {putnow "privmsg $c :Usage: .wiki <kode-bahasa> <keyword>"; return}
 if {[catch {set wikiurl [http::geturl https://$targetlang.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1&[http::formatQuery titles $wikisearch] -timeout 30000]} error]} {putnow "privmsg $c :\0034ERROR:\003 $error"; return}
 set wikidata [http::data $wikiurl]; set response [json::json2dict $wikidata]; http::cleanup $wikiurl
 regexp -all -nocase {"pages":\{"(.*?)":\{"} $wikidata "" pageid; if {$pageid == "-1"} {putnow "privmsg $c :$wikisearch \0034»»\003 Not Found"; return}
 set titles [dict get $response query pages $pageid title]; set extracts [dict get $response query pages $pageid extract]
 regsub -all {\s+} $titles "_" urlwiki; set urlwikis "https://$targetlang.wikipedia.org/wiki/$urlwiki"
 regsub -all "\"" $extracts "\'\'" extracts; set extracts [newline $extracts]
 putnow "privmsg $c :\00353\037Wikipedia:\037\003\002 $titles\002 \0034»»\003 \037$urlwikis\037"
 foreach line $extracts {if {$line != ""} {putnow "privmsg $c :$line"}}
}
putlog "+++ Wikipedia TCL Loaded..."
