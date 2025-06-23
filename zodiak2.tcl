bind pub - .zodiak pub:zdkdtk
proc pub:zdkdtk {n u h c t} {
 set t [lindex [stripcodes bcruag $t] 0]; set t [string tolower $t]; if {$t == ""} {putquick "privmsg $c :.zodiak <zodiak>"; return}
 catch {exec curl --connect-timeout 5 -X GET https://wolipop.detik.com/zodiak/$t 2>/dev/null} data; regsub -all "&nbsp;" $data "" data
 regexp {Peruntungan: ([^<]+)<br /><br />} $data x peruntungan
 if {![info exists peruntungan]} {putquick "privmsg $c :\0034ERROR:\003 No data found"; return}
 regexp {Keuangan: ([^<]+)<br /><br />} $data x keuangan
 regexp {Asmara: ([^<]+)<br /><br />} $data x asmara
 regexp {Jam Baik: ([^<]+)</p>} $data x jambaik
 set peruntungan [newline $peruntungan]; set keuangan [newline $keuangan]; set asmara [newline $asmara];
 putquick "privmsg $c :\002\00353Peruntungan :\003\002";
 foreach untung $peruntungan {if {$untung != ""} {putquick "privmsg $c :$untung"}}
 putquick "privmsg $c :\002\00353Keuangan :\003\002";
 foreach uang $keuangan {if {$uang != ""} {putquick "privmsg $c :$uang"}}
 putquick "privmsg $c :\002\00353Asmara :\003\002";
 foreach asmr $asmara {if {$asmr != ""} {putquick "privmsg $c :$asmr"}}
 putquick "privmsg $c :\002\00353Jam Baik :\003\002 $jambaik";
}
putlog "+++ Zodiak TCL Loaded..."
