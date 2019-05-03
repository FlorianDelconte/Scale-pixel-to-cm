close all

path_img='../DATA/PNG/sgm_mire/img_canny/B/msk/';
%obtient la liste des images 
filelist_img=[dir(strcat(path_img,'*.png'));dir(strcat(path_img,'*.PNG'))];
nfiles = length(filelist_img);

fig_img=figure('Name','contour');
fig_pixel =figure('Name','test');
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
        [H,theta,rho] = hough(contour,'RhoResolution',3);
        %%%%DETECTION DES LIGNES HORIZONTALES%%%%
        ind_max_p = houghpeaks(H,1);
        theta_max = theta(ind_max_p(2));
        hough_vector_max_theta=H(:,ind_max_p(2));
        [V,I,w]=findpeaks(hough_vector_max_theta,'WidthReference','halfheight');%'MinPeakDistance',10
        %w=w.*5;
        %%%%DETECTION DES LIGNES +90 DEGREES%%%%%
        ind_dec_p = mod(ind_max_p(2)+90,180);
        theta_dec = theta(ind_dec_p);
        hough_vector_max_theta_90=H(:,ind_dec_p);
        [V_dec,I_dec,w_dec]=findpeaks(hough_vector_max_theta_90,'WidthReference','halfheight');%'MinPeakDistance',5
        %w_dec=w_dec.*5; 
        %%%%NETOYAGE VECTEURS%%%%%%%%%%%%%%%%%%%%
        [V,I,w]=clear(V,I,w);
        [V_dec,I_dec,w_dec]=clear(V_dec,I_dec,w_dec);
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
        %%%%EXTRACTION DES PIXELS ASSOCIER AUX DROITES%%%%%%%%%%%%%%%%
        %get_pixel_line_by_hough(P,P_dec,contour,theta,rho,fig_pixel,w/2);
        pixel_line=get_pixel_line_by_normal(fig_img, contour,rho,theta,P,w);
        %%%%LINES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        lines = houghlines(contour,theta,rho,P,'FillGap',10000);
        lines_dec = houghlines(contour,theta,rho,P_dec,'FillGap',10000);      
        %%%%AFFICHAGE%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        affichage_pixel_normal(fig_pixel,contour,pixel_line);
        affichage_img(fig_img,contour,filelist_img(i).name,lines,lines_dec,rho_out,theta_out,rho_dec_out,theta_dec_out);
        affichage_hough(fig_hough,H,theta,rho,I,I_dec,theta_max,theta_dec);
        affichage_distrib(fig_vecteur,hough_vector_max_theta,10,fig_vecteur_long,hough_vector_max_theta_90,5);
        pause;   
        clearfig(fig_img,fig_vecteur,fig_vecteur_long,fig_hough,fig_pixel);
    else
        fprintf("segmentation to short for analyse")
        pause;
    end
    
end

function [V_res,I_res,w_res]= clear(V_dec,ind_dec,w)
    m=mean(V_dec);
     
    t=[V_dec ind_dec w];
    t(t(:,1)<m, :)=[];
    
    V_res=t(:,1);
    I_res= t(:,2);
    w_res = t(:,3);
end
function get_pixel_line_by_hough(P,P_dec,contour,theta,rho,fig_pixel,w)
    [m,n]=size(P)
    [m_dec,n_dec]=size(P_dec)
    [m_img,n_img]=size(contour)
    figure(fig_pixel);hold on; 
    final_image=zeros(m_img,n_img,3);
    final_R=zeros(m_img,n_img,1);
    final_B=zeros(m_img,n_img,1);
    %%FOR RED LINE%%
    for i=1:m%pour chaque peaks
        [r, c] = hough_bin_pixels(contour, theta, rho, P(i,:),w);   %--> w est la largeur de la prominence du peaks selectionné
        R=add_pixel_to_image(r,c,m_img,n_img);
        final_R = imadd(R,final_R);
    end
    %%FOR BLUE LINE%%
    for i=1:m_dec
        [r, c] = hough_bin_pixels(contour, theta, rho, P_dec(i,:),w );   %--> w est la largeur de la prominence du peaks selectionné
        B=add_pixel_to_image(r,c,m_img,n_img);
        final_B = imadd(B,final_B);
    end
    final_image(:,:,1)=final_R;
    final_image(:,:,3)=final_B;
    imshow(final_image);
    hold off;
end
function [pixel_line]=get_pixel_line_by_normal(fig_img,contour,rho,theta,P,w)
    [height, width] = size(contour);
    figure(fig_img );
    imshow(contour );hold on;
    
    numdroite=2;
    
    %largeur/theta/rho de la droite courante
    largeur_d=w(numdroite);
    theta_d=theta(P(numdroite,2 ));
    rho_d=rho(P(numdroite,1));
    %creation de la droite
    x = 1:width;
    y = (rho_d - x* cosd(theta_d ))/ sind(theta_d);
    %retrait des morceaux de droite en dehors de l'image
    y=y';
    x=x';
    pts_droite=[x y];
    pts_droite(pts_droite(:,2)<0, :)=[];
    pts_droite(pts_droite(:,2)>height, :)=[];
    x=pts_droite(:,1);
    y=pts_droite(:,2);
    nb_point=length(x);
    y_dist=0;
    x_dist=0;
    pts_normal1=[];
    pts_normal2=[];
    pixel_normal=[];
    img=zeros(size(contour));
    pixel_line=[];
    for i = 1:nb_point
        numpixeldroite=i;
        %calcul du deuxièmme point de la normal
        if(i==1)
            y_dist=sind(theta_d)*(largeur_d/2);
            x_dist=cosd(theta_d)*(largeur_d/2);
        end
        pts_droite(numdroite,1);
        pts_droite(numdroite,2);
        point1= [pts_droite(numpixeldroite,1)  pts_droite(numpixeldroite,2)];
        point2= [point1(1)-x_dist point1(2)-y_dist];
        point3= [point1(1)+x_dist point1(2)+y_dist];
        pts_normal1=[pts_normal1 ;point2];
        pts_normal2=[pts_normal1 ;point3];
        normal_x=[point1(1) point2(1) point3(1)];
        normal_y=[point1(2) point2(2) point3(2)];
        %plot(normal_x,normal_y,'LineWidth',1.5,'Color','yellow');  
        [x,y]=bresenham(point2(1),point2(2),point3(1),point3(2));
        %pixels= [x,y] ;
%         pixels(pixels(:,1)<=0, :)=[];
%         pixels(pixels(:,1)>width, :)=[];
%         pixels(pixels(:,2)<=0, :)=[];
%         pixels(pixels(:,2)>height, :)=[];
       % pixels(:,1);
       % pixels(:,2);
        %contour(sub2ind(size(contour),pixels(:,2),pixels(:,1))) = 255;
  
        [x,y]=get_nearest_pixel_line(point1,[x,y],contour);
        pixel_line=[pixel_line;[x,y]];
        %pixel_normal=[pixel_normal;pixels];
    end
     %imshow(contour );hold on;
end

function [x, y]=get_nearest_pixel_line(point_droite, pixels, image)
    pixels;
    point_droite;
    nb_pix=length(pixels(:,1));
    true_pix=[];
    for i = 1:nb_pix
        if(image(pixels(i,2),pixels(i,1))>0 )
            p=[pixels(i,1),pixels(i,2)];
            true_pix=[true_pix ;p];
        end
    end
    nb_true_pix=length(true_pix);
    %par defaut un si aucun pixel est blanc sur la  normal, x,y valent -1
    x=-1;
    y=-1;
    if(nb_true_pix>0  )
        distance=sqrt(((true_pix(:,2)-point_droite(2))+(true_pix(:,1)-point_droite(1))).*((true_pix(:,2)-point_droite(:,2))+(true_pix(:,1)-point_droite(:,1))));
        [v,indice] = min(distance);
         x=true_pix(indice,1);
         y=true_pix(indice,2);
     end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%AFFICHAGE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function affichage_pixel_normal(fig_pixel,contour,pixel_line)
    figure(fig_pixel);
   
    [m_img,n_img]=size(contour);
    final_image=zeros(m_img,n_img,3);
    %[h,w]=size(contour)
    img=zeros(m_img,n_img,1);
    size(img);

    pixel_line;
    for i = 1:length(pixel_line);
        %img(sub2ind(size(img),pixel_line(:,2),pixel_line(:,1))) = 255;
        %pixel_line(i,2),pixel_line(i,1);
        if(pixel_line(i,2)>-1 && pixel_line(i,1)>-1)
            %img(pixel_line(i,2),pixel_line(i,1))=255;
            pixel_line(i,2);
            pixel_line(i,1);
            img(sub2ind(size(img),pixel_line(i,2),pixel_line(i,1))) = 255;
        end
    end
    size(pixel_line);
    size(img);
    final_image(:,:,1)=img;
    final_image(:,:,2)=contour ;
    imshow(final_image);hold on;
    truesize(fig_pixel );
    
    hold off;
end
function [imageC]=add_pixel_to_image(r,c,m_img,n_img)
     imageC=zeros(m_img,n_img,1);
     imageC(sub2ind([m_img,n_img], r, c)) = 255;
end
function affichage_img(fig_img,img,img_name,lines,lines_dec,rho_out,theta_out,rho_dec_out,theta_dec_out)
    figure(fig_img);
    imshow(img);hold on;
    title(img_name);
    truesize(fig_img);
    
    [height, width] = size(img);
    %Plot lines using rho and theta
    for i=1:length(rho_out(1,:))
        if theta_out(i)==0
            %plot([rho_out(i),rho_out(i)],[1,height],'LineWidth',1.5,'Color','red');
        end
        x1=1:width;
        y1 = ((rho_out(i)) - x1* cosd(theta_out(i)) )/ sind(theta_out(i));
        %%%
        y1=y1';
        x1=x1';
        pts=[x1 y1];
        pts(pts(:,2)<0, :)=[];
        pts(pts(:,2)>height, :)=[];
        %plot(pts(:,1),pts(:,2),'Color','yellow','r*');
        plot(pts(:,1),pts(:,2),'LineWidth',1.5,'Color','red');
    end
    for i=1:length(rho_dec_out(1,:))
        if theta_dec_out(i)==0
            %plot([rho_dec_out(i),rho_dec_out(i)],[1,height],'LineWidth',1.5,'Color','red');
        end
        x1=1:width;
        y1 = ((rho_dec_out(i)) - x1* cosd(theta_dec_out(i)) )/ sind(theta_dec_out(i))  ; 
        y1=y1';
        x1=x1';
        pts=[x1,y1];
        pts(pts(:,2)<0, :)=[];
        pts(pts(:,2)>height, :)=[];
%         x1=pts(:,1);
%         y1=pts(:,2);
        plot(pts(:,1),pts(:,2),'LineWidth',1.5,'Color','blue');
    end
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
    [V_plot,I_plot,w]=findpeaks(vec,'WidthReference','halfheight');%'WidthReference','halfheight','MinPeakDistance',vec_dist
    [V_plot,I_plot]=clear(V_plot,I_plot,w);
    plot(vec);
    plot(I_plot,V_plot,'o');
    hold off;
    
    figure(fig_vec90);
    hold on;
    vec90=[0,nonzeros(vec90)'];
    vec90=[vec90,0];
    [V_plot_dec,I_plot_dec,w_dec]=findpeaks(vec90,'WidthReference','halfheight');%'MinPeakDistance',vec_dist90
    [V_plot_dec,I_plot_dec]=clear(V_plot_dec,I_plot_dec,w_dec);
    plot(vec90);
    plot (I_plot_dec,V_plot_dec,'o');
    hold off;
end
function []= clearfig(fig_img,fig_vecteur_long,fig_vecteur_long_90,fig_hough,fig_pixel)
    figure(fig_img);
    clf('reset')
    figure(fig_vecteur_long);
    clf('reset')
    figure(fig_vecteur_long_90);
    clf('reset')
    figure(fig_hough);
    clf('reset')
    figure(fig_pixel);
    clf('reset')
end

