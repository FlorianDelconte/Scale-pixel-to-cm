import numpy as np
import os
import sys
import cv2
import matplotlib.pyplot as plt

c =119
def main(path_img):
    dirs = os.listdir( path_img )
    for item in dirs:
        print(item)
        im = Image.open(path_img+item)
        imBinaire=cv2.threshold(im, seuil ,255,cv2.THRESH_BINARY)
        imBinaire.save(f+e, 'JPEG', quality=100)
        
if __name__ == '__main__':
    if( len(sys.argv)==2):
        path_image=sys.argv[1]
    else:
        print("arg 1 : path image ")
    main(path_image)
