%%
%entrée :
%   img_in=  image de base
%   img_sgm= segmentation de la mire correspondant
%sortie : 
%   img_out= image pré-traitée 
%   proportion= proportion de pixel blanc dans la segmentation de la mire
%%
function [img_out,proportion]=pretreatment(img_in,img_sgm)
    %EXTRACTION DE COMPOSANTE
    R = img_in(:,:,1);
    %OTSU
    %Canny_test=edge(R,'Canny');
    isBinaryImage = islogical(img_sgm);
    if(isBinaryImage~=1)
        %OTSU
        level=graythresh(img_sgm);
        img_sgm=im2bw(img_sgm,level);
        %MAX COMPOSANTE
        img_sgm=bwareafilt(img_sgm,1);
        %BOUNDINGBOX de la région segmenté
        box=regionprops(img_sgm,'BoundingBox');
        roy=round(box(1).BoundingBox);
        %Recupère la bounding box dans la composante R de l'img
        R_cropped=imcrop(R,roy);
        %Recupère la bounding box dans l'image segmenté
        SGM_cropped=imcrop(img_sgm,roy);
        %calcul canny dans la bounding box de la composante R
        Canny_cropped=edge(R_cropped,'Canny');
        %masque canny avec la segmentation
        Canny_masked = bsxfun(@times, Canny_cropped, cast(SGM_cropped,class(Canny_cropped)));
        img_out=Canny_masked;
        %PROPORTION DE PIXEL BLANC DANS L'IMAGE SEGMENTEE
        nbPixBlanc=nnz(img_sgm);
        [m,n]=size(img_sgm);
        nbPix=m*n;
        proportion=nbPixBlanc/nbPix;
    else
        proportion=0;
        img_out=img_sgm;
    end

end