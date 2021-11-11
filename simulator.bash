#!/usr/bin/bash

home=/data
cat /dev/urandom | tr -dc "[:space:][:print:]" | head -c $(shuf -e 10000 100000 1000000 100000000 -n 1) > $home/binFile.bin;
cat /dev/urandom | tr -dc "[:space:][:print:]" | head -c $(shuf -e 10000 100000 1000000 100000000 -n 1) > $home/textFile.bin;

file0="/dev/null";
file=$home/$(date +'%Y%m%d_%H%M%S_%N');

ft0=$file0;
ft1=$file"_type1";
ft2=$file"_type2";
ft3=$file"_type3";
ft4=$file"_type4";

#higher the number of novar less variability
novarbin=$(shuf -i 3-50 -n 1)
novartext=$(shuf -i 3-50 -n 1)

var1=$(shuf -i 5-$novartext -n 1);
counter1=0;

var2=$(shuf -i 5-$novarbin -n 1);
counter2=0;

var3=$(shuf -i 5-10 -n 1);
counter3=0;

dataset=1;

while true; do

	echo
	echo "Generating dataset: "$dataset
    echo "-----------------------"

	#files that are part similar and part diffent (TXT)
    echo -n $ft1;
	cat /dev/urandom | tr -dc "[:space:][:print:]" | head -c $(shuf -e 500 1000 5000 10000 20000 100000 1000000 -n 1) > $ft1;
	ps -ef >> $ft1;
	journalctl -o verbose >> $ft1;
	size=$(cat $ft1 | wc -c);
	echo -n "--> "$(numfmt --to=si $size);

	diff=$(diff $ft0 $ft1 | wc -c;)
	perc=$(echo "scale=2;100 - $diff/$(cat $ft1 | wc -c) * 100; scale=0"| bc)%
    echo "   diff: "${perc#-}
	ft0=$ft1;

	file=$home/$(date +'%Y%m%d_%H%M%S_%N');
	ft1=$file"_type1";

	#files that are part similar and part diffent (TXT+BIN)
	echo -n $ft2;
	cat /dev/urandom | head -c $(shuf -e 500 1000 5000 10000 100000 -n 1) > $ft2;
	size=$(cat $ft2 | wc -c);
	echo "--> "$(numfmt --to=si $size);
	ps -ef >> $ft2;
	ft2=$file"_type2";

    #files that are equals (TXT)
	ft3=$file"_type3";
	/usr/bin/cp $home/textFile.bin $ft3;
	#~ echo $textFile > $ft3;
	size=$(cat $ft3 | wc -c);
	echo -n $ft3;
	echo "--> "$(numfmt --to=si $size);

	let counter1=counter1+1;
	#change content of file every var1 times
	if [[ $counter1 -gt $var1 ]]; then
	   echo
	   echo "------------------"
	   echo "changing textfile!";
	   echo "------------------"
	   echo
	   textFile=$(cat /dev/urandom | tr -dc "[:space:][:print:]" | head -c $(shuf -e 10000 100000 1000000 100000000 -n 1));
	   var1=$(shuf -i 5-$novartext -n 1)
       counter1=0
	fi


    #files that are equals (BIN)
	ft4=$file"_type4";
	/usr/bin/cp  $home/binFile.bin $ft4;
	size=$(cat $ft4 | wc -c);
	echo -n $ft4;
	echo "--> "$(numfmt --to=si $size);

	let counter2=counter2+1;
	#change content of file every var2 times
	if [[ $counter2 -gt $var2 ]]; then
	   echo
	   echo "------------------"
	   echo "changing binfile!";
	   echo "------------------"
	   echo
	   cat /dev/urandom | tr -dc "[:space:][:print:]" | head -c $(shuf -e 10000 100000 1000000 100000000 -n 1) > $home/binFile.bin;
	   var2=$(shuf -i 5-$novarbin -n 1)
       counter2=0
	fi

    #lets change the variability to simulate more or less users dinamically
	let counter3=counter3+1;
	if [[ $counter3 -gt $var3 ]]; then
	   echo
	   echo "---------------------"
	   echo "changing variability!";
	   echo "---------------------"
	   echo
       novarbin=$(shuf -i 6-50 -n 1)
       novartext=$(shuf -i 6-50 -n 1)
       counter3=0
	fi


	let dataset=dataset+1

done
Copy & paste the above script to a file and change the permissions to executable. Then run it.. .please just be sure that the vdo volume is mounted in /data.

You can also copy & paste directly on to a terminal to execute it.

In another terminal accessing the same host you can execute the following script to evaluate the use of the disk and the optimization ratio reported by vdstats.

clear;
while true; do
   df -kh /data;
   echo ---;
   sudo vdostats --verbose | head -16;
   echo “---”;
   vdostats --hu ;
   echo "---";ls /data | wc -l;
   sleep 8;
   clear;
done
