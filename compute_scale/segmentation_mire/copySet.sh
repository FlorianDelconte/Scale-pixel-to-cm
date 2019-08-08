#!/bin/bash

set -x

if [ $# -lt 1 ]
	then
	exit 2
fi

idir="../Echantillonnage/Epicéa/Log_ends_Corcieux_Huawei_renommes"
odir="dataset/huawei"
for file in $idir/*.jpg
do
	if [ -f $file ]
		then
		base=${file##*/}
		name=${base%.jpg}
		#length=`echo $name | wc -c`
		#input_name=`echo $name | tail -c $(($length-9))`
		cp "$idir/$name.jpg" "$odir/corcieux_$name.jpg"
	fi
done

exit 0