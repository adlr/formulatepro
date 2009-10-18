#!/bin/bash

# simple usage: $ ./release.sh -v 0.0.6

# $1 - source folder
# $2 - volume name
# $3 - output file

# for example:
# ./release.sh ./build/Release/FormulatePro.app FormulatePro-0.0.2 FormulatePro-0.0.2.dmg

if [ "$1" = "-v" ]; then
	SRC="./build/Release/FormulatePro.app"
	VOL="FormulatePro-$2"
	OUT="$VOL.dmg"
	VERS=$2
else
	SRC="$1"
	VOL="$2"
	OUT="$3"
fi

echo "SRC = '$SRC'"
echo "VOL = '$VOL'"
echo "OUT = '$OUT'"
echo Creating .dmg file
GZIP=-9 hdiutil create -fs HFS+ -srcfolder "$SRC" -volname "$VOL" "$OUT"
echo signing
SIG=$(ruby ./third_party/Sparkle/Extras/Signing\ Tools/sign_update.rb \
    "$OUT" ./dsa_priv.pem)
cat <<EOF
        <item>
            <title>Version $VERS</title>
            <description>http://adlr.info/appcasts/$VOL.html</description>
            <pubDate>$(date)</pubDate>
            <enclosure sparkle:version="$VERS"
                url="http://adlr.info/appcasts/$VOL.dmg"
                sparkle:dsaSignature="$SIG"
                length="$(stat -f "%z" "$OUT")"
                type="application/octet-stream"/>
        </item>
EOF
