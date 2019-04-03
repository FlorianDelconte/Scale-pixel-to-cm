import numpy as np
import os
import sys
import cv2
import matplotlib.pyplot as plt

##############################
#Classe python qui permet d'ajouter un l'images segmenté sur l'image normal
##############################

class Comparator:
    def __init__(self,path_i,path_iSeg,path_dest):
        self.path_dest=path_dest
        #chemin des repertoire qui contient les images et les images segmented
        self.path_image=path_i
        self.path_imageSeg=path_iSeg
        #self.path_dest=path_dest
        #liste des images
        self.list_img=[]
        for element in os.listdir(self.path_image):
            self.list_img.append(element)
        self.list_img=sorted(self.list_img)
        #liste des images segmenté
        self.list_imgSeg=[]
        for element in os.listdir(self.path_imageSeg):
            self.list_imgSeg.append(element)
        self.list_imgSeg=sorted(self.list_imgSeg)
        #lecture des images
        self.img = cv2.imread(self.path_image+self.list_img[0],cv2.IMREAD_COLOR)
        self.img2 = cv2.imread(self.path_imageSeg+self.list_imgSeg[0],0)
        #self.img2 =cv2.threshold(self.img2, 0 ,255,cv2.THRESH_BINARY+cv2.THRESH_OTSU)
        #self.imgTerrain = cv2.imread(self.path_terrain+self.list_imgTerrain[0],cv2.IMREAD_COLOR)
        #passage en matrice
        self.img= np.array(self.img)
        self.img2= np.array(self.img2)
        #self.imgTerrain=np.array(self.imgTerrain)
        #creation du masque rouge
        self.red_masque=np.zeros((self.img2.shape[0],self.img2.shape[1],3), np.uint8)
        #creation de l'image résultat
        self.res=np.zeros((self.img2.shape[0],self.img2.shape[1],3), np.uint8)


    def maj_red_mask(self):
        self.img2[self.img2>0]=255
        RGB = np.array((*"RGB",))
        self.red_masque=np.multiply.outer(self.img2, RGB=='R')

    def compare_image(self):
        self.maj_red_mask()
        #print(self.img.shape)
        #print(self.red_masque.shape)
        if(self.img.shape==self.red_masque.shape):
            self.res = cv2.addWeighted(self.img,1,self.red_masque,0.6,0)


    def show_image(self):
        cv2.imshow('image',self.res )
        c = cv2.waitKey(0)
        if(c==113):
            cv2.destroyAllWindows()
            sys.exit(0)
        else:
            cv2.destroyAllWindows()

    def save_masqued_image(self,name):
        cv2.imwrite(self.path_dest+name,self.res)

    def run(self):
        if(len(self.list_imgSeg)==len(self.list_img)):
            for i in range(0,len(self.list_imgSeg)):
                print("creation du visuel ",i)
                self.red_masque=np.zeros((self.img2.shape[0],self.img2.shape[1],3), np.uint8)
                self.res=np.zeros((self.img2.shape[0],self.img2.shape[1],3), np.uint8)
                self.img= cv2.imread(self.path_image+self.list_img[i],cv2.IMREAD_COLOR)
                self.img2= cv2.imread(self.path_imageSeg+self.list_imgSeg[i],0)
                self.img= np.array(self.img)
                self.img2= np.array(self.img2)
                self.compare_image()
                if(show==0):
                    self.save_masqued_image(self.list_img[i])
                else:
                    self.show_image()
        else:
            print("problème : les repertoire n'ont pas la même taille")
show=0


if __name__ == '__main__':
    if( len(sys.argv)==4):
        path_image=sys.argv[1]
        path_imageSeg=sys.argv[2]
        path=os.getcwd()
        path_dest=sys.argv[3]
        show=0
        print("écriture dans le repertoire : "+sys.argv[3])
    else:
        if( len(sys.argv)==3):
            path_image=sys.argv[1]
            path_imageSeg=sys.argv[2]
        else:
            print("arg 1 : path image arg 2 : path image segmented arg3 : path destination")
            sys.exit()

    comp = Comparator(path_image,path_imageSeg,path_dest)
    comp.run()
    #comp.maj_red_mask()
    #comp.compare_image()
    #comp.show_image()
    #comp.save_masqued_image()
