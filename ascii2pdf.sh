#!/bin/sh -eu
# Script to render ASCII-Art to PDF 1.0.0, Copyright (c) 2022 Ma_Sys.ma.
# For further info send an e-mail to Ma_Sys.ma@web.de.

if [ $# -lt 2 ]; then
	cat <<EOF
USAGE $0 <FILE.txt> <FILE.pdf> [--asciistyle FILE.txt] 
                               [--pgo --OPTION VALUE...] [GLOBALWKHTMLTOPDF...]
Typical options --orientation Landscape --page-size A3 --asciistyle file.txt
EOF
	exit 1
fi

txt="$1"
pdf="$2"
stylefile=
font="/usr/share/texlive/texmf-dist/fonts/truetype/paratype/ptmono/PTM55F.ttf"
tmp="$(mktemp -d)"
css=
pagopts=

trap "rm -r \"$tmp\"" INT TERM EXIT

shift 2

if [ $# -ge 2 ] && [ "$1" = "--asciistyle" ]; then
	stylefile="$2"
	contentlines="$(wc -l < "$txt")"
	head -n "$contentlines" < "$stylefile" > "$tmp/asciistyle.txt"
	css="$(tail -n +$((contentlines + 1)) < "$stylefile")"
	shift 2
fi

while [ $# -ge 3 ] && [ "$1" = "--pgo" ]; do
	pagopts="$pagopts $2 $3"
	shift 3
done

cat > "$tmp/page.xhtml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
			"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>print</title>
<style type="text/css">
/* <![CDATA[ */
@font-face {
	font-family: "PTMono Regular";
	src: url("file://$font") format("truetype");
}
pre { font-family: "PTMono Regular"; font-size: 16px; }
.class_g { color: #00aa00; } /* green */
.class_G { color: #00cc00; }
.class_w { color: #777777; } /* white */
.class_y { color: #999900; } /* yellow */
.class_Y { color: #cccc00; }
.class_p { color: #990099; } /* pink/magenta */
.class_P { color: #ff00ff; }
.class_c { color: #008080; } /* cyan */
.class_C { color: #00aaaa; }
.class_r { color: #900000; } /* red */
.class_R { color: #ff0000; }
.class_b { color: #000090; } /* blue */
.class_B { color: #0000ff; }
$css
/* ]]> */
</style>
</head>
<body>
<pre>
EOF

if [ -f "$tmp/asciistyle.txt" ]; then
	awk '
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
		if(lchr == "&") {
			lchr = "&amp;"
		} else if(lchr == "<") {
			lchr = "&lt;"
		} else if(lchr == ">") {
			lchr = "&gt;"
		} else if(lchr == "\"") {
			lchr = "&quot;"
		} else if(lchr == "'\''") {
			lchr = "&apos;"
		}
		if(schr ~ /[a-zA-Z0-9]/) {
			printf "<span class=\"class_%c\">%s</span>", schr, lchr
		} else {
			printf "%s", lchr
		}
	}
	print ""
}
' "$stylefile" "$txt" >> "$tmp/page.xhtml"
else
	sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' \
			-e 's/"/\&quot;/g' < "$txt" >> "$tmp/page.xhtml"
fi

cat >> "$tmp/page.xhtml" <<EOF
</pre>
</body>
</html>
EOF

echo wkhtmltopdf "$@" "$tmp/page.xhtml" --allow "$font" $pagopts "$pdf"
wkhtmltopdf "$@" "$tmp/page.xhtml" --allow "$font" $pagopts "$pdf"
