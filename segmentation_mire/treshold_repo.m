clear all

path_sgmMire='../DATA/PNG/sgm_mire/';
%obtient la liste des images 
filelist_sgm=[dir(strcat(path_sgmMire,'*.png'));dir(strcat(path_sgmMire,'*.PNG'))];
nfiles = length(filelist_sgm);
seuil=0.944;

for i = 1:nfiles
    path_name=strcat(strcat(path_sgmMire, '/'), filelist_sgm(i).name)
    SGM=imread(path_name);
    level=graythresh(SGM);
    SGM=im2bw(SGM,level);
    imwrite(SGM,path_name);
end