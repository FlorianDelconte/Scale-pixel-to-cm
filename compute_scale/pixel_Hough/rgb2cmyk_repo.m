clear all

path_source='../DATA/PNG/truth_ground/img/normal_size/';
path_dest='../DATA/PNG/sgm_mire/img_cmyk/';

filelist_sgm=[dir(strcat(path_source,'*.png'));dir(strcat(path_source,'*.PNG'))];
nfiles = length(filelist_sgm);
for i = 1:nfiles
    path_name_img=strcat(strcat(path_source, '/'), filelist_sgm(i).name);
    path_name_img
    path_name_write=strcat(strcat(path_dest, '/K/'), filelist_sgm(i).name);
    I_RGB=imread(path_name_img);
    I_CMYK=rgb2cmyk(I_RGB);
    % Composante Cyan/Magenta/Yellow/k
    C = I_CMYK(:,:,1);
    M = I_CMYK(:,:,2);
    Y = I_CMYK(:,:,3);
    K = I_CMYK(:,:,4);
    imwrite(K,path_name_write,'png');
end