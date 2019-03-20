#!/bin/bash 

set -x 

image_dir="./dataset/images"
filtr_dir="./dataset/selected"


csv="../pith_location_spruce.csv"
list=`cat $csv | cut -d "," -f1`

for img in $list
do
	x=`echo $img | tr -d "\""`
	cp $image_dir/$x $filtr_dir/$x
done

exit 0