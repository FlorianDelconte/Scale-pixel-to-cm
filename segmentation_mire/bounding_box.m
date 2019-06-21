function [M] = bounding_box(n,img)
    path_sgmMire='../DATA/PNG/sgm_mire/msk_otsu/max_composante/';
    path_name_msk=strcat(strcat(path_sgmMire, '/'), n);
    MASQUE=imread(path_name_msk);
    MASQUE=logical(MASQUE);
    %imshow(MASQUE);pause;
    box=regionprops(MASQUE,'BoundingBox');
    roy=round(box(1).BoundingBox);
    
    
    I=imcrop(img,roy);
    [x,y]=size(I);
    x=x+10;
    y=y+10;
    M=zeros(x,y);
    M(6:x-5,6:y-5)=I;
    
end