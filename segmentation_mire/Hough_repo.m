close all
%path_img='../DATA/PNG/sgm_mire/img_masked_canny/R/';
path_img='../DATA/PNG/sgm_mire/img_canny/R/msk/';
path_write='../DATA/PNG/sgm_mire/pixel_line/';
filelist_img=[dir(strcat(path_img,'*.png'));dir(strcat(path_img,'*.PNG'))];
nfiles = length(filelist_img);
seuil_clear=30;
fig_contourClear=figure('Name','contour normal');
fig_densite=figure('Name','densite');
fig_img=figure('Name','contour');
fig_pixel =figure('Name','pixels');
fig_hough=figure('Name','hough space');
fig_vecteur=figure('Name','vecteur theta max');
fig_vecteur_long=figure('Name','vecteur theta max +90');
% nfiles
cpt=0;
for i = 1 :nfiles
    %if(i==52)
    filelist_img(i).name
    if(strcmp(filelist_img(i).name,"huawei_E088H_2.png")==1)
    if(check_sgm(filelist_img(i).name)==1)
        %%%%%%%%%%%%%OUVERTURE BOITE ENGLOBANTE IMG%%%%%%%%%%%%%%
        path_name=strcat(strcat(path_img, '/'), filelist_img(i).name);
        contour=imread(path_name);
        contour=bounding_box(filelist_img(i).name,contour);
        [img_densite,contour_clear,ratio]=densite(contour,24,9);%img canny,taille fenetre, seuil
        %si la proportion de pixel dense depasse 0.2 
        %ratio
        if(ratio>=0.4)
            contour=contour_clear;
        end

        %%%%%%%%%%%%%DETECTION DE LA MIRE%%%%%%%%%%%%%%%%%%%%%%%%
        [H,theta,rho] = hough(contour,'RhoResolution',5);
        %%%%DETECTION DES LIGNES HORIZONTALES%%%%
        ind_max_p = houghpeaks(H,1);
        theta_max = theta(ind_max_p(2));
        hough_vector_max_theta=H(:,ind_max_p(2));
        [V,I,w,prominence]=findpeaks(hough_vector_max_theta);%'WidthReference','halfheight'
        %%%%DETECTION DES LIGNES 90 (+ ou - 30 degree) DEGREES%%%%%
        ind_dec_p = mod(ind_max_p(2)+90,180);
        %ind_dec_p
        %[hough_vector_max_theta_90 ind_dec_p]=get_hough_vector_max(ind_dec_p,H,30,rho,seuil_clear);
        %ind_dec_p
        hough_vector_max_theta_90=H(:,ind_dec_p);
        theta_dec = theta(ind_dec_p); 
        [V_dec,I_dec,w_dec]=findpeaks(hough_vector_max_theta_90);%,'WidthReference','halfheight'
        %w_dec=w_dec.*5; 
        %%%%NETOYAGE VECTEURS%%%%%%%%%%%%%%%%%%%%
        %[V,I,w]=clear(V,I,w);
        %[V,I,w]=clear2(V,I,w,rho,seuil_clear);
        %[V,I,w]=clear3(V,I,w);
        [V,I,w]=clear3max(V,I,w,rho,prominence);
        if(V~=-1)
            cpt=cpt+1;
            [V_dec,I_dec,w_dec]=clear_dec(V_dec,I_dec,w_dec,rho,seuil_clear);
            %%%%CREATION DES PEAKS%%%%%%%%%%%%%%%%%%%
            P=zeros(length(I),1);
            P(:)=ind_max_p(2);
            P=[I(:),P];                 %--->P concontour_clear tient les indice de rho | theta 
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
            pixel_all_line=get_pixel_line_by_normal(contour,rho,theta,P,w);
            pixel_all_line_dec=get_pixel_line_by_normal( contour,rho,theta,P_dec,w_dec);
            %figure(fig_pixel);
            %pixel_all_line=get_pixel_line_by_pavage(fig_img, contour,rho,theta,P,P_dec,w);
            %%%%LINES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %       lines = houghlines(contour,theta,rho,P,'FillGap',10000);
    %       lines_dec = houghlines(contour,theta,rho,P_dec,'FillGap',10000);   
            %%%%ECRITURE%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %write_file(strcat(path_write, strrep(filelist_img(i).name,'.png','.dat')),pixel_all_line);
            %%%%AFFICHAGE%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           
            affichage_pixel_normal(fig_pixel,contour,pixel_all_line,pixel_all_line_dec);
            affichage_img(fig_img,contour,filelist_img(i).name,rho_out,theta_out,rho_dec_out,theta_dec_out);
            affichage_hough(fig_hough,H,theta,rho,I,I_dec,theta_max,theta_dec);
            affichage_distrib(fig_vecteur,hough_vector_max_theta,[V,I,w],fig_vecteur_long,hough_vector_max_theta_90,[V_dec,I_dec,w_dec],rho);
            affichage_densite(fig_densite,img_densite,filelist_img(i).name);
            
%             write_file(strcat(path_write,strrep(filelist_img(i).name, '.png', '.dat')),pixel_all_line);
%             write_file(strcat(path_write,strrep(filelist_img(i).name, '.png', '_dec.dat')),pixel_all_line_dec);
            pause;
            figure(fig_pixel);
            clf('reset')
            clearfig(fig_img,fig_vecteur,fig_vecteur_long,fig_hough,fig_pixel,fig_densite,fig_contourClear);
        end
    else
        fprintf("segmentation to short for analyse")
        %TODO : grossir la boite englobante et verifier qu'il y a 2 droite
        %horizontal et 4 droite vertical
    end
   end
    
end
cpt
function write_file(file_name,pixels_lines)
    %file_name : le chemin+le nom du fichier à écrire
    %pixels_lines : enssemble des pixels appartenant aux droites sous la forme
    %: X11 Y11 X21 Y21 X31 Y31 ... 
    %: X12 Y12 X22 Y22 X32 Y32 ... 
    %: X13 Y13 X23 Y23 X33 Y33 ... 
    %: X14 Y14 X24 Y24 X34 Y34 ... 
   
    [nbligne,nblcolonne] = size(pixels_lines);
    writematrix(pixels_lines(:,:),[file_name] ,'Delimiter','space');
end
function [V_res,I_res,w_res]= clear(V_dec,ind_dec,w)
    %retrait des lignes dont le nombre de vote est < à la moyenne
    m=mean(V_dec); 
    t=[V_dec ind_dec];
    t=[t w];
    t(t(:,1)<m, :)=[];
    V_res=t(:,1);
    I_res= t(:,2);
    w_res = t(:,3);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
end
function [V_res,I_res,w_res]= clear2(V,ind,w,rho,s)%s est le seuil
    %retrait des lignes dont le nombre de vote est < à la moyenne
    m=mean(V); 
    t=[V ind];
    t=[t w];
    t(t(:,1)<m, :)=[];
    V=t(:,1);
    ind= t(:,2);
    w = t(:,3);
    %parcours des indice de rho 3 par 3 et selection des distance égale
    ind;
    rho(ind);
    indice_equiDist=[];
    nb_ligne=size(ind);
    for i=2:nb_ligne-1
        rho_peaks_previous=rho(ind(i-1));
        rho_peaks_actu=rho(ind(i));
        rho_peaks_next=rho(ind(i+1));
        distance_previous=abs(rho_peaks_actu-rho_peaks_previous);
        distance_next=abs(rho_peaks_next-rho_peaks_actu);
        m=max(distance_next,distance_previous);
        seuil=(m/100)*s;
        if(distance_previous>(distance_next-seuil) && distance_previous<(distance_next+seuil))
            indice_equiDist=[indice_equiDist;i distance_previous];
        end
    end
    indice_equiDist;
    nb_ligne_test=size(indice_equiDist);
    nb_ligne_test;
    if(nb_ligne_test>0)
        %min=999999999;%une très grande valeur
        ma=-999999999;%une très pette valeur
        min_ind=-1;
        for i=1:nb_ligne_test
            dist=indice_equiDist(i,2);
            ind_3=indice_equiDist(i,1);
%              if(dist<min)
%                  min=dist;
%                  min_ind=ind_3;
%              end
             if(dist>ma)
                 ma=dist;
                 min_ind=ind_3;
             end
        end
        dist;
        V_res=V(ind_3-1:ind_3+1);
        I_res= ind(ind_3-1:ind_3+1);
        w_res = w(ind_3-1:ind_3+1);
    else
        V_res= -1;
        I_res= -1;
        w_res = -1;
    end
    
end
function [V_res,I_res,w_res]= clear3(V_dec,ind_dec,w)
    %retrait des lignes dont le nombre de vote est < à la moyenne
    t=[V_dec ind_dec];
    t=[t w];
    %t(t(:,1)<m, :)=[];
    [M,I] = max(V_dec)
    V_res=V_dec(I);
    I_res=ind_dec(I);
    w_res = w(I);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
end
function [V,I,w] = clear3max(V,I,w,rho,prominence)
    %suppression des element qui ont un rho trop proche
    rhosort=rho(I);
    %trie des peaks en fonction du nombre de vote
    [vsort isort]=sort(prominence,'descend');
   
    %selection des 3 plus piques aillant le plus de vote
    V=V(isort(1:3));
    I=I(isort(1:3));
    w=w(isort(1:3)); 
end
function [V_res,I_res,w_res]= clear_dec(V_dec,ind_dec,w,rho,s)
    m=mean(V_dec);
    t=[V_dec ind_dec];
    t=[t w];
    %retrait des lignes dont le nombre de vote est < à la moyenne
    t(t(:,1)<m, :)=[];
    V_dec=t(:,1);
    ind_dec= t(:,2);
    w_dec = t(:,3);
    %suppression des peaks trop proche ()
    %Calcul de la distance (rho) entre les piques
    dist=[];
    for i=1:length(ind_dec)-1
       rho_peaks=rho(ind_dec(i));
       rho_peaks_next=rho(ind_dec(i+1));
       distance=rho_peaks_next-rho_peaks ;
       dist=[dist ;distance];
    end
    mdist=0;
    taillemdist=length(dist);
    %on trie les disctance par ordre décroissant
    [vsort isort]=sort(dist,'descend');
    %si le nombre de distance est impaire
    if(mod(taillemdist,2)~=0)
        %On selectionne la medianne
        mdist=median(vsort,'all');
    %si il est paire
    else 
        mid=taillemdist/2;
        mid_next=mid+1;
        mdist=max(vsort(mid),vsort(mid_next));
    end
    seuil_accepted=(mdist/100)*s;
    mdist-seuil_accepted;
    mdist+seuil_accepted;
    res=[];
    for i=1:length(ind_dec)-1
        rho_peaks=rho(ind_dec(i));
        rho_peaks_next=rho(ind_dec(i+1));
        distance=rho_peaks_next-rho_peaks ;
        if(distance>=mdist-seuil_accepted && distance<=mdist+seuil_accepted)
            res=[res;t(i,1) t(i,2) t(i,3)];
            res=[res;t(i+1,1) t(i+1,2) t(i+1,3)];
        end
    end

    res=unique(res,'rows');
    V_res=res(:,1);
    I_res= res(:,2);
    w_res = res(:,3);
end
function [V_res,I_res,w_res]= clear_dec2(V_dec,ind_dec,w,rho,s)
    m=mean(V_dec);
    t=[V_dec ind_dec];
    t=[t w];
    %retrait des lignes dont le nombre de vote est < à la moyenne
    t(t(:,1)<m, :)=[];
    V_dec=t(:,1);
    ind_dec= t(:,2);
    w_dec = t(:,3);
    %Calcul de la distance (rho) entre les piques
    dist=[];
    indiceDist=[]
    for i=1:length(ind_dec)-1
       rho_peaks=rho(ind_dec(i));
       rho_peaks_next=rho(ind_dec(i+1));
       distance=rho_peaks_next-rho_peaks ;
       dist=[dist ;distance];
       indiceDist=[indiceDist;ind_dec(i) ind_dec(i+1)];
    end
    %retrait des lignes dont la distance est inférieur à la médianne
    mdist=median(dist);
    seuil_accepted=(mdist/100)*s;
    res=[];
    for icurrentDist=1:length(ind_dec)-1
        rho_peaks=rho(ind_dec(icurrentDist));
        rho_peaks_next=rho(ind_dec(icurrentDist+1));
        distance=rho_peaks_next-rho_peaks;
        if(distance>mdist-seuil_accepted && distance<mdist+seuil_accepted)
             res=[res;t(icurrentDist,1) t(icurrentDist,2) t(icurrentDist,3)];
             res=[res;t(icurrentDist+1,1) t(icurrentDist+1,2) t(icurrentDist+1,3)];
        end
    end
    res=unique(res,'rows');
    V_res=res(:,1);
    I_res= res(:,2);
    w_res = res(:,3);
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
    imshow(contour);hold on;
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
function [pixel_all_line]=get_pixel_line_by_normal(contour,rho,theta,P,w)
    [height, width] = size(contour);  
    pixel_all_line=[];
    [nbligne,nblcolonne] = size(P);
    %trie du P en fonction de la distance à l'origine
    P=sortrows(P,1);
    for j = 1:nbligne
        numdroite=j;
        %largeur/theta/rho de la droite courante
        largeur_d=w(numdroite)*5;%*5 pour rho_resolution
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
function [hough_vector_max, indice_dec]=get_hough_vector_max(indice,H,angle_accepted,rho,seuil_clear)
    %fonction qui permet de retourner le vector de hough correspondant au
    %normale des longue droite
    %Creation de la sous-matrice de H (défini par l'indice et l'angle
    %toléré)
    %H est défini de 0à 180 alors il faut faire attention a ne pas être à
    %l'exterieur 
    debut=indice-angle_accepted;
    fin=indice+angle_accepted;
    if(debut<=0)
        debut= 180-(abs(debut));
        gauche1=H(:,debut:1:180);
        gauche2=H(:,1:1:indice);
        gauche=[gauche1 gauche2];
        %soit début est <0 soit fin est >180 mais pas les deux.
        droite=H(:,indice:1:fin);
        hough_matrice_theta=[gauche droite];
    else
        if(fin >180)
            fin2=fin-180;
            indice;
            droite1=H(:,indice:1:180);
            fin2;
            droite2=H(:,1:1:fin2);
            droite=[droite1 droite2];
            %soit début est <0 soit fin est >180 mais pas les deux.
            gauche=H(:,debut:1:indice);
            hough_matrice_theta=[gauche droite];
        else 
            %cas ou l'angle toleré ne dépase pas les borne de H
            hough_matrice_theta=H(:,debut:1:fin);
        end
    end
    %TODO : probleme quand fin depasse 180
    [~, nbcolonne]=size(hough_matrice_theta);
    indice_max=-1;
    nb_vote_max=-1;
    nbcolonne;
    for i = 1 :nbcolonne
        vector_candidate=hough_matrice_theta(:,i);
        [V_dec,I_dec,w_dec]=findpeaks(vector_candidate);
        [V_dec,I_dec,w_dec]=clear_dec(V_dec,I_dec,w_dec,rho,seuil_clear);
        nbvote_candidate=sum(V_dec);
        if(nbvote_candidate>=nb_vote_max)
            indice_max=i;
            nb_vote_max=nbvote_candidate;
        end
    end
    hough_vector_max=hough_matrice_theta(:,indice_max);
    %%TODO : probleme si debut+indice_max > 180
    indice_dec=mod(debut+indice_max,180);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%AFFICHAGE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function affichage_densite(fig_densite,img_densite,img_name)
   figure(fig_densite);
   title(img_name);
   imshow(img_densite,[0,255]);
end
function affichage_contourcleared(fig_contourClear,contour_clear)
   figure(fig_contourClear);
   imshow(contour_clear);
end
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
    [nbligne_dec,nbcolonne_dec]=size(pixel_all_line_dec);
    for j = 1:2:nbcolonne_dec
        pixel_line=pixel_all_line_dec(:,j); 
        j=j+1;
        pixel_line=[pixel_line ,pixel_all_line_dec(:,j)];
        for i = 1:nbligne_dec       
             if(pixel_line(i,2)>-1 && pixel_line(i,1)>-1)
                droite_bleu(sub2ind(size(droite_bleu),pixel_line(i,2),pixel_line(i,1))) = 255;
            end
        end
    end
    
    final_image(:,:,1)=droite_rouge;
    %final_image(:,:,2)=contour;
    final_image(:,:,3)=droite_bleu;
    %X=[pixel_all_line(1,1) pixel_all_line(nbligne,1)]
    %Y=[pixel_all_line(1,2) pixel_all_line(nbligne,2)]
    imshow(final_image);hold on;
    %plot(X,Y,'LineWidth',0.5,'Color','white');
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
        if (sind(theta_out(i))==0)
            plot([rho_out(i),rho_out(i)],[1,height],'LineWidth',1.5,'Color','red');
        end
        x1=1;
        y1 = ((rho_out(i)) - x1* cosd(theta_out(i)) )/ sind(theta_out(i));
        x2=width;
        y2 = ((rho_out(i)) - x2* cosd(theta_out(i)) )/ sind(theta_out(i));
        plot([x1 x2],[y1 y2],'LineWidth',1.5,'Color','red');
    end
    for i=1:length(rho_dec_out(1,:))
        if (sind(theta_dec_out(i))==0)
            plot([rho_dec_out(i),rho_dec_out(i)],[1,height],'LineWidth',1.5,'Color','blue');
        end
          x1=1;
          y1 = ((rho_dec_out(i)) - x1* cosd(theta_dec_out(i)) )/ sind(theta_dec_out(i));
          x2=width;
          y2 = ((rho_dec_out(i)) - x2* cosd(theta_dec_out(i)) )/ sind(theta_dec_out(i));
        plot([x1 x2],[y1 y2] ,'LineWidth',1.5,'Color','blue');
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
    %plot(Pdec(:,2),Pdec(:,1),'o','color','red');
    hold off;
end
function []= clearfig(fig_img,fig_vecteur_long,fig_vecteur_long_90,fig_hough,fig_pixel,fig_densite,fig_contourClear)
    clf('reset')
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
    figure(fig_densite);
    clf('reset')
     figure(fig_contourClear);
    clf('reset')
end
 
