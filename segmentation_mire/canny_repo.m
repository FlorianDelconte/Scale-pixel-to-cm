clear all

path_source='../DATA/PNG/truth_ground/img/256_256/';
%path_dest='../DATA/PNG/sgm_mire/';
path_dest='../DATA/PNG/truth_ground/img/test/';
%obtient la liste des images 
filelist_sgm=[dir(strcat(path_source,'*.png'));dir(strcat(path_source,'*.PNG'))];
nfiles = length(filelist_sgm);

fig=figure('Name','Segmentation de mire');
for i = 1:nfiles
    tic;
    path_name=strcat(strcat(path_source, '/'), filelist_sgm(i).name)
    %path_name_write=strcat(strcat(path_dest, '/img_canny/S/'), filelist_sgm(i).name)
    path_name_write=strcat(strcat(path_dest, '/R/'), filelist_sgm(i).name)
    I_RGB=imread(path_name);
    I_RGB = imgaussfilt(I_RGB);
    [I_RGB,R,G,B,I_HSV,H,S,V] = create_composante(I_RGB);   
    canny=edge(R,'Canny');%% écrit ici la composante sur laquelle tu souhaite utilisé canny
    imwrite(canny,path_name_write,'png');
    toc
end