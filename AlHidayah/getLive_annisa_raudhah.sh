#!/bin/bash
path_script="/home/deanet/bin/"
s3_access_key=`cat $path_script/api_key.txt | awk -F \: '{print $1}'`
s3_secret_key=`cat $path_script/api_key.txt | awk -F \: '{print $2}'`

url="http://api.justin.tv/api/channel/archives/raudhah.xml"
tanggal=`date +%Y-%-m-%-d`
#tanggal="2012-12-5"
det=`date +%m_%d_%Y`
#det="12_05_2012"


curl="/usr/bin/curl"

file="/tmp/anisaraudhah-$det.xml"
lists="/tmp/anisalistsraudhah-$det.txt"
$curl -v $url > $file

$curl "http://d.nabawiy.com/nabawiy.php" > /tmp/h.txt

hariH=`awk -F \; '{print $1}' /tmp/h.txt`
blnH=`awk -F \; '{print $2}' /tmp/h.txt`
thnH=`awk -F \; '{print $3}' /tmp/h.txt`

#hariH="21"
#blnH="Muharram"
#thnH="1434"



$curl "http://archive.org/details/annisa_${blnH}_${thnH}_nabawiy" > /tmp/11n

count=`cat $file | grep video_file_url | grep $tanggal | cut -d \> -f 2 | cut -d \< -f 1 | wc -l`

cat $file | grep video_file_url | grep $tanggal | cut -d \> -f 2 | cut -d \< -f 1 > $lists


for a in $(eval echo {1..$count});do

link=`cat $lists | tail -n $a | head -n 1`

namafile=`echo $link | awk -F / '{print $NF}'`
dotfile=`echo $namafile | cut -d \_ -f 4`
fixnamafile="Kajian_An_Nisa${hariH}${blnH}${thnH}_video_${det}_live${a}_user_raudhah_$dotfile"
#http://archive.org/download/annisa_kahfiid/Kajian_An_Nisa_video_06_20_2012_live_user_raudhah_1340183662.flv
/usr/bin/wget -c $link -O /tmp/$namafile -t 0

if [ -f /tmp/$namafile ];then


	cat /tmp/11n | grep "Item cannot be found"
	if [ "$?" == "0" ] ; then

	$curl -v --location --header 'x-amz-auto-make-bucket:1' \
	--header 'x-archive-meta01-collection:majelis-taklim' \
	--header 'authorization: LOW '${s3_access_key}':'${s3_secret_key}'' \
	--upload-file /tmp/$namafile http://s3.us.archive.org/annisa_${blnH}_${thnH}_nabawiy/$fixnamafile
	else

	$curl -v --location --header 'authorization: LOW '${s3_access_key}':'${s3_secret_key}'' \
	 --upload-file /tmp/$namafile http://s3.us.archive.org/annisa_${blnH}_${thnH}_nabawiy/$fixnamafile

	fi

#/usr/local/bin/curl -v --location --header 'authorization: LOW UzSG2GOEmmlFOwXi:UXzWENJrmd17cqtk' --upload-file /tmp/$namafile http://s3.us.archive.org/annisa_kahfiid/$fixnamafile



else
echo "file /tmp/$namafile doesnt exist"
fi

done
