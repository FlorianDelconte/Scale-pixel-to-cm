#! /bin/bash
$pathToExcute=''
for fichier in ../../../DATA/PNG/sgm_mire/pixel_line/* 
do
	if [[ $fichier == *"dec"* ]]
	then
        	echo "nope"
	else
		./../build/makeSgmFlou $(basename $fichier .${fichier##*.})
	fi
done
