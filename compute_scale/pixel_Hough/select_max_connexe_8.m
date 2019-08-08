clear all

path_sgmMire='../DATA/PNG/sgm_mire/msk_otsu/';
%obtient la liste des images 
filelist_sgm=[dir(strcat(path_sgmMire,'*.png'));dir(strcat(path_sgmMire,'*.PNG'))];
nfiles = length(filelist_sgm);
fig=figure('Name','bjr');
for i = 1:nfiles
    path_name_write=strcat(strcat(path_sgmMire, '/max_composante/'), filelist_sgm(i).name)
    SGM=imread(strcat(strcat(path_sgmMire, '/'), filelist_sgm(i).name));
    biggest=bwareafilt(SGM,1);
    imshow(biggest)
    
    imwrite(biggest,path_name_write,'png');
end