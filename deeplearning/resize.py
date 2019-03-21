#!/usr/bin/python
import numpy as np
from PIL import Image
import os
import cv2



def main(path_img):
    dirs = os.listdir( path_img )
    for item in dirs:
        print(item)
        im = Image.open(path_img+item)
        f, e = os.path.splitext(path_img+item)
        imResize = im.resize((256,256), Image.ANTIALIAS)
        imResize.save(f+'.JPG', 'JPEG', quality=90)

if __name__ == "__main__":
    path_img = os.path.join(os.getcwd(), 'dataset','test','input/')
    main(path_img)
