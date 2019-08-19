import numpy as np
import os
import sys, getopt
import cv2
import matplotlib.pyplot as plt
#return lsit of file name of two folder
def make_list(pathToFolder1):
    #list of all fil in folder1
    list_file_folder1=[]
    for element in os.listdir(pathToFolder1):
        if(".gitkeep" not in element):
            list_file_folder1.append(element)
    list_file_folder1=sorted(list_file_folder1)
    return list_file_folder1
#return an binary img of the maximum component
def maxComponent(img):
    ret, labels = cv2.connectedComponents(img,connectivity = 8)
    max_area=-sys.maxsize - 1;
    label_max=-1;
    label_counter=0;
    for i in range(1,ret):
        label_counter=np.count_nonzero(labels == i)
        if(label_counter>max_area):
            max_area=label_counter
            label_max=i

    img=np.where(labels!=label_max, 0, img)

    img=np.where(labels==label_max, 255, img)

    return img
#return a img tresholded by otsu and select the max composante
def Otsu_MaxComponent(img):
    _,img=cv2.threshold(img, 0, 255, cv2.THRESH_BINARY+cv2.THRESH_OTSU)
    max_comp=maxComponent(img)
    return max_comp
#return a img tresholded by otsu and select the max composante and royed
def Otsu_MaxComponent_Roy(img):
    #print(img.dtype)
    img=Otsu_MaxComponent(img)
    # print(img.dtype)
    #BOUNDING BOX
    #x, y, w, h = cv2.boundingRect(np.argwhere(img))
    #print("x",x,"y",y,"w",w,"h",h)
    #rect = cv2.rectangle(img.copy(),(y,x),(y+h,x+w),(127),-1)
    #ROTATED BOUNDING BOX
    contours,_ = cv2.findContours(img.copy(), 1, 2) # not copying here will throw an error
    #print(contours)
    rect = cv2.minAreaRect(contours[len(contours)-1]) # basically you can feed this rect into your classifier
    (x,y),(w,h), a = rect
    box = cv2.boxPoints(rect)
    box = np.int0(box) #turn into ints
    rect2 = cv2.drawContours(img.copy(),[box],0,127,3 )

    plt.imshow(rect2)
    plt.show()
    return img
#compute TP,FN,FP,TN between two image, second image is the groudtruth
def confusion_matrix(img_test,img_truth):
    '''fig=plt.figure()
    plt.subplot(2,2,1)
    plt.imshow(img_test)
    plt.subplot(2,2,2)
    plt.imshow(img_truth)
    plt.show()'''
    TP = 0
    FN = 0
    FP = 0
    TN = 0
    #compute TruePositif
    image_test_add_exp=np.bitwise_and(img_test,img_truth)
    TP=np.count_nonzero(image_test_add_exp)#nombre de pixel dansf la forme réel ET dans la forme estimée

    #compute TrueNegatif
    image_test_inverse=np.bitwise_not(img_test)
    img_expected_inverse=np.bitwise_not(img_truth)
    image_test_inverse_and_img_expected_inverse=np.bitwise_and(image_test_inverse,img_expected_inverse)
    TN=np.count_nonzero(image_test_inverse_and_img_expected_inverse)#nombre de pixel à l'exterrieur de la forme réel ET à l'exterrieur de la forme estimée

    #compute FalseNegatif
    img_test_inverse=np.bitwise_not(img_test)
    image_test_inverse_add_exp=np.bitwise_and(img_truth,img_test_inverse)
    FN=np.count_nonzero(image_test_inverse_add_exp)

    #compute FalsePositif
    img_exp_inverse=np.bitwise_not(img_truth)
    image_exp_inverse_add_test=np.bitwise_and(img_exp_inverse,img_test)
    FP=np.count_nonzero(image_exp_inverse_add_test)

    if(TP+FP !=0):
        precision=TP/(TP+FP)
    else:
        precision =0
    if(TP+FN!=0):
        recall=TP/(TP+FN)
    else:
        recall=0

    return TP,TN,FN,FP,precision,recall

if __name__ == '__main__':
    #path to  computed img segmentation
    path_SGM_computed="../compute_scale/IMG_SGM/"
    #path to expected img segmentation
    path_SGM_expected="../DATA/PNG/truth_ground/mire/normal_size/"

    list_SGM_expected=make_list(path_SGM_expected)
    for nameFileSgm in list_SGM_expected:
        print(nameFileSgm)
        img_Expected=cv2.imread(path_SGM_expected+nameFileSgm,0)
        img_Computed=cv2.imread(path_SGM_computed+nameFileSgm,0)
        #get the otsu/maxcomponent
        img_cl=Otsu_MaxComponent(img_Computed)
        #get the otsu/maxcomponent/boundingbox img
        img_Roy=Otsu_MaxComponent_Roy(img_Computed)
        #compute confusion matrix
        TP1,TN1,FN1,FP1,precision1,recall1=confusion_matrix(img_Computed,img_Expected)
        TP2,TN2,FN2,FP2,precision2,recall2=confusion_matrix(img_cl,img_Expected)
        TP3,TN3,FN3,FP3,precision3,recall3=confusion_matrix(img_Roy,img_Expected)
        print("BRUT-----TP : ",TP1,"TN : ",TN1,"FN : ",FN1,"FP : ",FP1, "precision : ",precision1, "recall : ",recall1)
        print("OTSU_MAX-----TP : ",TP2,"TN : ",TN2,"FN : ",FN2,"FP : ",FP2, "precision : ",precision2, "recall : ",recall2)
        print("OTSU_MAX_ROY-----TP : ",TP3,"TN : ",TN3,"FN : ",FN3,"FP : ",FP3, "precision : ",precision3, "recall : ",recall3)
