bind pub - .zodiak pub:zdkdtk
proc pub:zdkdtk {n u h c t} {
 set t [lindex [stripcodes bcruag $t] 0]; set t [string tolower $t]; if {$t == ""} {putquick "privmsg $c :.zdk <zodiak>"; return}
 catch {exec curl --connect-timeout 5 --max-time 60 --retry 5 --retry-delay 2 --retry-max-time 30 -X GET https://wolipop.detik.com/zodiak/$t 2>/dev/null} list;
 regsub -all "\n" $list "" data; regsub -all "</div>" $data "" data; regsub -all "&nbsp;" $data "" data; regsub -all "</strong>" $data "" data;
 regsub -all "<strong>" $data "" data; regsub -all "&ndash;" $data " - " data;
 regexp {Peruntungan:(.*?)<} $data x peruntungan; regexp {s Zodiac(.*?)<} $data x peruntungan2
 if {![info exists peruntungan]} {if {[info exists peruntungan2]} {set peruntungan $peruntungan2} else {putquick "privmsg $c :\0034ERROR:\003 No data found"; return}}
 regexp {Keuangan: ([^<]+)<} $data x keuangan
 regexp {Asmara: (.*?)<} $data x asmara
 regexp {Jam.*?: (.*?)</p>} $data x jambaik; regexp {Jam.*?: (.*?)<div} $data x jambaik2;
 putquick "privmsg $c :\002\00309Zodiak: [string toupper $t]\003\002";
 putquick "privmsg $c :\002\00353Peruntungan :\003\002 $peruntungan";
 putquick "privmsg $c :\002\00353Keuangan :\003\002 $keuangan";
 putquick "privmsg $c :\002\00353Asmara :\003\002 $asmara";
 if {![info exists jambaik]} {if {[info exists jambaik2]} {set jambaik $jambaik2} else {return}}
 regsub -all "<br />" $jambaik "" jambaik;
 putquick "privmsg $c :\002\00353Jam Baik :\003\002 $jambaik";
}
putlog "+++ Zodiak TCL Loaded..."
