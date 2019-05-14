close all

path_img='../DATA/PNG/sgm_mire/img_canny/R/msk/';
path_write='../DATA/PNG/sgm_mire/pixel_line/';
filelist_img=[dir(strcat(path_img,'*.png'));dir(strcat(path_img,'*.PNG'))];
nfiles = length(filelist_img);

fig_img=figure('Name','contour');
fig_pixel =figure('Name','pixels');
fig_hough=figure('Name','hough space');
fig_vecteur=figure('Name','vecteur theta max');
fig_vecteur_long=figure('Name','vecteur theta max +90');

for i = 1 :nfiles
    filelist_img(i);
    if(check_sgm(filelist_img(i).name)==1)
        filelist_img(i).name
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
        %pixel_all_line=get_pixel_line_by_normal(fig_img, contour,rho,theta,P,w);
        %pixel_all_line_dec=get_pixel_line_by_normal(fig_img, contour,rho,theta,P_dec,w_dec);
        get_pixel_line_by_pavage(fig_img, contour,rho,theta,P,w); 
        %%%%LINES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%         lines = houghlines(contour,theta,rho,P,'FillGap',10000);
%         lines_dec = houghlines(contour,theta,rho,P_dec,'FillGap',10000);   
        %%%%ECRITURE%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %write_file(strcat(path_write, strrep(filelist_img(i).name,'.png','.dat')),pixel_all_line);
        %%%%AFFICHAGE%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %affichage_pixel_normal(fig_pixel,contour,pixel_all_line,pixel_all_line_dec);
        affichage_img(fig_img,contour,filelist_img(i).name,rho_out,theta_out,rho_dec_out,theta_dec_out);
        affichage_hough(fig_hough,H,theta,rho,I,I_dec,theta_max,theta_dec);
        affichage_distrib(fig_vecteur,hough_vector_max_theta,[V,I,w],fig_vecteur_long,hough_vector_max_theta_90,[V_dec,I_dec,w_dec],rho);
        pause;   
        clearfig(fig_img,fig_vecteur,fig_vecteur_long,fig_hough,fig_pixel);
    else
        fprintf("segmentation to short for analyse")
        pause;
    end
    
end

function write_file(file_name,pixels_lines)
    %file_name : le chemin+le nom du fichier à écrire
    %pixels_lines : enssemble des pixels appartenant aux droites sous la forme
    %: X11 Y11 X21 Y21 X31 Y31 ... 
    %: X12 Y12 X22 Y22 X32 Y32 ... 
    %: X13 Y13 X23 Y23 X33 Y33 ... 
    %: X14 Y14 X24 Y24 X34 Y34 ... 
    file_name;
    pixels_lines;
    csvwrite(file_name,pixels_lines);
end
function [V_res,I_res,w_res]= clear(V_dec,ind_dec,w)
    m=mean(V_dec);
    
    t=[V_dec ind_dec];
    t=[t w];
    %t
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
function [pixel_all_line]=get_pixel_line_by_pavage(fig_img,contour,rho,theta,P,w)
    [height, width] = size(contour);  
    pixel_all_line=[];
    [nbligne,nbcolonne] = size(P);
    figure(fig_img);
    imshow(contour);hold on;
    numdroite=4 ;
    %largeur/theta/rho de la droite courante
    %largeur_d=w(numdroite)*2;
    theta_d=theta(P(numdroite,2 ));
    rho_d=rho(P(numdroite,1));
    %rho_d
    %rho(P(3,1))
    %creation de la droite courante
    rho_d
    x1 = 0;
    y1 = round((rho_d - x1* cosd(theta_d ))/ sind(theta_d));
    x2 = width;
    y2 = round((rho_d - x2* cosd(theta_d ))/ sind(theta_d));

  
    
    plot([x1 x2],[y1 y2],'color','red');
    
    %coeficient a,b,mu et w de la norm
    a=y2-y1;
    b=x2-x1;
    g=gcd(a,b) 
    a=a/g;
    b=b/g; 

    mu=rho_d;
    ww=max(abs(a),abs(b));

    D=droiteNaive(contour,a,b,mu,ww,x1,x2,y1,y2);
    plot(D(:,1),D(:,2),'o','color','yellow'); 
    plot([x1 x2],[y1 y2],'o','color','red');
    pause;
end

function [pixel_droite]=droiteNaive(contour,a,b,mu,w,x1,x2,y1,y2)
    x=x1;
    y=y1;
    deltaX=x2-x1;
    pixel_droite= [];
     for i = 1:deltaX
        pixel_droite=[pixel_droite; [x y]];
        if((mu<=(a*x)-(b*y)) && ((a*x)-(b*y)<(mu+w-1)))
            x=x+1;    
        else
            x=x+1;
            y=y+1;
        end
    end
    
end
function [pixel_all_line]=get_pixel_line_by_normal(fig_img,contour,rho,theta,P,w)
    [height, width] = size(contour);  
    pixel_all_line=[];
    [nbligne,nblcolonne] = size(P);
    for j = 1:nbligne
        numdroite=j;
        %largeur/theta/rho de la droite courante
        largeur_d=w(numdroite)*10;
        theta_d=theta(P(numdroite,2 ));
        rho_d=rho(P(numdroite,1));
        %creation de la droite courante
        if(abs(theta_d)>=45)
            x = 1:width;
            y = (rho_d - x* cosd(theta_d ))/ sind(theta_d);
        else
            y = 1:height;
            x = (rho_d - y* sind(theta_d ))/ cosd(theta_d);
        end
        y=y';
        x=x';
        pts_droite=[x y];
        %extraction des (x,y) des point sur lesquelles tracer la normal
        x=pts_droite(:,1);
        y=pts_droite(:,2);
        pixel_line=[];
        y_dist=0;
        x_dist=0;
        nb_point=length(x);
        point_droite=[];
        %parcours de chaque point extrait précédement
        for i = 1:nb_point
            numpixeldroite=i;
            %calcul des décalage x, y à faire sur chaque discrétisation de la
            %droite pour obtenir les points aux extrémités de la normal
            if(i==1)
                y_dist=sind(theta_d)*(largeur_d/2);
                x_dist=cosd(theta_d)*(largeur_d/2);
            end
            %point actuel de la droite
            point_droite= [pts_droite(numpixeldroite,1)  pts_droite(numpixeldroite,2)];
            %point extremite de la normal
            extrem_x1=point_droite(1)-x_dist;
            extrem_y1=point_droite(2)-y_dist;
            point_normal1= [extrem_x1 extrem_y1]; 
            %deuxièmme point extremite de la normal
            extrem_x2=point_droite(1)+x_dist;
            extrem_y2=point_droite(2)+y_dist;
            point_normal2= [extrem_x2 extrem_y2];

            %calcul du segment discret entre les deux points de la normal
            [x,y]=bresenham(point_normal1(1),point_normal1(2),point_normal2(1),point_normal2(2));
            %selection du pixel blanc (de la normal) le plus proche de la
            %droite
            [x,y]=get_nearest_pixel_line(point_droite,[x,y],contour);
            %concatenation des pixels selectionne dans une liste
            pixel_line=[pixel_line;[x,y]];
        end
        pixel_all_line=[pixel_all_line, pixel_line];
    end
end
function [x, y]=get_nearest_pixel_line(point_droite, pixels, image)
    [height, width] = size(image);  
    nb_pix=length(pixels(:,1));
    true_pix=[];
    %parcours de tous les pixels
    for i = 1:nb_pix
        %si le pixel existe
        if((pixels(i,2)>0 && pixels(i,2)<=height) && (pixels(i,1)>0 && pixels(i,1)<=width))
            %selection des pixels blanc
            if(image(pixels(i,2),pixels(i,1))>0 )
                p=[pixels(i,1),pixels(i,2)];
                true_pix=[true_pix ;p];
            end
        end
    end
    nb_true_pix=length(true_pix);
    %par defaut un si aucun pixel est blanc sur la  normal, x,y valent -1
    x=-1;
    y=-1;
    %selection du pixels le plus proche de la droite par distance
    %euclidienne
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
function affichage_pixel_normal(fig_pixel,contour,pixel_all_line,pixel_all_line_dec)
    figure(fig_pixel);
    [m_img,n_img]=size(contour);
    %creation de trois composante de couleur
    final_image=zeros(m_img,n_img,3);
    %les droites rouges sont les droites horizontal
    droite_rouge=zeros(m_img,n_img,1);
    %Les droites bleu sont les droites vertical
    droite_bleu=zeros(m_img,n_img,1);
    %nombre de ligne/colonne de la matrice des droite pixelisé 
    [nbligne,nbcolonne]=size(pixel_all_line);
    %pixel_all_line est composé [x,y] * nbdroite colonne (2colonne
    %correspond à 1 droite discrète)
    for j = 1:2:nbcolonne
        %extraction des composante x de la droite discrète
        pixel_line=pixel_all_line(:,j);
        j=j+1;
        %extration des composante y de la droite discrète
        pixel_line=[pixel_line  ,pixel_all_line(:,j)];
        % parcours des deux colonne le long des lignes
        for i = 1:nbligne
            if(pixel_line(i,2)>-1 && pixel_line(i,1)>-1 )
                droite_rouge(sub2ind(size(droite_rouge),pixel_line(i,2),pixel_line(i,1))) = 255;
            end
        end
    end
    %nombre de ligne/colonne de la matrice des droite decalé pixelisé 
    [nbligne,nbcolonne]=size(pixel_all_line_dec);
    for j = 1:2:nbcolonne
        pixel_line=pixel_all_line_dec(:,j); 
        j=j+1;
        pixel_line=[pixel_line ,pixel_all_line_dec(:,j)];
        for i = 1:nbligne       
             if(pixel_line(i,2)>-1 && pixel_line(i,1)>-1)
                droite_bleu(sub2ind(size(droite_bleu),pixel_line(i,2),pixel_line(i,1))) = 255;
            end
        end
    end
    
    final_image(:,:,1)=droite_rouge;
    final_image(:,:,3)=droite_bleu;
    imshow(final_image);hold on;
    truesize(fig_pixel );
    hold off;
end
function affichage_img(fig_img,img,img_name,rho_out,theta_out,rho_dec_out,theta_dec_out)
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
function []=affichage_distrib(fig_vec,vec,P,fig_vec90,vec90,Pdec,rho)
    %P=[V,I,w] déjà clear 
    %Pdec=[Vdec,Idec,wdec] deja clear
    figure(fig_vec);
    hold on;
    ind=1:length(vec);%indice dec correspond aux rho; valeur de vec corrrespond aux nombre de vote dans hough
    plot(rho(ind),vec);
    plot(rho(P(:,2)),P(:,1),'o','color','red');
    hold off;
    
    figure(fig_vec90);
    hold on;
    ind_dec=1:length(vec90);
    plot(rho(ind_dec),vec90);
    plot(rho(Pdec(:,2)),Pdec(:,1),'o','color','red');
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

