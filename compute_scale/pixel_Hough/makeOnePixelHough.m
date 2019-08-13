
%%
%extract pixel associated to Hough line which respect a checkboard pattern
%-------entrée--------
%img_RGB : matrix rgb picture 
%img_SGM : matrix sgm picture
%%
function [hough_line_pixels,hough_line_pixels_dec]=makeOnePixelHough(img_RGB , img_SGM)
    close all;
    %input image
    img=img_RGB;
    img_sgm=img_SGM;
    %apply several treatments to prepare apply Hough, 
    %shape_ouline is img treated
    %proportion is the proportion of white pixel in the shape_ouline matrix
    [shape_outline,proportion]=pretreatment(img,img_sgm);
    %we assume that if proportion is < 0.015 then, there is no checkboard to
    %detect
    if(proportion >=0.007)%0.015
        %make a density picture map in grayscale (white pixel means that the pixel in considered dense 
        %clear the shape_outline given in paramater
        %compute the ratio of pixel dense
        [density_picture,shape_outline_clear,ratio]=densite(shape_outline,24,9);%img canny,taille fenetre, seuil 

        %we clear the shape_outline onely if ratio is > 0.4
        if(ratio>=0.4)
            shape_outline=shape_outline_clear;
        end
        %use Hough, matlab toolbox : https://de.mathworks.com/help/images/ref/hough.html#buwgokq-6
        [H,theta,rho] = hough(shape_outline,'RhoResolution',5);
        %%%%HORIZONTAL vote vector%%%%
        %use houghpeaks to find the max peak in hough transform https://de.mathworks.com/help/images/ref/houghpeaks.html
        maxPeak = houghpeaks(H,1);
        theta_maxPeaks = theta(maxPeak(2));
        vote_max_theta=H(:,maxPeak(2));
        %%%%VERTICAL vote vector%%%%%
        ind_dec_p = mod(maxPeak(2)+90,180);
        theta_dec = theta(ind_dec_p);
        vote_max_theta_dec=H(:,ind_dec_p);
        %%%%CLEAR VOTE to get rho value%%%%
        % 0 pour les droites horizontales
        [vote_max_theta_clear,rho_indice_clear,prominence]=clearHoughVecteur(rho,vote_max_theta,0);
        % 1 pour les droites verticales
        [vote_max_theta_dec_clear,rho_indice_dec_clear,prominence_dec]=clearHoughVecteur(rho,vote_max_theta_dec,1);
        %check if the clear operation let at least one value
        if(isempty(vote_max_theta_clear)==0 && isempty(vote_max_theta_dec_clear)==0)
            %%%%Lines creation%%%%%%%%%%%%%%%%%%%
            horizontal_lines=zeros(length(rho_indice_clear),1);
            horizontal_lines(:)=theta(maxPeak(2));
            horizontal_lines=[rho(rho_indice_clear(:))',horizontal_lines];
            vertical_lines=zeros(length(rho_indice_dec_clear),1);
            vertical_lines(:)=theta(ind_dec_p);
            vertical_lines=[rho(rho_indice_dec_clear(:))',vertical_lines];
            %%%%EXTRACTION DES PIXELS ASSOCIER AUX DROITES%%%%%%%%%%%%%%%%
            %get_pixel_line_by_hough(P,P_dec,contour,theta,rho,fig_pixel,w/2);
            hough_line_pixels=get_pixel_line_by_normal(shape_outline,horizontal_lines,prominence);
            hough_line_pixels_dec=get_pixel_line_by_normal( shape_outline,vertical_lines,prominence_dec);
            %%%%AFFICHAGE%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %afficheur(shape_outline,hough_line_pixels,hough_line_pixels_dec,horizontal_lines,vertical_lines,H,theta,rho,rho_indice_clear,rho_indice_dec_clear,theta_maxPeaks,theta_dec,vote_max_theta,vote_max_theta_clear,prominence,vote_max_theta_dec,vote_max_theta_dec_clear,prominence_dec,density_picture)  
            %pause;
        else
            fprintf("verticales or horizontales line detection problem\n")
            hough_line_pixels=[];
            hough_line_pixels_dec=[];
        end
    else
        fprintf("segmentation to short for analyse\n")
        hough_line_pixels=[];
        hough_line_pixels_dec=[];   
    end
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
    
    (final_image);
    hold off;
end
function [firstdroite]=get_pixel_line_by_pavage(fig_img,contour,rho,theta,P,P_dec,w)
    [height, width] = size(contour);  
    firstdroite=[];
    %[nbligne,nbcolonne] = size(P);
    numdroite=1  ;
    %première droite
    theta_d=theta(P(numdroite,2 ));
    rho_d=rho(P(numdroite,1));
    %première normal
    theta_n=theta(P_dec(numdroite,2 ));
    rho_n=rho(P_dec(numdroite,1));
    %creation de la droite courante
    x1_d = 1;
    y1_d = round((rho_d - x1_d* cosd(theta_d ))/ sind(theta_d));
    x2_d = width; 
    y2_d = round((rho_d - x2_d* cosd(theta_d ))/ sind(theta_d));
    %creation de la droite
    a_d=y2_d-y1_d;
    b_d=x2_d-x1_d;
    g_d=gcd(a_d,b_d); 
    a_d=a_d/g_d;
    b_d=b_d/g_d ;
    mu_d=(a_d*x1_d)-(b_d*y1_d);
    wd=max(abs(a_d),abs(b_d));
    [firstdroite,freeman,c1,c2]=droiteNaive(contour,a_d,b_d,mu_d,wd,x1_d,y1_d);
  
    plot(firstdroite(:, 1),firstdroite(:,2),'o','Color','red' )
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%creation de la structure normal
    a_n=-b_d;
    b_n= a_d;
    x1_n=firstdroite(1,1);
    y1_n=firstdroite(1,2);
    mu_n=((a_n*x1_n)-(b_n*y1_n));
    wn=max(abs(a_n),abs(b_n));
    %demi normal naive
    [pixel_all_line_dec_up,freeman_dec,c1_dec,c2_dec]=droiteNaive(contour,a_n,b_n,mu_n,wn,x1_n,y1_n);
    
    %extraction du pattern
    pattern_dec=extract_pattern(freeman_dec,a_n,b_n);
    
    %construction de la normal complete par la structure
    pixel_droite=getPixelByStructure(a_n,b_n,mu_n ,pattern_dec,contour);

    plot(pixel_droite(:, 1), pixel_droite(:,2),'o','Color','green');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    all_pixel=[];
    [nbligne,nblcolonne] = size(P);
    for n = 2 :nbligne 
        theta_current=theta(P(n,2));
        rho_current=rho(P(n,1));
        %discrétisation des autres droites à partir de la structure 
%         pixel_droite=getPixelByStructure(theta_current ,rho_current,pattern,contour);
%         plot(pixel_droite(:,1),pixel_droite(:,2),'o','Color','blue' );
        %discrétisation naïve
        x1_d = 1;
        y1_d = round((rho_current - x1_d* cosd(theta_current ))/ sind(theta_current));
        x2_d = width; 
        y2_d = round((rho_current - x2_d* cosd(theta_current ))/ sind(theta_current));
        a_d=y2_d-y1_d;
        b_d=x2_d-x1_d;
        g_d=gcd(a_d,b_d); 
        a_d=a_d/g_d;
        b_d=b_d/g_d ;
        mu_d=(a_d*x1_d)-(b_d*y1_d);
        wd=max(abs(a_d),abs(b_d));
        [pixel,freeman,c1,c2]=droiteNaive(contour,a_d,b_d,mu_d,wd,x1_d,y1_d);
        plot(pixel(:,1),pixel(:,2),'o','Color','red' );
    end 
    

  
 end
function [pixel_droite]=getPixelByStructure(a,b,c,structure,contour)
    [height, width] = size(contour);  
    xd2 = 1;
    %yd2 = round((rho - xd2* cosd(theta ))/ sind(theta)); 
    yd2=round((c-(a*xd2))/(-b));
    pixel_droite=[xd2 yd2];
    p=1;
    while(xd2<width )
        if(p<=length(structure))
            if(structure(p)==0)
                xd2=xd2+1;
                pixel_droite=[pixel_droite ; xd2 yd2];
            end
            if(structure(p)==1)
                xd2=xd2+1;
                yd2=yd2+1;
                pixel_droite=[pixel_droite ; xd2 yd2];
            end
            if(structure(p)==2)
                yd2=yd2+1;
                pixel_droite=[pixel_droite ; xd2 yd2];
            end
            if(structure(p)==3)
                xd2=xd2-1;
                yd2=yd2+1;
                pixel_droite=[pixel_droite ; xd2 yd2];
            end
            if(structure(p)==4)
                xd2=xd2-1;
                pixel_droite=[pixel_droite ; xd2 yd2];
            end
            if(structure(p)==5)
                xd2=xd2-1;
                yd2=yd2-1;
                pixel_droite=[pixel_droite ; xd2 yd2];
            end
            if(structure(p)==6)
                yd2=yd2-1;
                pixel_droite=[pixel_droite ; xd2 yd2];
            end
            if(structure(p)==7)
                xd2=xd2+1;
                yd2=yd2-1;
                pixel_droite=[pixel_droite ; xd2 yd2];
            end
            
        else
            p=0;
        end
        p=p+1;
    end
end
function [pattern]=extract_pattern(freeman_code,a,b)
    %la longueur de la période est défini par a ou b 
    periode=max(abs(a),abs(b));
    if(periode<=length(freeman_code))
        pattern=freeman_code(1:periode);
    else
        pattern=freeman_code;
    end
end
function [pixel_droite,freeman,c1,c2]=droiteNaive(contour,a,b,mu,w,x1,y1)
    x=x1;
    y=y1;

    [height, width] = size(contour); 
    nbp=max(height,width);
    pixel_droite= [];
    freeman= [];
     code=-1;
     c1=-1;
     c2=-1;
    for i = 1:nbp
         %if((x>0 && x<=width) && (y>0 && y<=height))   
         pixel_droite=[pixel_droite; [x y]];
         if(code ~=-1)
            freeman= [freeman; code];
         end
         %end
         %octant haut/droite
         if(a>=0 && b>=0)
            if(abs(b)>abs(a)) 
                if(((mu<=(a*x)-(b*y)) && ((a*x)-(b*y)<(mu+w-1))))
                    x=x+1; 
                    code=0;
                    c1=code;
                else
                    x=x+1; 
                    y=y+1;
                    code=1;
                    c2=code;
                end
            else
                if(((mu<=(a*x)-(b*y)) && ((a*x)-(b*y)<(mu+w-1))))
                    y=y+1;    
                    code=2;
                    c1=code;
                else
                    x=x+1; 
                    y=y+1;
                    code=1;
                    c2=code;
                end
            end
         end
         %octant bas/droite
         if(a<=0 && b>=0)
            if(abs(b)>abs(a)) 
                if(((mu<=(a*x)-(b*y)) && ((a*x)-(b*y)<(mu+w-1))))
                    x=x+1;   
                    code=0;
                    c1=code;
                else
                    x=x+1; 
                    y=y-1;
                    code=7;
                   c2=code;
                end
            else
                if(((mu<=(a*x)-(b*y)) && ((a*x)-(b*y)<(mu+w-1))))
                    y=y-1; 
                    code=6;
                   c1=code;
                else
                    x=x+1; 
                    y=y-1;
                    code=7;
                    c2=code;
                end
            end
         end
         %octant bas/gauche
         if(a<=0 && b<=0)
            if(abs(b)>abs(a)) 
                if(((mu<=(a*x)-(b*y)) && ((a*x)-(b*y)<(mu+w-1))))
                    x=x-1;   
                    code=4
                    c1=code;
                else
                    x=x-1; 
                    y=y-1;
                    code=5;
                    c2=code;
                end
            else
                if(((mu<=(a*x)-(b*y)) && ((a*x)-(b*y)<(mu+w-1))))
                    y=y-1; 
                    code=6;
                    c1=code;
                else
                    x=x-1; 
                    y=y-1;
                    code=5;
                    c2=code;
                end
            end
         end
         %octant haut/gauche
         if(a>=0 && b<=0)
           if(abs(b)>abs(a)) 
                if(((mu<=(a*x)-(b*y)) && ((a*x)-(b*y)<(mu+w-1))))
                    x=x-1;  
                    code=4;
                    c1=code;
                else
                    x=x-1; 
                    y=y+1;
                    code=3;
                    c2=code;
                end
            else
                if(((mu<=(a*x)-(b*y)) && ((a*x)-(b*y)<(mu+w-1))))
                    y=y+1;  
                    code=2;
                    c1=code;
                else
                    x=x-1; 
                    y=y+1;
                    code=3
                    c2=code;
                end
            end
         end 
    end  
end
function [pixel_all_line]=get_pixel_line_by_normal(contour,P,w)
    [height, width] = size(contour);  
    pixel_all_line=[];
    [nbligne,nblcolonne] = size(P);
    %trie du P en fonction de la distance à l'origine
    P=sortrows(P,1);
    for j = 1:nbligne
        numdroite=j;
        %largeur/theta/rho de la droite courante
        largeur_d=w(numdroite)*5;
        theta_d=P(numdroite,2 );
        rho_d=P(numdroite,1);
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
