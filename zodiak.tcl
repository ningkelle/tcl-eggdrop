set cmds ". ! ` -"
foreach cmd $cmds {bind pub - ${cmd}zodiak pub:zdkdtk}
proc pub:zdkdtk {n u h c t} {
 set t [lindex [stripcodes bcruag $t] 0]; set t [string tolower $t]; if {$t == ""} {putquick "privmsg $c :.zdk <zodiak>"; return}
 catch {exec curl --connect-timeout 5 --max-time 60 --retry 5 --retry-delay 2 --retry-max-time 30 -X GET https://www.fimela.com/zodiak/$t 2>/dev/null} data;
 regexp {<span class="zodiak--content-header__date">(.*?)</span>.*Diperbarui </span>(.*?)</time>} $data x tanggal update;
 regexp {Profil</h5></div><div class="zodiak--content__content"><p>(.*?)</p>} $data x profile;
 if {![info exists profile]} {putquick "privmsg $c :\00304ERROR:\003 No data found"; return}
 regexp {Kesehatan</h5>.*<p>([^<]+)</p></div>.*Love</h5>.*Single: ([^<]+)<br><br>Couple: ([^<]+)</p></div></div>.*Karir</h5>.*<p>([^<]+)</p></div></div>.*Keuangan</h5>.*<p>([^<]+)<} $data x kesehatan single couple karir uang
 putquick "privmsg $c :\002\00363[string toupper $t]\003\002 ($tanggal) \0034-\003 Update: $update";
 # set profile [newline $profile]; foreach pro $profile {if {$pro != ""} {putquick "privmsg $c :$pro"}}
 putquick "privmsg $c :\002\00353Kesehatan :\003\002 $kesehatan";
 putquick "privmsg $c :\002\00353Love :\003\002 \002\037Single :\037\002 $single \002\037Couple :\037\002 $couple";
 putquick "privmsg $c :\002\00353Karir :\003\002 $karir";
 putquick "privmsg $c :\002\00353Keuangan :\003\002 $uang";
}
putlog "+++ Zodiak TCL Loaded..."
