#!/bin/sh -eu

if ! [ $# = 2 ]; then
	echo "Usage $0 in out"
	exit 1
fi

exec gs -dBATCH -dNOPAUSE -dNOCACHE -sProcessColorModel=DeviceRGB \
	-dNOOUTERSAVE -sOutputFile="$2" -dPDFSETTINGS=/prepress \
	-dMonoImageResolution=600 -r150 -dSAFER -dMaxInlineImageSize=16384 \
	-dDetectDuplicateImages -sDEVICE=pdfwrite "$1"
