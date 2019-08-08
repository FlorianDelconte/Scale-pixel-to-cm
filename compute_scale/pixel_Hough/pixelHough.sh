#! /bin/bash
#path_to_img="../../DATA/PNG/truth_ground/img/normal_size/"
path_to_img=$1
path_to_sgm="../IMG_SGM/"
path_to_write="../PIXELS/"
matlab -nodisplay -nodesktop -r "main('$path_to_img','$path_to_sgm','$path_to_write');exit"
