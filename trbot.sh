#!/bin/bash
#autoid_bot

ftb=/usr/share/autoid_bot/
fPID=$ftb"pid.txt"
home_trbot=$ftb
starten=1

function Init2()
{
logger "init2 start"
token=$(sed -n 1"p" $ftb"settings.conf" | tr -d '\r')
echo "0" > $ftb"lastid.txt"
sec=$(sed -n 2"p" $ftb"settings.conf" | tr -d '\r')
sec4=$(sed -n "4p" $ftb"settings.conf" | tr -d '\r')
chat_id=$(sed -n "5p" $ftb"settings.conf" | tr -d '\r')
logger "init2 stop"
}

function logger()
{
local date1=`date '+ %Y-%m-%d %H:%M:%S'`
echo $date1" autoid_bot: "$1
}



roborob () 
{
otv=""

if [ "$text" = "/myid" ]; then
	echo "user_id="$user_id > $ftb"userid.txt"
	chat_id=$user_id
	otv=$ftb"userid.txt"
	send;
fi
if [ "$text" = "/id" ]; then
	echo "chat_id="$chat_id > $ftb"chatid.txt"
	otv=$ftb"chatid.txt"
	send;
fi

logger "roborob otv="$otv
}



send1 ()
{
logger "send1 start"
echo $chat_id > $ftb"send.txt"
echo $otv >> $ftb"send.txt"

rm -f $ftb"out.txt"
file=$ftb"out.txt"; 
$ftb"cucu2.sh" &
pauseloop;

if [ -f $ftb"out.txt" ]; then
	
	if [ "$(cat $ftb"out.txt" | grep ":true,")" ]; then
		logger "send1 OK"
	else
		logger "send1 file+, timeout.."
		sleep 2
	fi
else
	logger "send1 FAIL"
	if [ -f $ftb"cu2_pid.txt" ]; then
		logger "send1 kill cucu2"
		cu_pid=$(sed -n 1"p" $ftb"cu2_pid.txt" | tr -d '\r')
		killall cucu2.sh
		kill -9 $cu_pid
		rm -f $ftb"cu2_pid.txt"
	fi
fi

logger "send1 exit"
}


send ()
{
logger "send start"
rm -f $ftb"send.txt"

dl=$(wc -m $otv | awk '{ print $1 }')
echo "dl="$dl
if [ "$dl" -gt "4000" ]; then
	sv=$(echo "$dl/4000" | bc)
	logger "send sv="$sv
	$ftb"rex.sh" $otv
	
	for (( i=1;i<=$sv;i++)); do
		otv=$ftb"rez"$i".txt"
		send1;
		rm -f $ftb"rez"$i".txt"
	done
	
else
	send1;
fi
logger "send exit"
}




pauseloop () 
{
sec1=0
again0="yes"
while [ "$again0" = "yes" ]
do
sec1=$((sec1+1))
sleep 1
if [ -f $file ] || [ "$sec1" -eq "$sec" ]; then
	again0="go"
	logger "pauseloop sec1="$sec1
fi
done
}


input () 
{
logger "input start"

rm -f $ftb"in.txt"
file=$ftb"in.txt";
$ftb"cucu1.sh" &
pauseloop;

if [ -f $ftb"in.txt" ]; then
	if [ "$(cat $ftb"in.txt" | grep ":true,")" ]; then
		logger "input OK"
	else
		logger "input file+, timeout.."
		sleep 2
	fi
else	#подвис
	logger "input FAIL"
	if [ -f $ftb"cu1_pid.txt" ]; then
		logger "input kill cucu1"
		cu_pid=$(sed -n 1"p" $ftb"cu1_pid.txt" | tr -d '\r')
		#killall cucu1.sh
		kill -9 $cu_pid
		rm -f $ftb"cu1_pid.txt"
	fi
fi

logger "input exit"
}



starten_furer ()  				
{

if [ "$starten" -eq "1" ]; then
	logger "starten_furer starten=1"
	mess_id=$(cat $ftb"in.txt" | jq ".result[].update_id" | tail -1 | tr -d '\r')
	if [ -z "$mess_id" ]; then
		mess_id=0
	fi
	echo $mess_id > $ftb"lastid.txt"
	logger "starten_furer mess_id="$mess_id
	starten=0
fi

}


parce ()
{
logger "parce start"
mi_col=$(cat $ftb"in.txt" | grep -c update_id | tr -d '\r')
logger "parce col mi_col ="$mi_col
mess_id=$(sed -n 1"p" $ftb"lastid.txt" | tr -d '\r')

for (( i=0;i<=$mi_col;i++)); do
	i1=$((i-1))
	mi=$(cat $ftb"in.txt" | jq ".result[$i1].update_id" | tr -d '\r')

	[ -z "$mi" ] && mi=0
	[ "$mi" == "" ] && mi=0
	#[ "$mess_id" == null ] && mess_id=0
	[ "$mi" == null ] && mi=0
	
	logger "parce ffufuf mess_id="$mess_id", mi="$mi
	if [ "$mess_id" -ge "$mi" ] || [ "$mi" -eq "0" ]; then
		ffufuf=1
		else
		ffufuf=0
	fi
	logger "parce ffufuf ffufuf="$ffufuf
	
	if [ "$ffufuf" -eq "0" ]; then
		user_id=$(cat $ftb"in.txt" | jq ".result[$i1].message.from.id" | tr -d '\r')
		chat_id=$(cat $ftb"in.txt" | jq ".result[$i1].message.chat.id" | tr -d '\r')
		logger "parce user_id="$user_id", chat_id="$chat_id
		text=$(cat $ftb"in.txt" | jq ".result[$i1].message.text" | sed 's/\"/ /g' | sed 's/^[ \t]*//;s/[ \t]*$//' | tr -d '\r')
		logger "parce text="$text
		roborob;
		mess_id=$mi
	fi
done
echo $mi > $ftb"lastid.txt"
logger "parce stop"
}



if ! [ -f $fPID ]; then		#-----------------------
	PID=$$
	echo $PID > $fPID
	logger "start bot"
	Init2;
	starten_furer;
	otv=$ftb"start.txt"; send;

	while true
	do
		input;
		parce;
		logger "sleep "$sec4" sec"
		sleep $sec4
	done
else
	logger "pid up exit"
fi #-----------------------

rm -f $fPID

