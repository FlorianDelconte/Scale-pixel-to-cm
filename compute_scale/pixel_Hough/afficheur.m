%%
%Ce script permet de générer 5 figure : 
%---fig_vecteur : affiche le vecteur qui contient le pique de vote max dans
%l'espace de Hough
%---fig_vecteur_dec : affiche le vecteur décallé de 90° par rapport au pique de vote max dans l'espace de
%Hough
%---hough space : l'espace de hough avec les piques selectionnées (en rouge
%les droites horizontales, en bleu les droite verticales
%---img et droite de hough :  affiche les droite de hough sur l'image généré
%par le pré-traitement
%---densite : une carte de densité de pixels
%---pixels de hough : les pixels proche des droites de hough
%%
function afficheur(contour,pixel_all_line,pixel_all_line_dec,horizontal_lines,vertical_lines,H,theta,rho,I,I_dec,theta_max,theta_dec,hough_vector_max_theta,V,w,hough_vector_max_theta_90,V_dec,w_dec,img_densite)
%%%les figures
    fig_pixel =figure('Name','pixels de hough');
    fig_densite=figure('Name','densite');
    fig_img=figure('Name','img et droite de Hough');
    fig_hough=figure('Name','hough space');
    fig_vecteur=figure('Name','rho en fonction du nombre de vote pour le vecteur max');
    fig_vecteur_dec=figure('Name','rho en fonction du nombre de vote pour le vecteur max décalé de 90°');
%%%Les appels
    affichage_pixel_normal(fig_pixel,contour,pixel_all_line,pixel_all_line_dec);
    affichage_img(fig_img,contour,horizontal_lines,vertical_lines);
    affichage_hough(fig_hough,H,theta,rho,horizontal_lines,vertical_lines);
    affichage_distrib(fig_vecteur,hough_vector_max_theta,[V,I,w],fig_vecteur_dec,hough_vector_max_theta_90,[V_dec,I_dec,w_dec],rho);
    affichage_densite(fig_densite,img_densite);
end
%%
%permet d'afficher l'image actuellement traité ainsi que les droite de
%Hough 
%%
function affichage_img(fig_img,img,horizontal_lines,vertical_lines)
    figure(fig_img);
    imshow(img);hold on;
    truesize(fig_img);
    [height, width] = size(img);
    %Plot lines using rho and theta
    for i=1:length(horizontal_lines(:,1))
        rho_d=horizontal_lines(i,1);
        theta_d=horizontal_lines(i,2);
        if (sind(theta_d)==0)
            plot([rho_d,rho_d],[1,height],'LineWidth',1.5,'Color','red');
        end
        x1=1;
        y1 = ((rho_d) - x1* cosd(theta_d) )/ sind(theta_d);
        x2=width;
        y2 = ((rho_d) - x2* cosd(theta_d) )/ sind(theta_d);
        plot([x1 x2],[y1 y2],'LineWidth',1.5,'Color','red');
    end
    for i=1:length(vertical_lines(:,1))
        rho_n=vertical_lines(i,1);
        theta_n=vertical_lines(i,2);
        if (sind(theta_n)==0)
            plot([rho_n,rho_n],[1,height],'LineWidth',1.5,'Color','blue');
        end
          x1=1;
          y1 = ((rho_n) - x1* cosd(theta_n) )/ sind(theta_n);
          x2=width;
          y2 = ((rho_n) - x2* cosd(theta_n) )/ sind(theta_n);
        plot([x1 x2],[y1 y2] ,'LineWidth',1.5,'Color','blue');
    end
    hold off;
end
%%
%permet d'afficher une carte de densité liée au pxiels de l'image
%%
function affichage_densite(fig_densite,img_densite)
   figure(fig_densite);
   imshow(img_densite,[0,255]);
end
%%
%permet d'afficher les pixels associers aux droites de Hough
%%
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
   % final_image(final_image(:,:,1)==0 & final_image(:,:,2)==0 & final_image(:,:,3)==0)=100;
    imshow(final_image);hold on;
    
    truesize(fig_pixel );
    hold off;
end
%%
%Permet d'afficher l'espace de hough ainsi que les peaks selectionner 
%rouge : les droites horizontales, bleu : les droites verticales
%%
function affichage_hough(fig_hough,hough,theta,rho,horizontal_lines,vertical_lines)
    figure(fig_hough);hold on;
    imshow(imadjust(rescale(hough)),'XData',theta,'YData',rho,'InitialMagnification','fit');
    title('Hough transform');
    xlabel('\theta'), ylabel('\rho');
    axis on, axis normal;
    t=length(horizontal_lines);
    t_dec=length(vertical_lines);
    if (t ~= 0 || t_dec ~= 0)
        plot(horizontal_lines(:,2),horizontal_lines(:,1),'s','color','red'); 
        plot(vertical_lines(:,2),vertical_lines(:,1),'s','color','blue');  
    end
    hold off;
end
%%
%permet d'afficher le rho en fonction du nombre de vote des vecteurs de
%l'espace de Houg selectionné
%%
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
    hold off;
end