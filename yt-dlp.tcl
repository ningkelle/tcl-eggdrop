# apt update
# wget https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O /usr/bin/yt-dlp
# chmod a+rx /usr/bin/yt-dlp
# yt-dlp -vU
# apt install libimage-exiftool-perl
####################################
bind pub - .mp3 pub:mp3
proc pub:mp3 {n u h c t} {set t [stripcodes bcruag $t]; if {$t == ""} {putnow "privmsg $c :Usage : .mp3 <YouTube URL/Artis - Title>"; return}; dl:mp3 $n $c $t; return}
proc dl:mp3 {nick chan ytid} {
 putnow "PRIVMSG $chan :$nick : Ok! Download \00353mp3\003 sekarang."
 catch {exec yt-dlp --no-playlist --max-filesize 10m --restrict-filenames -f webm/m4a/aac -x --audio-format mp3 --audio-quality 128k --default-search "ytsearch" "$ytid" -o "/$path/%(title)s.%(ext)s"} donlot
 regexp -all -nocase {\[ExtractAudio\] Destination.*?/$path/(.*?)/(.*?)\.mp3} $donlot t link title
 regsub -all "\n" $donlot "" donlot
 regexp -all -nocase {YouTube said: (.*?)\.} $donlot t ytsaid ; if {[info exists ytsaid]} {putnow "privmsg $chan :\0034ERROR\:\003 $ytsaid"; return}
 if {[string match -nocase "*ile is larger than max-filesize*" $donlot]} {putnow "privmsg $chan :\0034ERROR\:\003 File too big - Max\00353 10MB\003"; return}
 if {[string match -nocase "*ERROR:*" $donlot]} {putnow "privmsg $chan :\0034ERROR\:\003 [string range $donlot [expr [string last ":" $donlot] + 2] end]"; return}
 if {[string match -nocase "*leting origin*" $donlot]} {
  set title "$title.mp3"
  set size [exec exiftool -FileSize -s /$path/$link/$title | sed {s/ //g} | sed {s/FileSize://g}]
  set length [exec exiftool -Duration -s /$path/$link/$title | sed {s/ //g} | sed {s/Duration://g} | sed {s/(approx)//g}]
  putnow "privmsg $chan :\037Complete:\037 https://web-server/$link/$title"
  putnow "privmsg $chan :\037FileSize:\037 $size \0034-\003 \037Duration:\037 $length"
  return 0
 }
 foreach line [split $donlot "\n"] {putlog $line}
 putnow "privmsg $chan :\0034ERROR\:\003 Unknown Result"
}
putlog "+++ yt-dlp TCL Loaded..."
