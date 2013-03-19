#!/bin/bash

## uploading to google
## rev: 22 Aug 2012 16:07

markas="/home/clients/websites/w_syafaa/"

/usr/bin/crontab -l > $markas/crontab.txt

det=`date +%F`
/bin/mkdir /tmp/.bekap/
/bin/tar -cvf /tmp/.bekap/config-$det.tar $markas/* $markas/.htpasswd $markas/.muttrc $markas/.ssh/;

browser="Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:13.0) Gecko/20100101 Firefox/13.0.1"
username="backup@deanet.web.id"
password="password"
accountype="HOSTED" #gooApps = HOSTED , gmail=GOOGLE
pewede="/tmp"
file="$pewede/.bekap/config-$det.tar"
tipe="application/x-tar"

/usr/local/bin/curl -v --data-urlencode Email=$username --data-urlencode Passwd=$password -d accountType=$accountype -d service=writely -d source=cURL "https://www.google.com/accounts/ClientLogin" > $pewede/login.txt

token=`cat $pewede/login.txt | grep Auth | cut -d \= -f 2`

#/usr/bin/curl -L -v --header "Authorization: GoogleLogin auth=${token}" -d service=folder -d mimeType=application%2Fvnd.google-apps.folder "https://docs.google.com/feeds/documents/private/full" > $pewede/list.txt

#/usr/bin/curl -L -v --header "Authorization: GoogleLogin auth=${token}" "https://docs.google.com/feeds/default/private/full/folder%3Aroot" > archive.txt

#https://docs.google.com/feeds/documents/private/full/folder%3A0B3VeMFQ6ZgBULTJhOER5elZ4ZXM

uploadlink=`/usr/local/bin/curl -Sv -k --request POST  -H "Content-Length: 0" -H "Authorization: GoogleLogin auth=${token}" -H "GData-Version: 3.0" -H "Content-Type: $tipe" -H "Slug: backup-w_syafaa-$det.tar" "https://docs.google.com/feeds/upload/create-session/default/private/full?convert=false" -D /dev/stdout | grep "Location:" | sed s/"Location: "//`

/usr/local/bin/curl -Sv -k --request POST --data-binary "@$file" -H "Authorization: GoogleLogin auth=${token}" -H "GData-Version: 3.0" -H "Content-Type: $tipe" -H "Slug: backup-w_syafaa-$det.tar" "$uploadlink" > $pewede/goolog.upload.txt

##uploadlink=`/usr/bin/curl -Sv -k --request POST  -H "Content-Length: 0" -H "Authorization: GoogleLogin auth=${token}" -H "GData-Version: 3.0" -H "Content-Type: $tipe" -H "Slug: $file" "https://docs.google.com/feeds/default/private/full/-/folder?title=$file&title-exact=true" -D /dev/stdout | grep "Location:" | sed s/"Location: "//`

##/usr/bin/curl -Sv -k --request POST --data-binary "@$file" -H "Authorization: GoogleLogin auth=${token}" -H "GData-Version: 3.0" -H "Content-Type: $tipe" -H "Slug: $file" "$uploadlink" > $pewede/goolog.upload.txt





#id=`/usr/local/bin/tidy -xml -indent -quiet $pewede/goolog.upload.txt | grep "ccc" | grep output | cut -d \= -f 3 | cut -d \& -f 1`

#echo "File $file: https://docs.google.com/a/redawning.com/spreadsheet/ccc?key=$id";

#/usr/bin/curl -v https://www.google.com/accounts/ClientLogin --data-urlencode Email=$username --data-urlencode Passwd=$password -d accountType=HOSTED -d service=wise -d source=cURL > $pewede/logindlspread.txt

#dltoken=`cat $pewede/logindlspread.txt | grep Auth | cut -d \= -f 2`

#/usr/bin/curl -L -v  --header "Authorization: GoogleLogin auth=${dltoken}" "https://spreadsheets.google.com/feeds/download/spreadsheets/Export?key=$id&exportFormat=xls&format=xls" > /tmp/$filedl

#/usr/bin/mutt -s "$region SynCal Report - $det"  -a /tmp/$filedl dian.griyana@redawning.com <  /dev/null

rm -rf /tmp/.bekap/
