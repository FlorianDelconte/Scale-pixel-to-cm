import numpy as np
from PIL import Image
import os
import sys
import cv2
import matplotlib.pyplot as plt

seuil =125
def main(path_img):
    dirs = os.listdir( path_img )
    for item in dirs:
        print(item)
        f, e = os.path.splitext(path_img+item)
        im = cv2.imread(path_img+item,0)
        #_,imBinaire=cv2.threshold(im, seuil ,255,cv2.THRESH_BINARY)
        _,imBinaire=cv2.threshold(im, 0 ,255,cv2.THRESH_BINARY+cv2.THRESH_OTSU)
        #imBinaire.save(f+e, 'JPEG', quality=100)
        cv2.imwrite(f+e,imBinaire)

if __name__ == '__main__':
    if( len(sys.argv)==2):
        path_image=sys.argv[1]
    else:
        print("arg 1 : path image ")
    main(path_image)
