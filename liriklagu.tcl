bind pub - .lirik pub:lirik
proc pub:lirik {n u h c t} {
 set t [stripcodes bcruag $t]; if {$t == ""} {putnow "privmsg $c :.lirik <judul lagu>"; return}; regsub -all {\s+} $t "%20" text;
 catch {exec curl -X GET --connect-timeout 5 https://lyrist.vercel.app/api/$text} lirikdata; set lirikjson [json::json2dict $lirikdata]
 if {![dict exists $lirikjson lyrics]} {putnow "privmsg $c :Not Found"; return}
 foreach var {lyrics title artist image} {set $var [dict get $lirikjson $var]}
 putnow "privmsg $c :\037\00353Lirik Lagu:\003\037 $title \0034-\003 \002$artist\002" 
 foreach line [split $lyrics "\n"] {regexp -all {\[(.*?)\]} $line "" verse; regsub -all {\[.*?\]} $line "\00363\[$verse\]\003" line; putnow "privmsg $c :$line"}
}
putlog "+++ Lirik Lagu TCL Loaded..."
