%%
%entrée :
%   img_in=  image de base
%   img_sgm= segmentation de la mire correspondant
%sortie : 
%   img_out= image pré-traitée 
%   proportion= proportion de pixel blanc dans la segmentation de la mire
%%
function [img_out,proportion]=pretreatment(img_in,img_sgm)
    %GAUSSIENNE
    %img_in = imgaussfilt(img_in,2);
    %EXTRACTION DE COMPOSANTE
    R = img_in(:,:,1);
    R_canny=edge(R,'Canny');%%-----> attention prend du temps
    %OTSU
    isBinaryImage = islogical(img_sgm);
    if(isBinaryImage~=1)
        %OTSU
        level=graythresh(img_sgm);
        img_sgm=im2bw(img_sgm,level);
        %MAX COMPOSANTE
        img_sgm=bwareafilt(img_sgm,1);
        %Canny * imgSgm
        %R_canny = bsxfun(@times, R_canny, cast(img_sgm,class(R_canny))); 
        %BOUNDINGBOX
        box=regionprops(img_sgm,'BoundingBox');
        roy=round(box(1).BoundingBox);
        %découpe la composante R et l'image segmenté
        img_out=imcrop(R_canny,roy);%R_canny
%             test=imcrop(rgb2gray(img_in),roy);
%             corners = detectHarrisFeatures(test);
%             imshow(test);hold on;
%             plot(corners.selectStrongest(10));
%             pause;
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