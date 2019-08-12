#! /bin/bash
# Make segmentation from path_to_img to path_to_sgm
#path_to_img="./../../DATA/PNG/truth_ground/img/normal_size/"
path_to_img="$1"
path_to_venv="./venv/bin/activate"
#path to output segmentation mire
path_to_sgm="./../IMG_SGM/"

source $path_to_venv
python3 predict.py $path_to_img $path_to_sgm
