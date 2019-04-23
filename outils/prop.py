#!/usr/bin/python
import numpy as np
from PIL import Image
import os
import cv2
import sys, getopt


def main(path_img):
    dirs = os.listdir( path_img )
    for item in dirs:
        print(item)
        im = cv2.imread(path_img+item)
        nbPixBlanc=np.count_nonzero(im)
        width, height = im.shape[:2]
        nbPix=width*height
        print(nbPixBlanc/nbPix)
if __name__ == "__main__":
    path_img=""
    try:
      opts, args = getopt.getopt(sys.argv[1:],"hp:",["path="])
    except getopt.GetoptError:
        print("prop.py -p <path to repository>")
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print("prop.py -p <path to repository>")
            sys.exit()
        elif opt in ("-p", "--path"):
            path_img=arg
    main(path_img)
