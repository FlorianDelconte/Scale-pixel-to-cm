%%
%script qui permet de créer une carte de densité de pixels
%entrée : 
%   img : l'image à traiter 
%   windowsSize : la taille de la fenêtre dans laquelle est calculé la densité
%   seuil : le seuil à partir duquel le pixel est considéré comme dense
%sortie :
%   densite_out : la carte de densité de l'image (en niveau de gris)
%   img_out : l'image d'entrée que laquelle on a retiré les pixels dense
%   ratio : la proportion de pixel dense (en ne comptant pas les pixel ==0 )
%%
function [densite_out,img_out,ratio]=densite(img,windowsSize,seuil)
    s=size(img);
    %creation de la lutte de couleur en fonction de la taille de la fenetre
    [lutte]=create_lute(windowsSize);
    %calcul de l'intensité limite au dela de laquelle on met à zero le
    %pixel
    intens_limite=lutte(int16(((windowsSize*windowsSize)/100)*seuil));
    nb_pixel_fond=0;
    %calcul la proportion de pixel dont la densité associé est supérieur
    %au seuil 
    [ratio,img_out,densite_out]=countPixelSup(img,windowsSize,intens_limite,lutte); 
end

%%
%compte le nombre de pixels dont la densité (dans une fenetre donnée)
%dépasse le seuil
function [ratio,contour_clear,img_densite]=countPixelSup(img,windowsSize,intens_limite,lutte)
    s=size(img);
    %creation de l'image des contour canny nettoyé
    contour_clear=zeros(s(1),s(2));
    %image de la densité de pixel, initialisation à zero
    img_densite=zeros(s(1),s(2));
    ratio=0;
     for i=(windowsSize/2)+1:s(1)-windowsSize/2
        for j=(windowsSize/2)+1:s(2)-windowsSize/2    
            if(img(i,j)~=0)
                c=compute_densite_color(i,j,img,windowsSize,lutte);
                img_densite(i,j)=c;
                if(c>intens_limite)
                   ratio=ratio+1;
                else
                    contour_clear(i,j)=255;
                end
            end
        end
     end
     
     ratio=ratio/nnz(img);
end

%%
%permet de mettre toutes les valeurs a zero dans une fenetre autour du
%pixel de coordonée (i,j)
function img=appliqueZero(img,ws, i,j)
    for x=(-ws/2):ws/2     
        for y=(-ws/2):ws/2 
            coordx=i+x;
            coordy=j+y;
            img(coordx,coordy)=0;
        end
    end
end
%%
%permet de mettre toutes les valeurs a un dans une fenetre autour du
%pixel de coordonée (i,j)
function img=appliqueUn(img,ws, i,j)
    for x=(-ws/2):ws/2     
        for y=(-ws/2):ws/2 
            coordx=i+x;
            coordy=j+y;
            img(coordx,coordy)=255;
        end
    end
end
%%
%permet de mettre toutes les valeurs a une couleur en paramètre dans une fenetre autour du
%pixel de coordonée (i,j)
function img=appliqueColor(img,ws, i,j,c)
    for x=(-ws/2):ws/2     
        for y=(-ws/2):ws/2 
            coordx=i+x;
            coordy=j+y;
            img(coordx,coordy)=c;
        end
    end
end

%%
%calcule la densité de pixel à une position donnée et une fenettre donnée et renvoi la couleur
%associé à cette position [0,255]
function [color]=compute_densite_color(i,j,img,ws,lutte)
    nb_pixel=1;
     for x=(-ws/2):ws/2     
        for y=(-ws/2):ws/2   
            coordx=i+x;
            coordy=j+y;
            if(img(coordx,coordy)~=0)
                nb_pixel=nb_pixel+1;
            end
        end
     end
     nb_pixel;
     color=lutte(nb_pixel);
end

%%
%calcule une lutte de couleur pour une taille de fenetre donnée
function [lutte]=create_lute(ws)
    %la fenetre est toujours de taille carré. donc la lutte est de taille
    %=(taille fenettre au carré)
    tailleLutte=ws*ws;
    %Trouver le changement d'intervalle revient à trouver une fonction
    %affine : donc ondéfini deux point
    x1=1;
    x2=tailleLutte;
    y1=0;
    y2=255;
    a=(y2-y1)/(x2-x1);
    b=-a;
    for x=1:tailleLutte
        lutte(x)=int16(a*x+b);
    end
end