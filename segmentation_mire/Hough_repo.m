clear all
close all

path_img='../DATA/PNG/sgm_mire/img_canny/G/msk/';
%obtient la liste des images 
filelist_img=[dir(strcat(path_img,'*.png'));dir(strcat(path_img,'*.PNG'))];
nfiles = length(filelist_img);

fig_canny=figure('Name','canny masked');
fig_hough=figure('Name','hough space');
%fig_line=figure('Name','hough line plot');

for i = 1:nfiles
    path_name=strcat(strcat(path_img, '/'), filelist_img(i).name)
    SGM=imread(path_name);
    SGM=bounding_box(filelist_img(i).name,SGM);
    size_img=size(SGM);
    x_img=size_img(2)
    %%%%%%%%%%%affichage img
    figure(fig_canny)
    imshow(SGM);
    title(filelist_img(i).name);
    [H,theta,rho] = hough(SGM);
    %%%%%%%%%%affichage hough
    figure(fig_hough)
    imshow(imadjust(rescale(H)),'XData',theta,'YData',rho,'InitialMagnification','fit');
    title('Hough transform');
    xlabel('\theta'), ylabel('\rho');
    axis on, axis normal, hold on;
    %P = houghpeaks(H,1,'threshold',ceil(0.07*max(H(:))));
    P = houghpeaks(H,1); 
    theta = theta(P(:,2)); 
    rho = rho(P(:,1));
    plot(theta,rho,'s','color','red');
     
    a=-cos(theta)/sin(theta)
    b=rho/sin(theta)
    Y=zeros(x_img,2);
    for k = 1:x_img
        Y(k,1)=(a*k)+b;
        Y(k,2)=k;
    end
    figure(fig_canny)
    hold on
    title('detect line');
%     
    plot(Y,'LineWidth',1,'Color','green');

    %%%%%%%%%%affichage ligne
    
    
    
%     lines = houghlines(SGM,theta,rho,P,'FillGap',1,'MinLength',11);
%     max_len = 0;
%     title('detect line');
%     imshow(SGM);
%     hold on
%     
%    
%     for k = 1:length(lines)
%         xy = [lines(k).point1; lines(k).point2];
%         plot(xy(:,1),xy(:,2),'LineWidth',1,'Color','green');
%  
%        % Plot beginnings and ends of lines
%         plot(xy(1,1),xy(1,2),'x','LineWidth',1,'Color','yellow');
%         plot(xy(2,1),xy(2,2),'x','LineWidth',1,'Color','red');
%  
%         % Determine the endpoints of the longest line segment
%         len = norm(lines(k).point1 - lines(k).point2);
%         if ( len > max_len)
%             max_len = len;
%             xy_long = xy;
%         end
%    end
   truesize(fig_canny);
   %truesize(fig_line);
   pause;
   hold off
    %imwrite(SGM,path_name_write);
end