#!/usr/bin/awk -f
# Ma_Sys.ma script to colorize ASCII-art files by stylesheet 1.0.0
# Copyright (c) 2022 Ma_Sys.ma.
# For further info send an e-mail to Ma_Sys.ma@web.de.
#
# USAGE $0 STYLE.txt DATA.txt
#
NR == FNR {
	# first pass is over stylesheet
	stylesheet[FNR] = $0
	next
}
{
	# second pass is over file contents
	line = $0
	llen = length(line)
	for(i = 1; i <= llen; i++) {
		schr = substr(stylesheet[FNR], i, 1) # style character
		lchr = substr(line, i, 1)            # line character
		sesc = ""

		# green
		if(schr == "g") {
			sesc = "\033[32m"
		} else if(schr == "G") {
			sesc = "\033[1;32m"
		# white/black
		} else if(schr == "w") {
			sesc = "\033[1;37m"
		} else if(schr == "k") {
			sesc = "\033[1;30m"
		# yellow
		} else if(schr == "y") {
			sesc = "\033[33m"
		} else if(schr == "Y") {
			sesc = "\033[1;33m"
		# pink/magenta
		} else if(schr == "p") {
			sesc = "\033[35m"
		} else if(schr == "P") {
			sesc = "\033[1;35m"
		# red
		} else if(schr == "r") {
			sesc = "\033[31m"
		} else if(schr == "R") {
			sesc = "\033[1;31m"
		# blue
		} else if(schr == "b") {
			sesc = "\033[34m"
		} else if(schr == "B") {
			sesc = "\033[1;34m"
		# cyan
		} else if(schr == "c") {
			sesc = "\033[36m"
		} else if(schr == "C") {
			sesc = "\033[1;36m"
		}
		
		if(sesc != "") {
			printf "%s%s\033[0m", sesc, lchr
		} else {
			printf "%s", lchr
		}
	}
	print ""
}
