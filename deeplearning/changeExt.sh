#!/bin/bash

set -x

if [ $# -lt 1 ]
	then
	exit 2
fi

idir="../treetrace/matlab/datas/NeuralNetwork/"
odir="dataset/target"
for file in $*
do
	base=${file##*/}
	name=${base%.jpg}
	length=`echo $name | wc -c`
	#input_name=`echo $name | tail -c $(($length-9))`
	#echo $name
	cp "$idir/$name.jpg" "$odir/$name.csv"
done

exit 0