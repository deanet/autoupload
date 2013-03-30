#!/bin/bash
export TZ="/usr/share/zoneinfo/Asia/Jakarta"
path_script="/home/alfaqir/bin/"
path_hum="/home/alfaqir/"

s3_access_key=`cat $path_script/api_key.txt | awk -F \: '{print $1}'`
s3_secret_key=`cat $path_script/api_key.txt | awk -F \: '{print $2}'`


curl="/usr/bin/curl"
identifier="MutiaraPagiKalamSalaf"
stream_url="http://radio.suaranabawiy.com:8872/"
#stream_url="http://stream.radiodakwahmustofa.com:8726/"
batasHours="0810"

#$curl "http://d.nabawiy.com/nabawiy.php" > /tmp/h.txt
cp "/home/alfaqir/www/alfaqir/nabawiy.php" /tmp/h.txt

hariH=`awk -F \; '{print $1}' /tmp/h.txt`
blnH=`awk -F \; '{print $2}' /tmp/h.txt`
thnH=`awk -F \; '{print $3}' /tmp/h.txt`


$curl "http://archive.org/details/${identifier}_${blnH}_${thnH}_nabawiy" > /tmp/11n

det=`date +%m_%d_%Y`
namefile="Kajian_MutiaraPagiKalamSalaf_SuaraNabawiyRaw${hariH}${blnH}${thnH}_${det}.mp3"
#savefile="/home/alfaqir/rabu/$namefile"
path_save="$path_hum/Majelis/SN/Madros_${blnH}_${thnH}"
savefile="${path_save}/${namefile}"

if [ ! -d "$path_save" ];then
mkdir -p "$path_save";
fi




##recuring
if [ -f "$savefile" ]; then
rm $savefile;
fi

head -n 1 $savefile | grep "ICY 200 OK" ; 

until [ "$?" == "0" ]; 
do 
	echo "ICY 401 Service unavail $?";
#	pkill wget;
	sleep 3;
	rm $savefile;
	rm ${savefile}.log;
	/usr/bin/wget -b --tries=1 $stream_url -O $savefile -o ${savefile}.log
	sleep 3;
	head -n 1 $savefile | grep "ICY 200 OK" ; 
done
echo "$? OK , lets count the time"

Hours=`date +%H%M`
until [ "$Hours" -gt "$batasHours" ];
do
	echo "masih jam $Hours";
	sleep 60;
	Hours=`date +%H%M`

done
pkill wget;
echo "kill wget jam $Hours"

if [ -f $savefile ] ; then

	cat /tmp/11n | grep "Item cannot be found"
	if [ "$?" == "0" ] ; then

	$curl -vvv --location --header 'x-amz-auto-make-bucket:1' \
	--header 'x-archive-meta-description: Ini adalah arsip raw shoutcast bulan '${blnH}' '${thnH}' Kajian Mutiara Pagi Kalam Salaf di SuaraNabawiy.com setiap bakda Subuh sampai selesai di hari Ahad, setiap pukul 07.00 sampai 08.00 di hari Senin dan Selasa' \
	--header 'x-archive-meta01-collection:majelis-taklim' \
	--header 'authorization: LOW '${s3_access_key}':'${s3_secret_key}'' \
	--upload-file $savefile http://s3.us.archive.org/${identifier}_${blnH}_${thnH}_nabawiy/$namefile
	else

	$curl -vvv --location --header 'authorization: LOW '${s3_access_key}':'${s3_secret_key}'' \
	--upload-file $savefile http://s3.us.archive.org/${identifier}_${blnH}_${thnH}_nabawiy/$namefile

	fi


else
	echo "file doesnt exist"
fi
