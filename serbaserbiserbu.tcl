# untuk menggunakan semua tcl disini, simpan file ini di dir scripts/
# lalu tambahkan di config : source scripts/serbaserbiserbu.tcl
####################################
package require Tcl
package require http
package require tls
package require json
package require textutil
# package require tdom
# package require eggdrop
http::register https 443 [list ::tls::socket -tls1 1 -ssl2 0 -ssl3 0 -autoservername 1]
http::config -proxyhost "" -useragent "IRCCloud/4.32.1 (iPhone; en-ID; iOS 18.6.2)"
proc formattedTXT {text} {regsub -all {\003([0-9]{1,2}(,[0-9]{1,2})?)?} $text "" text; regsub -all {[\002\037\026\035\017]} $text "" text; return $text}
proc commify {n {s ,} {g 3}} {regsub -all \\d(?=(\\d{$g})+([regexp -inline {\.\d*$} $n]$)) $n \\0$s}
proc noquote {t} {regsub -all {\."} $t {} t ; regsub -all {"}   $t {} t ; return $t}
proc capitalize {sentence} {subst -nobackslashes -novariables [regsub -all {\S+} $sentence {[string totitle &]}]}
proc newline {input} {return [split [textutil::adjust $input -length 350] \n]}
