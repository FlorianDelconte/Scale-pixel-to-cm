#!/usr/bin/python
import numpy as np
from PIL import Image
import os
import cv2
import sys, getopt


################################################################################
#Script pour resize un repertoire d'images. par defaut : ./dataset/test/input
#                                                         et 256*256
################################################################################

path_imgTruth = "../DATA/PNG/truth_ground/img/normal_size/"
path_imgTest = "../DATA/PNG/truth_ground/img/test/R/"
path_destination = "../DATA/PNG/truth_ground/img/test/R/"
taille=0
up=0
def main(path_img):
    if(up==0):
        resize_down(path_img)
    else:
        resize_up()

def resize_down(path_img):
    dirs = os.listdir( path_img )
    for item in dirs:
        print(item)
        im = cv2.imread(path_img+item)
        f, e = os.path.splitext(path_img+item)
        imResize =  cv2.resize(im,(taille,taille),interpolation =cv2.INTER_NEAREST)#INTER_NEAREST for binaire et INTER_AREA for rgb
        #imResize.save(f+e, 'JPEG', quality=100)
        cv2.imwrite(f+e,imResize)

def resize_up():
    dirs_truth = os.listdir( path_imgTruth )
    dirs_test = os.listdir( path_imgTest )
    #parcours de la la verite terrain pour obtenir la taille des img vers les quelles ont veut resize
    for item in dirs_truth:
        print(item)
        #on lit l image de verité
        im_truth = cv2.imread(path_imgTruth+item)
        #on lit l image de test
        im_test = cv2.imread(path_imgTest+item)
        #on recupère la taille de l image verite courrante
        width, height = im_truth.shape[:2]
        #on resize l image test dans la taille de l image verite
        im_test_resize =  cv2.resize(im_test,(height,width),interpolation =cv2.INTER_NEAREST)#INTER_NEAREST for binaire et INTER_AREA for rgb
        cv2.imwrite(path_destination+item,im_test_resize)


if __name__ == "__main__":
    #path_img = os.path.join(os.getcwd(), 'dataset','test','input/')
    path_img=""
    try:
      opts, args = getopt.getopt(sys.argv[1:],"hp:s:u",["path=","taille=","up="])
    except getopt.GetoptError:
        print("resize.py -p <path to repository> -s <size>")
        print("OR")
        print("resize.py -u")
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print("resize.py -p <path to repository> -s <size>")
            print("OR")
            print("resize.py -u")
            sys.exit()
        elif opt in ("-s", "--taille"):
            taille=int(arg)
        elif opt in ("-p", "--path"):
            path_img=arg
        elif opt in ("-u", "--up"):
            up=1
    main(path_img)
