function [s] = check_sgm(n)
    path_sgmMire='../DATA/PNG/sgm_mire/msk_otsu/max_composante/';
    path_name_msk=strcat(strcat(path_sgmMire, '/'), n);
    MASQUE=imread(path_name_msk);
    nbPixBlanc=nnz(MASQUE);
    [m,n]=size(MASQUE);
    nbPix=m*n;
    proportion =nbPixBlanc/nbPix;
    if(proportion<0.015)
        s=0
    else
        s=1
    end  
end