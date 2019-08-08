#! /bin/bash
$pathToExcute=''
for fichier in ../../../DATA/PNG/sgm_mire/pixel_line/*
do
	if [[ $fichier != *"dec"* ]]
	then
      		./../build/MakeScale $(basename $fichier .${fichier##*.})
	fi
done
