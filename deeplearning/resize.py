#!/usr/bin/python
import numpy as np
from PIL import Image
import os
import cv2
import sys


################################################################################
#Script pour resize un repertoire d'images. par défaut : ./dataset/test/input
#                                                         et 256*256
################################################################################
def main(path_img,taille):
    dirs = os.listdir( path_img )
    for item in dirs:
        print(item)
        im = Image.open(path_img+item)
        f, e = os.path.splitext(path_img+item)
        imResize = im.resize((taille,taille), Image.ANTIALIAS)
        imResize.save(f+'.JPG', 'JPEG', quality=90)

if __name__ == "__main__":
    #path_img = os.path.join(os.getcwd(), 'dataset','test','input/')
    if(len(sys.argv)<2):
        path_img=os.path.join(os.getcwd(), 'dataset','test','input/')
        taille=256
        #print("path_img="+os.path.join(os.getcwd(), 'dataset','test','input/'))
        #print("taille=256")
    else:
        if(len(sys.argv)>2 and len(sys.argv)<4):
            path_img=sys.argv[1]
            taille=sys.argv[2]
            #print("path_img="+sys.argv[1])
            #print("taille="+sys.argv[2])
        else:
            print("utilisation : arg1=path to repository ; arg2=size of img")
    main(path_img,taille)
