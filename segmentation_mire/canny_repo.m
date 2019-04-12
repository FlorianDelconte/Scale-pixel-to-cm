clear all

path_img='../DATA/PNG/truth_ground/img/normal_size/';
path_sgmMire='../DATA/PNG/sgm_mire/';
%obtient la liste des images 
filelist_sgm=[dir(strcat(path_img,'*.png'));dir(strcat(path_img,'*.PNG'))];
nfiles = length(filelist_sgm);

fig=figure('Name','Segmentation de mire');
for i = 1:nfiles
    path_name=strcat(strcat(path_img, '/'), filelist_sgm(i).name)
    path_name_write=strcat(strcat(path_sgmMire, '/img_canny/V/'), filelist_sgm(i).name)
    I_RGB=imread(path_name);
    [I_RGB,R,G,B,I_HSV,H,S,V] = create_composante(I_RGB);
    G=edge(V,'Canny');
    imwrite(G,path_name_write,'png');
end