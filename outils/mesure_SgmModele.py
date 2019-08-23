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
    _,img_tresholded=cv2.threshold(img, 0, 255, cv2.THRESH_BINARY+cv2.THRESH_OTSU)
    max_comp=maxComponent(img_tresholded)
    return max_comp
#return a img tresholded by otsu and select the max composante and royed
def Otsu_MaxComponent_Roy(img):
    img_otsuMax=Otsu_MaxComponent(img)
    #BOUNDING BOX
    x, y, w, h = cv2.boundingRect(np.argwhere(img_otsuMax))
    rect = cv2.rectangle(img_otsuMax.copy(),(y,x),(y+h,x+w),(127),-1)
    return rect
    #return an img tresholdef by otsu and select the max composante and constructed min area rotated rect around the past
def Otsu_MaxComponent_RotatedRoy(img):
    img_otsuMax=Otsu_MaxComponent(img)
    contours,_ = cv2.findContours(img_otsuMax.copy(), 1, 2) # not copying here will throw an error
    rect = cv2.minAreaRect(contours[len(contours)-1]) # basically you can feed this rect into your classifier
    (x,y),(w,h), a = rect
    box = cv2.boxPoints(rect)
    box = np.int0(box) #turn into ints
    rect2 = cv2.drawContours(img_otsuMax.copy(),[box],0,127,-1)
    return rect2
#compute TP,FN,FP,TN between two image, second image is the groudtruth
def confusion_matrix(detections,truth):
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

    positive_count = np.count_nonzero(detections)
    negative_count = truth.size - positive_count


    temp1=np.bitwise_and(truth,detections)
    TP = np.count_nonzero(temp1)
    FP = positive_count - TP
    temp2=np.bitwise_not(detections)
    temp2=np.bitwise_and(truth, temp2)
    FN = np.count_nonzero(temp2)
    TN = negative_count - FN
    '''#compute TruePositif
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
    '''

    #PRECISION
    if(TP+FP != 0 and np.count_nonzero(truth)!=0 ):
        precision=float(TP)/(TP+FP)
    else:
        precision=-1

    '''if(FP !=0):
        if(TP != 0):
            precision=float(TP)/(TP+FP)
        else:
            precision=float((truth.size-FP))/truth.size
    else:
        precision =1.'''
    #RECALL'
    if(TP+FN!=0):
        recall=float(TP)/(TP+FN)
    else:
        recall=-1

    '''if(FN!=0):
        if(TP != 0):
            recall=float(TP)/(TP+FN)
        else:
            recall=float((truth.size-FN))/truth.size
    else:
        recall=1.'''
    #ACCURACY
    accuracy=float(TP+TN)/(TP+TN+FP+FN)
    return TP,TN,FN,FP,precision,recall,accuracy

def display(img_Expected,img_cl):
    plt.figure()
    plt.imshow(np.dstack((img_cl,img_Expected,np.zeros(img_Expected.shape))))



    plt.show()
if __name__ == '__main__':
    #path to  computed img segmentation
    path_SGM_computed="../compute_scale/IMG_SGM/"#
    #path to expected img segmentation
    #path_SGM_expected="../DATA/PNG/truth_ground/mire/normal_size/"
    #path_SGM_expected="../DATA/PNG/truth_groundV2/mire/normal_size/"
    path_SGM_expected="../DATA/PNG/truth_groundV3/mire/normal_size/"
    moyTP=0
    moyTN=0
    moyFN=0
    moyFP=0
    moyPre=0.
    moyReca=0.
    moyAccu=0.
    list_SGM_expected=make_list(path_SGM_expected)
    denomPre=len(list_SGM_expected)
    denomRec=len(list_SGM_expected)
    for nameFileSgm in list_SGM_expected:
        print(nameFileSgm)
        img_Expected=cv2.imread(path_SGM_expected+nameFileSgm,0)
        img_Computed=cv2.imread(path_SGM_computed+nameFileSgm,0)
        #get the otsu/maxcomponent
        img_cl=Otsu_MaxComponent(img_Computed)
        #compute confusion matrix
        TP,TN,FN,FP,precision,recall,accuracy=confusion_matrix(img_cl,img_Expected)
        print("BRUT-----TP : ",TP,"TN : ",TN,"FN : ",FN,"FP : ",FP, "precision : ",precision, "recall : ",recall,"accuracy : ",accuracy)
        moyTP+=TP
        moyTN+=TN
        moyFN+=FN
        moyFP+=FP
        if(precision!=-1):
            moyPre+=precision
        else:
            denomPre=denomPre-1
        if(recall!=-1):
            moyReca+=recall
        else:
            denomRec=denomRec-1
        moyAccu+=accuracy
        #display(img_Expected,img_cl)

    moyPre=float(moyPre)/(denomPre)
    moyReca=float(moyReca)/(denomRec)
    moyAccu=float(moyAccu)/len(list_SGM_expected)
    print("moyenne precision : ",moyPre, "moyenne recall : ",moyReca,"moyenne accuracy : ",moyAccu)
