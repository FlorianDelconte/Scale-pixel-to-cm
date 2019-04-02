import numpy as np
import os
import sys
import cv2
import matplotlib.pyplot as plt

path_segmented_grume_test="/deeplearning/dataset/test/output/"
path_segmented_grume_expected="/truth_ground/sgm_grume/256_256/"
path_visu_grume_expected="/truth_ground/visu/256_256/"
path_visu_grume_test="/test/masqued_image/"



path=os.getcwd()
size=256


def compute_error(img_test,img_expected):
    diff=cv2.bitwise_xor(img_test,img_expected)
    nb_err=np.count_nonzero(diff)
    nb_pix_exp=np.count_nonzero(img_expected)
    return nb_err/nb_pix_exp
    #print(nb_err/nb_pix_exp)
def show_image(img_test,img_expected,im_visu_ob,im_visu_exp):
    fig=plt.figure()
    ax = fig.add_axes([0, 0, 1, 1])
    img_expected = cv2.cvtColor(img_expected, cv2.COLOR_BGR2RGB)
    img_test = cv2.cvtColor(img_test, cv2.COLOR_BGR2RGB)
    im_visu_exp = cv2.cvtColor(im_visu_exp, cv2.COLOR_BGR2RGB)
    im_visu_ob = cv2.cvtColor(im_visu_ob, cv2.COLOR_BGR2RGB)

    t=plt.subplot(2,2,1)
    t.set_title("truth_ground")
    plt.imshow(img_expected)

    t2=plt.subplot(2,2,2)
    t2.set_title("obtained")
    plt.imshow(img_test)

    t3=plt.subplot(2,2,3)
    plt.imshow(im_visu_exp)

    t3=plt.subplot(2,2,4)
    plt.imshow(im_visu_ob)
    print(img_test)
    print(compute_error(img_test,img_expected))
    plt.text(0.05, 0.8, "erreur :\n"+str('%.3f'%(compute_error(img_test,img_expected))),
        horizontalalignment='center',
        verticalalignment='center',
        rotation=45,
        transform=ax.transAxes)

    plt.show()

    #cv2.imshow('truth_ground',img_expected )
    #cv2.imshow('obtained',img_test )



def make_list():
    list_imgexpected=[]
    for element in os.listdir(path+path_segmented_grume_expected):
        list_imgexpected.append(element)
    list_imgexpected=sorted(list_imgexpected)
    #liste des images de la vérité terrain
    list_imgobtenue=[]
    for element in os.listdir(path+path_segmented_grume_test):
        list_imgobtenue.append(element)
    list_imgobtenue=sorted(list_imgobtenue)

    list_visu_exp=[]
    for element in os.listdir(path+path_visu_grume_expected):
        list_visu_exp.append(element)
    list_visu_exp=sorted(list_visu_exp)

    list_visu_test=[]
    for element in os.listdir(path+path_visu_grume_test):
        list_visu_test.append(element)
    list_visu_test=sorted(list_visu_test)

    return list_imgexpected,list_imgobtenue,list_visu_exp,list_visu_test


def compute_global_err_with_visu():
    l_exp,l_ob,l_visu_exp,l_visu_test=make_list()
    if(len(l_exp)==len(l_ob)):
        for i in range(0,len(l_ob)):
            print(l_visu_exp[i])
            im_visu_exp=cv2.imread(path+path_visu_grume_expected+l_visu_exp[i],cv2.IMREAD_COLOR)
            im_visu_ob=cv2.imread(path+path_visu_grume_test+l_visu_test[i],cv2.IMREAD_COLOR)

            im_ob=cv2.imread(path+path_segmented_grume_test+l_ob[i],0)
            _,im_ob=cv2.threshold(im_ob, 0, 255, cv2.THRESH_BINARY+cv2.THRESH_OTSU)
            im_exp=cv2.imread(path+path_segmented_grume_expected+l_exp[i],0)
            _,im_exp=cv2.threshold(im_exp, 0, 255, cv2.THRESH_BINARY+cv2.THRESH_OTSU)

            im_ob = np.array(im_ob)
            im_exp= np.array(im_exp)

            #compute_error(im_ob,im_exp)
            show_image(im_ob,im_exp,im_visu_ob,im_visu_exp)
    else:
        print("erreur : les listes n'ont pas la même taille")

def compute_global_err():
    l_exp,l_ob,_,_=make_list()
    if(len(l_exp)==len(l_ob)):
        moy=0
        for i in range(0,len(l_ob)):
            print(l_ob[i])
            im_ob=cv2.imread(path+path_segmented_grume_test+l_ob[i],0)
            _,im_ob=cv2.threshold(im_ob, 119, 255, cv2.THRESH_BINARY)
            im_exp=cv2.imread(path+path_segmented_grume_expected+l_exp[i],0)
            _,im_exp=cv2.threshold(im_exp, 119, 255, cv2.THRESH_BINARY)
            im_ob = np.array(im_ob)
            im_exp= np.array(im_exp)
            err=compute_error(im_ob,im_exp)
            print("erreur : "+str(err))
            moy+=err
        print("------------------------")
        moy=moy/len(l_ob)
        print(moy)

if __name__ == '__main__':
    if(len(sys.argv)>1):
        if(sys.argv[1]=="v"):
            compute_global_err_with_visu()
        else:
            print("arg=v for visual error")
    else:
        compute_global_err()
