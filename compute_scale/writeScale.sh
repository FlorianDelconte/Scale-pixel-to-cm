#! /bin/bash
#execute all other bash script to compute scale for an input path of image
#---------------------------------------------------------#
#path to image you want scale
path_to_img="$1"
path_to_img_subDir="../$path_to_img"
#---------------------------------------------------------#
echo "-------------TENSORFLOW/KERAS: U-NET for SEGMENTATION"
cd segmentation_mire/
time . ./segmentation.sh $path_to_img_subDir
cd ../
echo "-------------MATLAB: HOUGH-SPACE to extract PIXEL LINE"
cd pixel_Hough/
time . ./pixelHough.sh $path_to_img_subDir
cd ../
echo "-------------DGTAl: Segment flou to compute scale"
cd segment_flou/build/
time ./MakeScale
cd ../
echo "FINISH : scale is in SCALE repository"
