bind pub - .zodiak pub:zdk
proc pub:zdk {n u h c t} {
 set t [lindex [stripcodes bcruag $t] 0]; set t [string tolower $t]; if {$t == ""} {putquick "privmsg $c :.zodiak <zodiak>"; return}
 catch {exec curl --connect-timeout 5 -X GET https://www.fimela.com/zodiak/$t} data;
 regexp {<span class="zodiak--content-header__date">([^<]+)</span>} $data x tanggal
 regexp {<span class="zodiak--content-header__modified-time__text">Diperbarui </span>([^<]+)</time></div>} $data x update
 regexp {Profil</h5></div><div class="zodiak--content__content"><p>([^<]+)</p></div></div>} $data x profile
 if {![info exists profile]} {putquick "privmsg $c :\0034ERROR:\003 No data found"; return}
 regexp {Kesehatan</h5></div><div class="zodiak--content__content"><p>([^<]+)</p></div></div>} $data x kesehatan
 regexp {Love</h5></div><div class="zodiak--content__content"><p>Single: ([^<]+)<br><br>Couple:} $data x single
 regexp {<br><br>Couple: ([^<]+)</p></div></div>} $data x couple
 regexp {Karir</h5></div><div class="zodiak--content__content"><p>([^<]+)</p></div></div>} $data x karir
 regexp {Keuangan</h5></div><div class="zodiak--content__content"><p>([^<]+)</p></div></div></div>} $data x uang
 set profile [newline $profile]; set kesehatan [newline $kesehatan]; set single [newline $single]; set couple [newline $couple]; set karir [newline $karir]; set uang [newline $uang];
 putquick "privmsg $c :\002\00363[string toupper $t]\003\002 ($tanggal) \0034-\003 Update: $update";
 putquick "privmsg $c :\002\00353Profil :\003\002"; foreach pro $profile {if {$pro != ""} {putquick "privmsg $c :$pro"}}
 putquick "privmsg $c :\002\00353Kesehatan :\003\002"; foreach kes $kesehatan {if {$kes != ""} {putquick "privmsg $c :$kes"}}
 putquick "privmsg $c :\002\00353Love :\003\002";
 putquick "privmsg $c :\002\037Single :\037\002"; foreach sing $single {if {$sing != ""} {putquick "privmsg $c :$sing"}}
 putquick "privmsg $c :\002\037Couple :\037\002"; foreach coup $couple {if {$coup != ""} {putquick "privmsg $c :$coup"}}
 putquick "privmsg $c :\002\00353Karir :\003\002"; foreach kar $karir {if {$kar != ""} {putquick "privmsg $c :$kar"}}
 putquick "privmsg $c :\002\00353Keuangan :\003\002"; foreach duit $uang {if {$duit != ""} {putquick "privmsg $c :$duit"}}
}
putlog "+++ Zodiak TCL Loaded..."
