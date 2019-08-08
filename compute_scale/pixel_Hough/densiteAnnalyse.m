close all
path_img='../DATA/PNG/sgm_mire/img_canny/R/';
path_write='../DATA/PNG/sgm_mire/pixel_line/';
filelist_img=[dir(strcat(path_img,'*.png'));dir(strcat(path_img,'*.PNG'))];
nfiles = length(filelist_img);

fig_densite=figure('Name','densite');
fig_contourclear=figure('Name','contour clear');
fig_histo=figure('Name','histo');
allRatio=[];
for i = 1 :nfiles
    if(check_sgm(filelist_img(i).name)==1)
        path_name=strcat(strcat(path_img, '/'), filelist_img(i).name)
        contour=imread(path_name);
        %contour=bounding_box(filelist_img(i).name,contour);
        [img_densite,contour_clear,ratio]=densite(contour,24,9);
        allRatio=[allRatio ratio];
        contour=contour_clear;
    end
    %%%
     affichage_densite(fig_densite,img_densite,filelist_img(i).name);
     affichage_contourcleared(fig_contourclear,contour_clear,filelist_img(i).name);
    %%%
    %figure(fig_histo);
    %histogram(img_densite)
    %%%
  
     %figure(fig_densite);
     pause;
     %clf('reset')
    %figure(fig_histo);
    %clf('reset')
     %figure(fig_contourclear);
     %clf('reset')
     
end
affichage_ratio(allRatio,nfiles);
function affichage_ratio(allRatio,nbfile)
    figure;
    plot(allRatio);
    xlabel('ID images','FontSize',15,...              %Nom de l'axe des abscisses du tracé
       'FontWeight','bold','FontName',...
       'Times New Roman','Color','b')
    ylabel('ratio de pixels dense','FontSize',15,...      %Nom de l'axe des ordonnées du tracé
       'FontWeight','bold','FontName',...
       'Times New Roman','Color','b')

end
function affichage_densite(fig_densite,img_densite,img_name)
   figure(fig_densite);
   title(img_name);
   imshow(img_densite,[0,255]);
end
function affichage_contourcleared(fig_contourclear,contour_clear,img_name)
   figure(fig_contourclear);
   title(img_name);
   imshow(contour_clear);
end