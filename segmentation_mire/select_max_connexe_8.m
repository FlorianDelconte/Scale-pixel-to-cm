clear all

path_sgmMire='../DATA/PNG/sgm_mire/';
%obtient la liste des images 
filelist_sgm=[dir(strcat(path_sgmMire,'*.png'));dir(strcat(path_sgmMire,'*.PNG'))];
nfiles = length(filelist_img);

for i = 1:nfiles
    SGM=imread(strcat(strcat(path_sgmMire, '/'), filelist_sgm(i).name));
    CC = bwconncomp(BW)
end