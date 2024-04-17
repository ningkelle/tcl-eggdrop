package require Tcl 8.6.13
package require http 2.9.8
package require tls 1.7.22
package require json 1.3.4
package require tdom
package require eggdrop 1.9

http::register https 443 [list ::tls::socket -tls1 1 -ssl2 0 -ssl3 0 -autoservername 1]
http::config -proxyhost "" -useragent "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 10.0)"

proc commify {n {s ,} {g 3}} {regsub -all \\d(?=(\\d{$g})+([regexp -inline {\.\d*$} $n]$)) $n \\0$s}
proc noquote {t} {regsub -all {\."} $t {} t ; regsub -all {"}   $t {} t ; return $t}
proc antiflood {} {global floodprotect ; if {[info exists floodprotect]} {set diff [expr [clock seconds]-$floodprotect] ; if {$diff < 3} {return 1}} ; set floodprotect [clock seconds] ; return 0}
proc antifloodX {h} {global floodprotectX ; if {[matchattr $h n]} {return 0} ; if {[info exists floodprotectX]} {set diff [expr [clock seconds]-$floodprotectX] ; if {$diff < 5} {return 1} } ; set floodprotectX [clock seconds] ; return 0}
proc capitalize {sentence} {subst -nobackslashes -novariables [regsub -all {\S+} $sentence {[string totitle &]}]}
proc capitalizeX {sentence} {regsub -all -command {\S+} $sentence {string totitle}}
proc newline {input} {set j 0 ; set tempdef "" ; foreach line [split $input \n] {if {$line != ""} {set len 375 ; set splitChr " " ; set out [set cur {}]; set i 0 ; foreach word [split $line $splitChr] {if {[incr i [string len $word]]>$len} {lappend out [join $cur $splitChr] ; set cur [list $word] ; set i [string len $word] ; incr j} else {lappend cur $word} ; incr i} ; lappend out [join $cur $splitChr] ; foreach line2 $out {if {$j >= 1} {set line2 [linsert $line2 end] ; set j [expr $j -1]} ; lappend tempdef $line2}}} ; return $tempdef}
