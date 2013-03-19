#!/bin/bash
export TZ="/usr/share/zoneinfo/Asia/Jakarta"
path_script="/home/alfaqir/bin/"
s3_access_key=`cat $path_script/api_key.txt | awk -F \: '{print $1}'`
s3_secret_key=`cat $path_script/api_key.txt | awk -F \: '{print $2}'`

rm -f /tmp/ahadpagi.txt

curl="/usr/bin/curl"
identifier="MutiaraPagiKalamSalaf"
rtmp_stream_url="http://radio.suaranabawiy.com:8872/"
#stream_url="http://stream.radiodakwahmustofa.com:8726/"
batasHours="0600"

#$curl "http://d.nabawiy.com/nabawiy.php" > /tmp/h.txt
cp "/home/alfaqir/www/alfaqir/nabawiy.php" /tmp/h.txt

hariH=`awk -F \; '{print $1}' /tmp/h.txt`
blnH=`awk -F \; '{print $2}' /tmp/h.txt`
thnH=`awk -F \; '{print $3}' /tmp/h.txt`


$curl "http://archive.org/details/${identifier}_${blnH}_${thnH}_nabawiy" > /tmp/11n

##det=`date +%m_%d_%Y`
##namefile="Kajian_MutiaraPagiKalamSalaf_SuaraNabawiyLive${hariH}${blnH}${thnH}_${det}.flv"
##savefile="/home/alfaqir/raw/$namefile"

det=`date +%m_%d_%Y`
namefile="Kajian_MutiaraPagiKalamSalaf_SuaraNabawiyLive"
tanggal="${hariH}${blnH}${thnH}_${det}"
dotfile="flv"



##recuring
##if [ -f "$savefile" ]; then
##rm $savefile;
##fi

#head -n 1 $savefile | grep "ICY 200 OK" ; 
##grep FLV ${savefile}


##until [ "$?" == "0" ]; 
##do 
##	echo "stream belum tersedia $?";
#	pkill wget;
##	sleep 3;
##	rm $savefile;
##	rm ${savefile}.log;
#	/usr/bin/wget -b --tries=1 $stream_url -O $savefile -o ${savefile}.log
##rtmpdump -r rtmp://videostream.indostreamserver.com/sunniyah/ -a sunniyah -y live -W http://live.sunniyahsalafiyah.net/jwplayer/player.swf -p http://live.sunniyahsalafiyah.net -f "LNX 11,2,202,258" -o ${savefile} -V
##	sleep 3;
	#head -n 1 $savefile | grep "ICY 200 OK" ; 
##	grep FLV ${savefile}
##done
#echo "$? OK , lets count the time"
path_save="$path_script/Majelis/SN/AhadPagi_${blnH}_${thnH}"

if [ ! -d "$path_save" ];then
mkdir -p "$path_save";
fi

Hours=`date +%H%M`
savefile="${path_save}/${namefile}_${Hours}_${tanggal}.${dotfile}"

until [ "$Hours" -gt "$batasHours" ];
do
	echo "masih jam $Hours";
#	sleep 60;
rtmpdump -r rtmp://videostream.indostreamserver.com/sunniyah/ -a sunniyah -y live -W http://live.sunniyahsalafiyah.net/jwplayer/player.swf -p http://live.sunniyahsalafiyah.net -f "LNX 11,2,202,258" -o ${savefile} -V
        if [ -s "${savefile}" ];then
        echo "${savefile}" >> /tmp/ahadpagi.txt
        else
                rm "${savefile}";
        fi
        Hours=`date +%H%M`
        savefile="${path_save}/${namefile}_${Hours}_${tanggal}.${dotfile}"

##	Hours=`date +%H%M`

done
pkill rtmpdump;
echo "kill rtmpdump jam $Hours"

count=`wc -l /tmp/ahadpagi.txt | awk '{print $1}'`
for a in $(eval echo {1..$count});do

file_loc=`cat /tmp/ahadpagi.txt | head -n $a | tail -n 1`



if [ -f $file_loc ] ; then

	cat /tmp/11n | grep "Item cannot be found"
	if [ "$?" == "0" ] ; then

	$curl -vvv --location --header 'x-amz-auto-make-bucket:1' \
	--header 'x-archive-meta-description: Ini adalah arsip raw shoutcast bulan '${blnH}' '${thnH}' Kajian Mutiara Pagi Kalam Salaf di SuaraNabawiy.com setiap bakda Subuh sampai selesai di hari Ahad (LIVE), rabu (LIVE), setiap pukul 07.00 sampai 08.00 di hari Senin dan Selasa' \
	--header 'x-archive-meta01-collection:majelis-taklim' \
	--header 'authorization: LOW '${s3_access_key}':'${s3_secret_key}'' \
	--upload-file $file_loc http://s3.us.archive.org/${identifier}_${blnH}_${thnH}_nabawiy/${namefile}${a}_${tanggal}.${dotfile}
	else

	$curl -vvv --location --header 'authorization: LOW '${s3_access_key}':'${s3_secret_key}'' \
	--upload-file $file_loc http://s3.us.archive.org/${identifier}_${blnH}_${thnH}_nabawiy/${namefile}${a}_${tanggal}.${dotfile}

	fi


else
	echo "file doesnt exist"
fi


done
