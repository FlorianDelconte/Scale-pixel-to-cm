clear all

path_sgmMire='../DATA/PNG/sgm_mire/';
%obtient la liste des images 
filelist_sgm=[dir(strcat(path_sgmMire,'*.png'));dir(strcat(path_sgmMire,'*.PNG'))];
nfiles = length(filelist_sgm);
seuil=0.7;

for i = 1:nfiles
    path_name=strcat(strcat(path_sgmMire, '/'), filelist_sgm(i).name)
    path_name_write=strcat(strcat(path_sgmMire, '/msk_seuillage/'), filelist_sgm(i).name)
    SGM=imread(path_name);
    SGM=detect_contour(SGM,seuil);
    imwrite(SGM,path_name_write);
end