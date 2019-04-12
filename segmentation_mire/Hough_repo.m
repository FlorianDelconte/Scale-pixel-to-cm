clear all

path_img_msk='../DATA/PNG/sgm_mire/img_masked_canny/R/';
%obtient la liste des images 
filelist_img_msk=[dir(strcat(path_img_msk,'*.png'));dir(strcat(path_img_msk,'*.PNG'))];
nfiles = length(filelist_img_msk);
seuil=0.91;
fig=figure('Name','hough');

for i = 1:nfiles
    path_name=strcat(strcat(path_img_msk, '/'), filelist_img_msk(i).name)
    path_name_write=strcat(strcat(path_img_msk, '/hough/'), filelist_img_msk(i).name)
    SGM=imread(path_name);
    [H,theta,rho] = hough(SGM);
    P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
    lines = houghlines(SGM,theta,rho,P,'FillGap',5,'MinLength',20);
    max_len = 0;
    imshow(SGM)
    hold on
    for k = 1:length(lines)
         xy = [lines(k).point1; lines(k).point2];
         plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

        % Plot beginnings and ends of lines
         plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
         plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

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