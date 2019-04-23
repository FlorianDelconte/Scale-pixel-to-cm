close all

path_img='../DATA/PNG/sgm_mire/img_canny/B/msk/';
%obtient la liste des images 
filelist_img=[dir(strcat(path_img,'*.png'));dir(strcat(path_img,'*.PNG'))];
nfiles = length(filelist_img);

fig_img=figure('Name','contour');
fig_hough=figure('Name','hough space');
fig_vecteur=figure('Name','vecteur theta max');
fig_vecteur_long=figure('Name','vecteur theta max +90');

for i = 1:nfiles
    if(check_sgm(filelist_img(i).name)==1)
        %%%%%%%%%%%%%OUVERTURE BOITE ENGLOBANTE IMG%%%%%%%%%%%%%%
        path_name=strcat(strcat(path_img, '/'), filelist_img(i).name);
        contour=imread(path_name);
        contour=bounding_box(filelist_img(i).name,contour);
        %%%%%%%%%%%%%DETECTION DE LA MIRE%%%%%%%%%%%%%%%%%%%%%%%%
        [H,theta,rho] = hough(contour,'RhoResolution',5);
        %%%%DETECTION DES LIGNES HORIZONTALES%%%%
        ind_max_p = houghpeaks(H,1);
        theta_max = theta(ind_max_p(2));
        hough_vector_max_theta=H(:,ind_max_p(2));
        [V,I]=findpeaks(hough_vector_max_theta,'WidthReference','halfheight');%'MinPeakDistance',10
        %%%%DETECTION DES LIGNES +90 DEGREES%%%%%
        ind_dec_p = mod(ind_max_p(2)+90,180);
        theta_dec = theta(ind_dec_p);
        hough_vector_max_theta_90=H(:,ind_dec_p);
        [V_dec,I_dec]=findpeaks(hough_vector_max_theta_90,'WidthReference','halfheight');%'MinPeakDistance',5
        %%%%NETOYAGE VECTEURS%%%%%%%%%%%%%%%%%%%%
        [V,I]=clear(V,I);
        [V_dec,I_dec]=clear(V_dec,I_dec);
        %%%%CREATION DES PEAKS%%%%%%%%%%%%%%%%%%%
        P=zeros(length(I),1);
        P(:)=ind_max_p(2);
        P=[I(:),P];                 %--->P contient les indice de rho | theta
        P_dec=zeros(length(I_dec),1);
        P_dec(:)=ind_dec_p;
        P_dec=[I_dec(:),P_dec];
        %Extract rho and theta values from peaks cleared
        rho_out=rho(P(:,1));
        theta_out=theta(P(:,2));
        rho_dec_out=rho(P_dec(:,1));
        theta_dec_out=theta(P_dec(:,2));
        %%%%LINES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         
        lines = houghlines(contour,theta,rho,P,'FillGap',10000);
        lines_dec = houghlines(contour,theta,rho,P_dec,'FillGap',10000);
%         for i=1:length(rho_sort(1,:))
%             %Exception for theta=0, y1-> inf
%             if theta_sort(i)==0
%                 plot([rho_sort(i),rho_sort(i)],[1,480],'LineWidth',1.5,'Color','red');
%             end
%             x1=1:640;
%             y1 = ((rho_sort(i)) - x1* cosd(theta_sort(i)) )/ sind(theta_sort(i));
%             plot(x1,y1,'LineWidth',1.5,'Color','red');
%         end
        a=-cos(theta(P_dec(7,2)))/sin(theta(P_dec(7,2)));
        b= rho(P_dec(7,1))/sin(theta(P_dec(7,2)));
        
        %%%%AFFICHAGE%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        affichage_img(fig_img,contour,filelist_img(i).name,lines,lines_dec,rho_out,theta_out,rho_dec_out,theta_dec_out);
        affichage_hough(fig_hough,H,theta,rho,I,I_dec,theta_max,theta_dec);
        affichage_distrib(fig_vecteur,hough_vector_max_theta,10,fig_vecteur_long,hough_vector_max_theta_90,5);
        pause;   
        clearfig(fig_img,fig_vecteur,fig_vecteur_long,fig_hough);
    else
        fprintf("segmentation to short for analyse")
        pause;
    end
    
end

function [V_res,I_res]= clear(V_dec,ind_dec)
    m=mean(V_dec);
    I_res = ind_dec(V_dec > m);
    V_res = V_dec(V_dec > m);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%AFFICHAGE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function affichage_img(fig_img,img,img_name,lines,lines_dec,rho_out,theta_out,rho_dec_out,theta_dec_out)
    figure(fig_img);
    imshow(img);hold on;
    title(img_name);
    truesize(fig_img);
    
    [height, width] = size(img);
    %Plot lines using rho and theta
    for i=1:length(rho_out(1,:))
        %Exception for theta=0, y1-> inf
        if theta_out(i)==0
            plot([rho_out(i),rho_out(i)],[1,height],'LineWidth',1.5,'Color','red');
        end
        x1=1:width;
        y1 = ((rho_out(i)) - x1* cosd(theta_out(i)) )/ sind(theta_out(i));
        pixel=[x1',round(y1)'];
        rowsToDelete = any(pixel<0, 2);
        pixel(rowsToDelete,:) = [];
        img(pixel(1,1),pixel(1,2))=255;
        %I_res = ind_dec(V_dec > m);
      
        plot(x1,y1,'LineWidth',1.5,'Color','red');
    end
    for i=1:length(rho_dec_out(1,:))
        %Exception for theta=0, y1-> inf
        if theta_dec_out(i)==0
            plot([rho_dec_out(i),rho_dec_out(i)],[1,height],'LineWidth',1.5,'Color','red');
        end
        x1=1:width;
        y1 = ((rho_dec_out(i)) - x1* cosd(theta_dec_out(i)) )/ sind(theta_dec_out(i));
        plot(x1,y1,'LineWidth',1.5,'Color','blue');
    end
    imshow(img);
%     
%     for k = 1:length(lines)
%         xy = [lines(k).point1; lines(k).point2];
%         plot(xy(:,1),xy (:,2),'LineWidth',2,'Color','green');
%       % Plot beginnings and ends of lines
%         plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
%         plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
%     end
%     for k = 1:length(lines_dec)
%         xy = [lines_dec(k).point1; lines_dec(k).point2];
%         plot(xy(:,1),xy (:,2),'LineWidth',2,'Color','blue');
%       % Plot beginnings and ends of lines
%         plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
%         plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
%     end
%     hold off;
end
function affichage_hough(fig_hough,hough,theta,rho,I,I_dec,max_theta,max_theta_dec)
    figure(fig_hough);hold on;
    imshow(imadjust(rescale(hough)),'XData',theta,'YData',rho,'InitialMagnification','fit');
    title('Hough transform');
    xlabel('\theta'), ylabel('\rho');
    axis on, axis normal;
    
    roh_theta = rho(I(:));
    roh_theta_dec = rho(I_dec(:));
    t=length(I);
    t_dec=length(I_dec);
    if (t ~= 0 || t_dec ~= 0)
        plot(max_theta,roh_theta,'s','color','red'); 
        plot(max_theta_dec,roh_theta_dec,'s','color','red');  
    end
    hold off;
end
function []=affichage_distrib(fig_vec,vec,vec_dist,fig_vec90,vec90,vec_dist90)
    figure(fig_vec);
    hold on;
    vec=[0,nonzeros(vec)'];
    vec=[vec,0];
    [V_plot,I_plot]=findpeaks(vec,'WidthReference','halfheight');%'WidthReference','halfheight','MinPeakDistance',vec_dist
    [V_plot,I_plot]=clear(V_plot,I_plot);
    plot(vec);
    plot(I_plot,V_plot,'o');
    hold off;
    
    figure(fig_vec90);
    hold on;
    vec90=[0,nonzeros(vec90)'];
    vec90=[vec90,0];
    [V_plot_dec,I_plot_dec]=findpeaks(vec90,'WidthReference','halfheight');%'MinPeakDistance',vec_dist90
    [V_plot_dec,I_plot_dec]=clear(V_plot_dec,I_plot_dec);
    plot(vec90);
    plot (I_plot_dec,V_plot_dec,'o');
    hold off;
end
function []= clearfig(fig_img,fig_vecteur_long,fig_vecteur_long_90,fig_hough)
    figure(fig_img);
    clf('reset')
    figure(fig_vecteur_long);
    clf('reset')
    figure(fig_vecteur_long_90);
    clf('reset')
    figure(fig_hough);
    clf('reset')
end

