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
cd segment_flou/build/visu_EPS/
rm *.eps
cd ../../../
cd SCALE/
> echelle_computed_horizontal.txt
> echelle_computed_moyenne.txt
> echelle_computed_vertical.txt
cd ..
echo "-------------CLEAN completed"
