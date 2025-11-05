# untuk menggunakan semua tcl disini, simpan file ini di dir scripts/
# lalu tambahkan di config : source scripts/serbaserbiserbu.tcl
####################################
package require Tcl
package require http
package require tls
package require json
# package require tdom 0.9.3
# package require eggdrop 1.9

http::register https 443 [list ::tls::socket -tls1 1 -ssl2 0 -ssl3 0 -autoservername 1]
http::config -proxyhost "" -useragent "IRCCloud/4.35 (SM-F766B; id; Android 16; 1080x2520; WIFI)"

proc commify {n {s ,} {g 3}} {regsub -all \\d(?=(\\d{$g})+([regexp -inline {\.\d*$} $n]$)) $n \\0$s}
proc noquote {t} {regsub -all {\."} $t {} t ; regsub -all {"}   $t {} t ; return $t}
proc capitalize {sentence} {subst -nobackslashes -novariables [regsub -all {\S+} $sentence {[string totitle &]}]}
proc newline {input} {set j 0 ; set tempdef "" ; foreach line [split $input \n] {if {$line != ""} {set len 375 ; set splitChr " " ; set out [set cur {}]; set i 0 ; foreach word [split $line $splitChr] {if {[incr i [string len $word]]>$len} {lappend out [join $cur $splitChr] ; set cur [list $word] ; set i [string len $word] ; incr j} else {lappend cur $word} ; incr i} ; lappend out [join $cur $splitChr] ; foreach line2 $out {if {$j >= 1} {set line2 [linsert $line2 end] ; set j [expr $j -1]} ; lappend tempdef $line2}}} ; return $tempdef}
