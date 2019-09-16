import os
import matplotlib.pyplot as plt
import numpy as np

#PATH_GROUND_TRUTH_DISTANCE="../DATA/PNG/truth_ground/mire/echelle_remi.txt"
PATH_GROUND_TRUTH_DISTANCE="../DATA/PNG/INRA_test/GT_DouglasBBF.txt"
#PATH_COMPUTED_DISTANCE_VERTICALE="../segmentation_mire/segment_flou/build/echelle_computed_vertical.txt"
PATH_COMPUTED_DISTANCE_HORIZONTAL="../DATA/PNG/INRA_test/computed_DouglasBBF.txt"
#PATH_COMPUTED_DISTANCE_MOYENNE="../segmentation_mire/segment_flou/build/echelle_computed_moyenne.txt"
ID_FILE=[]#list all file
def main():
    #creation des matrice 'file | distance'
    GT_distance_brut=makeVectorDistanceGT(PATH_GROUND_TRUTH_DISTANCE)
    C_distance_verticale=makeVectorDistance(PATH_COMPUTED_DISTANCE_HORIZONTAL)
    C_distance_horizontal=makeVectorDistance(PATH_COMPUTED_DISTANCE_HORIZONTAL)
    C_distance_moyenne=makeVectorDistance(PATH_COMPUTED_DISTANCE_HORIZONTAL)
    GT_distance=cleanVectorGT(GT_distance_brut,C_distance_horizontal)

    min_distance,max_distance=min_max(GT_distance,C_distance_verticale,C_distance_horizontal)
    GT_distance_brut.sort(order="file")
    GT_distance.sort(order="file")
    C_distance_horizontal.sort(order="file")
    global ID_FILE
    ID_FILE=GT_distance['file']
    #print(C_distance_horizontal)
    #####calcul des erreurs
    #errorVerticale=compute_error(GT_distance,C_distance_verticale)
    errorHorizontal=compute_error(GT_distance,C_distance_horizontal)
    #print(GT_distance)
    #print(C_distance_horizontal)
    #errorMoyenne=compute_error(GT_distance,C_distance_moyenne)
    #####calcul des pourcentage d'erreur
    #ratioErreurVerticale=compute_RatioError(GT_distanprint(GT_distance.size())ce,C_distance_verticale)
    ratioErreurHorizontal=compute_RatioError(GT_distance,C_distance_horizontal)
    #ratioErreurmoyenne=compute_RatioError(GT_distance,C_distance_moyenne)
    #####calcul de la moyenne des erreurs
    #moyenne_error_Verticale=compute_moyenne(errorVerticale)
    moyenne_error_Horizontal=compute_moyenne(errorHorizontal)
    #moyenne_error_moyenne=compute_moyenne(errorMoyenne)
    #####calcul de la moyenne des pourcentage d'erreur
    #moyenne_ratio_Verticale=compute_moyenne(ratioErreurVerticale)
    moyenne_ratio_Horizontal=compute_moyenne(ratioErreurHorizontal)
    #moyenne_ratio_moyenne=compute_moyenne(ratioErreurmoyenne)
    print("moyenne erreur total horizontal : ",moyenne_error_Horizontal, "soit un ratio de  : ",moyenne_ratio_Horizontal)
    #print("moyenne erreur total verticale : ",moyenne_error_Verticale, "soit un ratio de : ",moyenne_ratio_Verticale)
    #print("moyenne erreur total verticale+horizontal/2 : ",moyenne_error_moyenne, "soit un ratio de : ",moyenne_ratio_moyenne)
    #####calcul de la variance
    variance_Horizontal=compute_variance(errorHorizontal)
    #variance_Verticale=compute_variance(errorVerticale)
    #variance_Moyenne=compute_variance(errorMoyenne)
    #####calcul de l'écart type
    ecart_type_Horizontal=ecartype(errorHorizontal)
    #ecart_type_Vertical=ecartype(errorVerticale)
    #ecart_type_Moyenne=ecartype(errorMoyenne)
    print("ecart-type horizontal : ",ecart_type_Horizontal)
    #print("ecart-type verticale : ",ecart_type_Vertical)
    #print("ecart-type verticale+horizontal/2 : ",ecart_type_Moyenne)
    x=[i for i in range(errorHorizontal.size)]
    #AFFICHAGE
    #plt.axis([1,errorVerticale.size,min_distance,max_distance])
    fig = plt.figure()
    #Erreur Horizontal
    ax1=fig.add_subplot(311)
    ax1.margins(0, min_distance)
    ax1.set_xlim(0, errorHorizontal.size)
    ax1.set_ylim(min_distance, max_distance)
    ax1.plot(x,GT_distance['dist'],color='green',linewidth=1,label="ground truth")
    ax1.errorbar(x,C_distance_horizontal['dist'], yerr=ecart_type_Horizontal, fmt='+', color='red',ecolor='lightgray', elinewidth=2, capsize=0,picker=x,label="computed distance (Horizontal)\n & standart deviation")
    box = ax1.get_position()
    ax1.set_position([box.x0, box.y0, box.width * 0.8, box.height])
    ax1.legend(loc='center left', bbox_to_anchor=(1, 0.5))
    #erreur Vertical
    '''ax2=fig.add_subplot(312)
    ax2.margins(0, min_distance)
    ax2.set_xlim(0, errorVerticale.size)
    ax2.set_ylim(min_distance, max_distance)
    ax2.plot(x,GT_distance['dist'],color='green',linewidth=1 ,label="ground truth"   )
    ax2.errorbar(x,C_distance_verticale['dist'], yerr=ecart_type_Vertical, fmt='+', color='blue',ecolor='lightgray', elinewidth=2, capsize=0,picker=x,label="computed distance (Vertical)\n & standart deviation")
    box = ax2.get_position()
    ax2.set_position([box.x0, box.y0, box.width * 0.8, box.height])
    ax2.legend(loc='center left', bbox_to_anchor=(1, 0.5))'''
    #erreur Horizontal+Vertical/2
    '''ax3=fig.add_subplot(313)
    ax3.margins(0, min_distance)
    ax3.set_xlim(0, errorVerticale.size)
    ax3.set_ylim(min_distance, max_distance)
    ax3.plot(x,GT_distance['dist'],color='green',linewidth=1 ,label="ground truth"   )
    ax3.errorbar(x,C_distance_moyenne['dist'], yerr=ecart_type_Moyenne, fmt='+', color='yellow',ecolor='lightgray', elinewidth=2, capsize=0,picker=x,label="computed distance (moyenne)\n & standart deviation")
    box = ax3.get_position()
    ax3.set_position([box.x0, box.y0, box.width * 0.8, box.height])
    ax3.legend(loc='center left', bbox_to_anchor=(1, 0.5))'''

    #fig.canvas.callbacks.connect('pick_event', on_pick)
    #plt.figure(2)
    #plt.plot(x,errorHorizontal,color='red',linewidth=1 ,label="ground truth"   )
    plt.show()

def on_pick(event):
    artist = event.artist
    xmouse, ymouse = event.mouseevent.xdata, event.mouseevent.ydata
    x, y = artist.get_xdata(), artist.get_ydata()
    ind = event.ind
    indice_file= x[ind[0]]
    print ('file id : ', indice_file)
    print('file name : ',ID_FILE[indice_file])

def cleanVectorGT(GTbrut_vec,C_vec):
    GTbrut_vec.sort(order="file")
    C_vec.sort(order="file")
    GTlist=[]
    for i in GTbrut_vec:
        filen=i['file']
        print(filen)
        print(C_vec)
        if(filen in C_vec['file']):
            GTlist.append(i)
    print(len(GTlist))
    GT=np.array(GTlist)
    return GT

def compute_moyenne(errorVec):
    moyenne=0
    for i in errorVec:
        moyenne+=i
    moyenne=moyenne/errorVec.size
    return moyenne

def compute_variance(errorVec):
    moy=compute_moyenne(errorVec)
    return compute_moyenne(np.array([(x-moy)**2 for x in errorVec]))

def ecartype(errorVec):
    return compute_variance(errorVec)**0.5

def compute_error(GT,CV):
    moyenne_error_list=[]
    for i in CV:
        dist_computed=i['dist']
        file_name=i['file']
        #print(file_name)
        dist_GT=findDist(file_name,GT)
        #print(dist_GT)
        erreur=abs(dist_GT-dist_computed)
        moyenne_error_list.append(erreur)
    moyenne_error_array = np.array(moyenne_error_list)
    return moyenne_error_array
def compute_RatioError(GT,CV):
    moyenne_error_list=[]
    for i in CV:
        dist_computed=i['dist']
        file_name=i['file']
        #print(file_name)
        dist_GT=findDist(file_name,GT)
        #print(dist_computed)
        erreur=abs(dist_GT-dist_computed)/abs(dist_GT)
        moyenne_error_list.append(erreur)
    moyenne_error_array = np.array(moyenne_error_list)
    return moyenne_error_array

def findDist(f,vec):
    #if filename not found
    dist=-1
    for i in vec:
        if(i['file']==f):
            dist=i['dist']
    return dist

def min_max(vec1,vec2,vec3):
    min_vec1= min_custom(vec1)
    max_vec1= max_custom(vec1)

    min_vec2= min_custom(vec2)
    max_vec2= max_custom(vec2)

    min_vec3= min_custom(vec3)
    max_vec3= max_custom(vec3)

    min_out=min(min_vec1,min_vec2,min_vec3)
    max_out=max(max_vec1,max_vec2,max_vec3)
    return min_out,max_out;

def min_custom(vec):
    m=999999999999;
    for i in vec:
        current_value=i['dist']
        if(current_value!=-1):
            if(current_value<m):
                m=current_value
    return m
def max_custom(vec):
    m=-999999999999;
    for i in vec:
        current_value=i['dist']
        if(current_value!=-1):
            if(current_value>m):
                m=current_value
    return m


def makeVectorDistance(path_file_distance):
    vectorDistance = np.loadtxt(path_file_distance,dtype={'names': ('file', 'dist'),'formats': ('|S25', np.float)})
    return vectorDistance

def makeVectorDistanceGT(path_file_distance):
    #vectorDistance = np.loadtxt(path_file_distance,dtype={'names': ('file', 'dist'),'formats': ('|S25', np.float)},delimiter='\t',usecols =(1, 3),skiprows=1)
    vectorDistance = np.loadtxt(path_file_distance,dtype={'names': ('file', 'dist'),'formats': ('|S25', np.float)},skiprows=1,usecols =(0, 2))
    vectorDistance['dist']=vectorDistance['dist'] / 10
    return vectorDistance

if __name__ == "__main__":
    # execute only if run as a script
    main()
