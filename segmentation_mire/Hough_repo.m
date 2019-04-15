clear all
close all

path_img='../DATA/PNG/sgm_mire/img_canny/G/msk/';
%obtient la liste des images 
filelist_img=[dir(strcat(path_img,'*.png'));dir(strcat(path_img,'*.PNG'))];
nfiles = length(filelist_img);
fig_canny=figure('Name','canny masked');
fig_hough=figure('Name','hough space');
fig_line=figure('Name','hough line plot');

for i = 1:nfiles
    path_name=strcat(strcat(path_img, '/'), filelist_img(i).name)
    SGM=imread(path_name);
    %%%%%%%%%%%affichage img
    figure(fig_canny)
    imshow(SGM);
    title(filelist_img(i).name);
    [H,theta,rho] = hough(SGM,'RhoResolution',1,'Theta',-90:0.1:89);
    %%%%%%%%%%affichage hough
    figure(fig_hough)
    imshow(imadjust(rescale(H)),'XData',theta,'YData',rho,'InitialMagnification','fit');
    title('Hough transform');
    xlabel('\theta'), ylabel('\rho');
    axis on, axis normal, hold on;
    max(H(:))
    %P = houghpeaks(H,1,'threshold',ceil(0.07*max(H(:))));
    P = houghpeaks(H,20);
    x = theta(P(:,2)); 
    y = rho(P(:,1));
    plot(x,y,'s','color','red');
    %%%%%%%%%%affichage ligne
    figure(fig_line)
    lines = houghlines(SGM,theta,rho,P,'FillGap',2,'MinLength',1);houghlines
    max_len = 0;
    title('detect line');
    imshow(SGM)
    hold on
    for k = 1:length(lines)
         xy = [lines(k).point1; lines(k).point2];
         plot(xy(:,1),xy(:,2),'LineWidth',1,'Color','green');

        % Plot beginnings and ends of lines
         plot(xy(1,1),xy(1,2),'x','LineWidth',1,'Color','yellow');
         plot(xy(2,1),xy(2,2),'x','LineWidth',1,'Color','red');

         % Determine the endpoints of the longest line segment
        len = norm(lines(k).point1 - lines(k).point2);
        if ( len > max_len)
            max_len = len;
            xy_long = xy;
        end
    end
   
   pause;
   hold off
    %imwrite(SGM,path_name_write);
end