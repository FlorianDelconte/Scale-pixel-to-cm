close all
clear all

path_img='../DATA/truth_ground/img/256_256/';
path_sgmMire='../DATA/test/mire/256_256/output/';
Nbcorner=32;
filtersize=3;
seuil=0.5;
contour_methode='Canny';%Prewitt Roberts log zerocross Canny approxcanny


edge_detector='Canny'%'Sobel''Prewitt''Roberts''log''Canny''approxcanny'
filelist_img=[dir(strcat(path_img,'*.jpg'));dir(strcat(path_img,'*.JPG'))]
filelist_sgm=[dir(strcat(path_sgmMire,'*.jpg'));dir(strcat(path_sgmMire,'*.JPG'))]
%filelist = dir([path,'*.{JPG,jpg}']);
nfiles = length(filelist_img)
fig=figure('Name','Segmentation de mire');
for i = 1:nfiles
    filelist_img(i).name
    filelist_sgm(i).name
    %lecture de l'image RGB
    I_RGB=imread(strcat(strcat(path_img, '/'), filelist_img(i).name));
    %lecture du masque
    MASQUE=imread(strcat(strcat(path_sgmMire, '/'), filelist_sgm(i).name));
    MASQUE=im2bw(MASQUE,0);
    %calcul l'image masqué
    I_RGB_masqued = bsxfun(@times, I_RGB, cast(MASQUE,class(I_RGB)));
    %recupère les composantes
    [I_RGB,R,G,B,I_HSV,H,S,V] = create_composante(I_RGB_masqued);
    
    
    %OPERATION
    [I_RGB,R,G,B,I_HSV,H,S,V] = treshold(I_RGB,R,G,B,I_HSV,H,S,V,seuil);
    %[I_RGB,R,G,B,I_HSV,H,S,V] = apply_Otsu(I_RGB,R,G,B,I_HSV,H,S,V);
    [I_RGB,R,G,B,I_HSV,H,S,V]=detect_contour(I_RGB,R,G,B,I_HSV,H,S,V,contour_methode);
    %AFFICHAGE
    affiche_composante(I_RGB,R,G,B,I_HSV,H,S,V);
    %affichage_harris(I_RGB,R,G,B,I_HSV,H,S,V,Nbcorner,filtersize);
    truesize(fig);
    pause;
end
%corners = detectHarrisFeatures(I);
%plot(corners.selectStrongest(300));