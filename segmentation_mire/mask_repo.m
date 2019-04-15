clear all

path_img='../DATA/PNG/sgm_mire/img_canny/S/';
path_sgmMire='../DATA/PNG/sgm_mire/msk_otsu/max_composante/';
%obtient la liste des images 
filelist_sgm=[dir(strcat(path_img,'*.png'));dir(strcat(path_img,'*.PNG'))];
nfiles = length(filelist_sgm);

for i = 1:nfiles
    path_name_img=strcat(strcat(path_img, '/'), filelist_sgm(i).name)
    path_name_msk=strcat(strcat(path_sgmMire, '/'), filelist_sgm(i).name)
    path_name_write=strcat(strcat(path_img, '/msk/'), filelist_sgm(i).name)
    I_RGB=imread(path_name_img);
    MASQUE=imread(path_name_msk);
    I_RGB_masqued = bsxfun(@times, I_RGB, cast(MASQUE,class(I_RGB)));
    imwrite(I_RGB_masqued,path_name_write,'png');
end