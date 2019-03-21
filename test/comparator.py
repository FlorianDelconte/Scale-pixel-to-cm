import numpy as np
import os
import sys
import cv2

class Comparator:
    def __init__(self,path_i,path_iSeg):
        #chemin des repertoire qui contient les images et les images segmented
        self.path_image=path_i
        self.path_imageSeg=path_iSeg
        #liste des images
        self.list_img=[]
        for element in os.listdir(path_image):
            self.list_img.append(element)
        #liste des images segmenté
        self.list_imgSeg=[]
        for element in os.listdir(path_imageSeg):
            self.list_imgSeg.append(element)

        #lecture des images
        self.img = cv2.imread(self.path_image+self.list_img[0],cv2.IMREAD_COLOR)
        self.img2 = cv2.imread(self.path_imageSeg+self.list_imgSeg[0],0)
        #passage en matrice
        self.img= np.array(self.img)
        self.img2= np.array(self.img2)
        #creation du masque rouge
        self.red_masque=np.zeros((self.img2.shape[0],self.img2.shape[1],3), np.uint8)
        #creation de l'image résultat
        self.res=np.zeros((self.img2.shape[0],self.img2.shape[1],3), np.uint8)

        #self.img= cv2.imread(path_image+self.list_img[0],cv2.IMREAD_COLOR)
        #self.img2= cv2.imread(path_imageSeg+self.list_imgSeg[0],0)
        #self.img= np.array(self.img)
        #self.img2= np.array(self.img2)


        #print(self.list_imgSeg)
        #print(self.list_img)

    def maj_red_mask(self):
        for i in range(0,self.img2.shape[0]):
            for j in range(0,self.img2.shape[1]):
                if(self.img2[i][j]!=0):
                    self.red_masque[i][j]=[0,0,255]

    def compare_image(self):
        self.maj_red_mask()
        self.res = cv2.addWeighted(self.img,1,self.red_masque,0.6,0)

    def show_image(self):
        cv2.imshow('image',self.res )
        cv2.waitKey(0)
        cv2.destroyAllWindows()

    def save_masqued_image(self,name):
        cv2.imwrite('masqued_image/'+name,self.res)

    def run(self):
        if(len(self.list_imgSeg)==len(self.list_img)):
            for i in range(0,len(self.list_imgSeg)):
                self.red_masque=np.zeros((self.img2.shape[0],self.img2.shape[1],3), np.uint8)
                self.res=np.zeros((self.img2.shape[0],self.img2.shape[1],3), np.uint8)
                self.img= cv2.imread(self.path_image+self.list_img[i],cv2.IMREAD_COLOR)
                self.img2= cv2.imread(self.path_imageSeg+self.list_imgSeg[i],0)
                self.img= np.array(self.img)
                self.img2= np.array(self.img2)
                self.compare_image()
                self.save_masqued_image(self.list_img[i])
        else:
            print("problème : les repertoire n'ont pas la même taille")

if __name__ == '__main__':
    if( len(sys.argv)==3):
        path_image=sys.argv[1]
        path_imageSeg=sys.argv[2]
    else:
        print("arg 1 : path image arg 2 : path image segmented")
        sys.exit()
    comp = Comparator(path_image,path_imageSeg)
    comp.run()
    #comp.maj_red_mask()
    #comp.compare_image()
    #comp.show_image()
    #comp.save_masqued_image()
