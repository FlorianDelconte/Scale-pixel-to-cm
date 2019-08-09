#! /bin/bash
#clean temp file like Segmented mire, pixel.dat and visual eps.
echo "-------------CLEAN"
echo "..."
cd IMG_SGM/
rm *.png
rm *.JPG
rm *.jpg
cd ..
cd PIXELS/
rm *.dat
cd ..
cd segment_flou/src/visu_EPS/
rm *.eps
cd ../../../
cd SCALE/
rm *.txt
cd ..
echo "-------------CLEAN completed"
