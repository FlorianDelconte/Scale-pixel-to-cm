#!/usr/bin/python
import numpy as np
from PIL import Image
import os
import cv2
import sys


################################################################################
#Script pour resize un repertoire d'images. par defaut : ./dataset/test/input
#                                                         et 256*256
################################################################################
def main(path_img,taille):
    dirs = os.listdir( path_img )
    for item in dirs:
        print(item)
        im = Image.open(path_img+item)
        f, e = os.path.splitext(path_img+item)
        imResize = im.resize((taille,taille),cv2.INTER_AREA)#INTER_NEAREST for binaire et INTER_AREA for rgb
        imResize.save(f+e, 'JPEG', quality=100)

if __name__ == "__main__":
    #path_img = os.path.join(os.getcwd(), 'dataset','test','input/')
    if(len(sys.argv)<2):
        path_img=os.path.join(os.getcwd(), '..','DATA','test','256_256','input/')
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
    main(path_img,int(taille))
