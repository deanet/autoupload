#!/bin/bash
path_script="/home/deanet/bin/"
s3_access_key=`cat $path_script/api_key.txt | awk -F \: '{print $1}'`
s3_secret_key=`cat $path_script/api_key.txt | awk -F \: '{print $2}'`

url="http://api.justin.tv/api/channel/archives/raudhah.xml"
file="/tmp/raudhah.xml"
lists="/tmp/listsraudhah.txt"
tanggal=`date +%Y-%-m-%-d`
#anggal="2012-11-23"
det=`date +%m_%d_%Y`
#det="11_23_2012"

curl="/usr/bin/curl"

$curl -v $url > $file


$curl "http://d.nabawiy.com/nabawiy.php" > /tmp/h.txt

hariH=`awk -F \; '{print $1}' /tmp/h.txt`
blnH=`awk -F \; '{print $2}' /tmp/h.txt`
thnH=`awk -F \; '{print $3}' /tmp/h.txt`


$curl "http://archive.org/details/arraudhah_${blnH}_${thnH}_nabawiy" > /tmp/11n


count=`cat $file | grep video_file_url | grep $tanggal | cut -d \> -f 2 | cut -d \< -f 1 | wc -l`

cat $file | grep video_file_url | grep $tanggal | cut -d \> -f 2 | cut -d \< -f 1 > $lists


for a in $(eval echo {1..$count});do

link=`cat $lists | tail -n $a | head -n 1`

namafile=`echo $link | awk -F / '{print $NF}'`
dotfile=`echo $namafile | cut -d \_ -f 4`
#det="11_16_2012"
fixnamafile="Kajian_Ar_Raudhah${hariH}${blnH}${thnH}_video_${det}_live${a}_user_raudhah_$dotfile"

/usr/bin/wget -c $link -O /tmp/$namafile -t 0

if [ -f /tmp/$namafile ];then

	cat /tmp/11n | grep "Item cannot be found"
	if [ "$?" == "0" ] ; then

	$curl -v --location --header 'x-amz-auto-make-bucket:1' \
	--header 'x-archive-meta01-collection:majelis-taklim' \
	--header 'authorization: LOW '${s3_access_key}':'${s3_secret_key}'' \
	--upload-file /tmp/$namafile http://s3.us.archive.org/arraudhah_${blnH}_${thnH}_nabawiy/$fixnamafile
	else

	$curl -v --location --header 'authorization: LOW '${s3_access_key}':'${s3_secret_key}'' \
	--upload-file /tmp/$namafile http://s3.us.archive.org/arraudhah_${blnH}_${thnH}_nabawiy/$fixnamafile

	fi


#/usr/local/bin/curl -v --location --header 'authorization: LOW UzSG2GOEmmlFOwXi:UXzWENJrmd17cqtk' --upload-file /tmp/$namafile http://s3.us.archive.org/arraudhah_1434H/$fixnamafile

else
echo "file /tmp/$namafile doesnt exist"
fi


done
