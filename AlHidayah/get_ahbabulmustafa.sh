#!/bin/bash
path_script="/home/deanet/bin/"
s3_access_key=`cat $path_script/api_key.txt | awk -F \: '{print $1}'`
s3_secret_key=`cat $path_script/api_key.txt | awk -F \: '{print $2}'`


curl="/usr/bin/curl"

$curl "http://d.nabawiy.com/nabawiy.php" > /tmp/h.txt

hariH=`awk -F \; '{print $1}' /tmp/h.txt`
blnH=`awk -F \; '{print $2}' /tmp/h.txt`
thnH=`awk -F \; '{print $3}' /tmp/h.txt`

#hariH="21"
#blnH="Muharram"
#thnH="1434"

$curl "http://archive.org/details/ahbabulmosthofa_${blnH}_${thnH}_nabawiy" > /tmp/11n

#http://archive.org/download/arraudhah_kahfiid/Kajian_Ar_Raudhah_10_07_2011.mp3
#archive.org/details/ahbabulmosthofa_kahfiid
det=`date +%m_%d_%Y`

#det="12_05_2012"
namefile="Kajian_Ahbabul_MusthofaRaw${hariH}${blnH}${thnH}_${det}.mp3"
savefile="/tmp/$namefile"
/usr/bin/wget -b -c --tries=0 http://radio.alhidayah.info:1076 -O $savefile

sleep 12600;pkill wget;

if [ -f $savefile ]
then

	cat /tmp/11n | grep "Item cannot be found"
	if [ "$?" == "0" ] ; then

	$curl -vvv --location --header 'x-amz-auto-make-bucket:1' \
	--header 'x-archive-meta01-collection:majelis-taklim' \
	--header 'authorization: LOW '${s3_access_key}':'${s3_secret_key}'' \
	--upload-file $savefile http://s3.us.archive.org/ahbabulmosthofa_${blnH}_${thnH}_nabawiy/$namefile
	else

	$curl -vvv --location --header 'authorization: LOW '${s3_access_key}':'${s3_secret_key}'' \
	--upload-file $savefile http://s3.us.archive.org/ahbabulmosthofa_${blnH}_${thnH}_nabawiy/$namefile

	fi

else
	echo "file doesnt exist"
fi
