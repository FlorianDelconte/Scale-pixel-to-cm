import numpy as np
import os
import sys
import cv2
import matplotlib.pyplot as plt

size="256_256/"
path_segmented_grume_test="/../DATA/test/"+size+"/output/"
path_segmented_grume_expected="/../DATA/truth_ground/sgm_grume/"+size
path_visu_grume_expected="/../DATA/truth_ground/visu/"+size
path_visu_grume_test="/../DATA/test/visu/"+size



path=os.getcwd()
size=256


def compute_error(img_test,img_expected):
    TP = 0
    FN = 0
    FP = 0
    TN = 0
    #compute TruePositif
    image_test_add_exp=cv2.bitwise_and(img_test,img_expected)
    TP=np.count_nonzero(image_test_add_exp)#nombre de pixel dansf la forme réel ET dans la forme estimée
    #compute TrueNegatif
    image_test_add_exp_inverse=cv2.bitwise_not(image_test_add_exp)
    TN=np.count_nonzero(image_test_add_exp_inverse)#nombre de pixel à l'exterrieur de la forme réel ET à l'exterrieur de la forme estimée
    #compute FalseNegatif
    img_test_inverse=cv2.bitwise_not(img_test)
    image_test_inverse_add_exp=cv2.bitwise_and(img_expected,img_test_inverse)
    FN=np.count_nonzero(image_test_inverse_add_exp)
    #compute FalsePositif
    img_exp_inverse=cv2.bitwise_not(img_expected)
    image_exp_inverse_add_test=cv2.bitwise_and(img_exp_inverse,img_test)
    FP=np.count_nonzero(image_exp_inverse_add_test)
    '''cv2.imshow('img_exp',img_expected)
    cv2.imshow('img_exp_inverse',img_exp_inverse)
    cv2.imshow('img_test',img_test)
    cv2.imshow('FP',image_exp_inverse_add_test)
    c = cv2.waitKey(0)
    if(c==113):
        cv2.destroyAllWindows()
        sys.exit(0)
    else:
        cv2.destroyAllWindows()'''
    #diff=cv2.bitwise_xor(img_test,img_expected)
    #nb_err=np.count_nonzero(diff)
    #nb_pix_exp=np.count_nonzero(img_expected)
    return TP,TN,FN,FP
    #print(nb_err/nb_pix_exp)

def show_image(img_test,img_expected,im_visu_ob,im_visu_exp):
    fig=plt.figure()
    ax = fig.add_axes([0, 0, 1, 1])


    TP,TN,FN,FP=compute_error(img_test,img_expected)
    precision=TP/(TP+FP)
    recall=TP/(TP+FN)

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

    plt.text(0.01, 0.8, "erreur :\n"+"TP : "+str(TP)+"\nTN : "+str(TN)+"\nFN : "+str(FN)+"\nFP : "+str(FP),
        horizontalalignment='left',
        verticalalignment='center',
        rotation=0,
        transform=ax.transAxes)

    plt.text(0.01, 0.2, "précision : "+str(precision)+"recall : "+str(recall),
        horizontalalignment='left',
        verticalalignment='center',
        rotation=0,
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
            #print(path+path_visu_grume_test+l_visu_test[i])
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
        moyTP=0
        moyTN=0
        moyFN=0
        moyFP=0
        moyPré=0
        moyReca=0
        for i in range(0,len(l_ob)):
            print(l_ob[i])
            im_ob=cv2.imread(path+path_segmented_grume_test+l_ob[i],0)
            _,im_ob=cv2.threshold(im_ob, 0, 255, cv2.THRESH_BINARY+cv2.THRESH_OTSU)
            im_exp=cv2.imread(path+path_segmented_grume_expected+l_exp[i],0)
            _,im_exp=cv2.threshold(im_exp, 0, 255, cv2.THRESH_BINARY+cv2.THRESH_OTSU)
            im_ob = np.array(im_ob)
            im_exp= np.array(im_exp)
            TP,TN,FN,FP=compute_error(im_ob,im_exp)
            precision=TP/(TP+FP)
            recall=TP/(TP+FN)
            print("TP : "+str(TP)+" TN : "+str(TN)+" FN : "+str(FN)+" FP : "+str(FP)+" precision : "+str(precision)+"recall : "+str(recall))
            moyTP+=TP
            moyTN+=TN
            moyFN+=FN
            moyFP+=FP
            moyPré+=precision
            moyReca+=recall
        print("------------------------")
        moyTP=moyTP/len(l_ob)
        moyTN=moyTN/len(l_ob)
        moyFN=moyFN/len(l_ob)
        moyFP=moyFP/len(l_ob)
        moyPré=moyPré/len(l_ob)
        moyReca=moyReca/len(l_ob)
        print("moyenne des TP "+str(moyTP))
        print("moyenne des TN "+str(moyTN))
        print("moyenne des FN "+str(moyFN))
        print("moyenne des FP "+str(moyFP))
        print("moyenne des précision "+str(moyPré))
        print("moyenne des recall "+str(moyReca))

if __name__ == '__main__':
    if(len(sys.argv)>1):
        if(sys.argv[1]=="v"):
            compute_global_err_with_visu()
        else:
            print("arg=v for visual error")
    else:
        compute_global_err()
