bind pub - .wiki pub:wiki
proc pub:wiki {n u h c t} {
 set t [stripcodes bcruag $t]; set targetlang [lindex $t 0]; set wikitext [lrange $t 1 end]; regsub -all {\s+} $wikitext "%20" wikisearch
 if {$t == "" || $wikisearch == ""} {putnow "privmsg $c :Usage: .wiki <kode-bahasa> <keyword>"; return}
 catch {exec curl --connect-timeout 5 --max-time 60 --retry 5 --retry-delay 2 --retry-max-time 30 https://$targetlang.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1&titles=$wikisearch} wikidata;
 regexp -all {"pages":\{"(.*?)"} $wikidata "" pageid; set response [json::json2dict $wikidata];
 if {$pageid == "-1"} {putnow "privmsg $c :$wikitext \0034»\003 Not Found"; return}
 set titles [dict get $response query pages $pageid title]; set extracts [dict get $response query pages $pageid extract]
 regsub -all {\s+} $titles "_" urlwiki; set urlwikis "https://$targetlang.wikipedia.org/wiki/$urlwiki"
 regsub -all "\"" $extracts "\'\'" extracts; set extracts [newline $extracts]
 putquick "privmsg $c :\00353\037Wikipedia:\037\003\002 $titles\002 \0034»\003 \037$urlwikis\037"
 foreach line $extracts {if {$line != ""} {putquick "privmsg $c :$line"}}
}
putlog "+++ Wikipedia TCL Loaded..."
