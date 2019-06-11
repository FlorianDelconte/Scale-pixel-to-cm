function [img_densite,contour_clear]=densite(img,windowsSize,seuil)
   
    s=size(img);
    %creation de l'image des contour canny nettoyé
    contour_clear=zeros(s(1),s(2));
    %image de la densité de pixel, initialisation à zero
    img_densite=zeros(s(1),s(2));
    %creation de la lutte de couleur en fonction de la taille de la fenetre
    [lutte]=create_lute(windowsSize);
    %calcul de l'intensité limite au dela de laquelle on met à zero le
    %pixel
    intens_limite=lutte(int16(((windowsSize*windowsSize)/100)*seuil))
    %calcul de la couleur assocé a la densité pour chaque pixel différent
    %de zero dans une fettre donné
    for i=(windowsSize/2)+1:s(1)-windowsSize      
        for j=(windowsSize/2)+1:s(2)-windowsSize         
            if(img(i,j)~=0)
                c=compute_densite_color(i,j,img,windowsSize,lutte);
                img_densite(i,j)=c;
                if(c<=intens_limite)
                    contour_clear(i,j)=255;
                end
            end
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