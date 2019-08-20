#! /bin/bash
path_to_img="$1"
echo $path_to_img
path_to_sgm="../IMG_SGM/"
path_to_write="../PIXELS/"
matlab -nodisplay -nodesktop -r "main('$path_to_img','$path_to_sgm','$path_to_write');exit"
