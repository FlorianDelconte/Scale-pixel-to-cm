
%%
%script qui permet de clear un vecteur de plusieurs manières.
%(1) : calcul les maximas locaux
%(2) : filtre les maximas locaux de plusieurs manièrs
%   la fonction 'clear3max' pour les droites horizontales
%   la fonction 'clear_dec' pour les droites verticales
%%
function [V_clear,I_clear,w_clear]=clearHoughVecteur(rho,hough_vector,number)
    seuil_clear=30;
    %si number =0 on clear le vecteur des droite horizontales
    if(number==0)
        %permet de récuperer les maximas locaux
        %V : valeur des maximas locaux,
        %I : indice des maximas locaux,
        %w : largeur associé aux maximas locaux
        %prominence : hauteur d'un pique en rapport aux piques voisin
        %--> voir https://de.mathworks.com/help/signal/ref/findpeaks.html
        [V,I,w,prominence]=findpeaks(hough_vector);
        [V_clear,I_clear,w_clear]=clear3max(V,I,w,prominence);
    else
        %si number=1 on traite le vecteur des droites verticales
        if(number==1)
            %permet de récuperer les maximum locaux 
             [V_dec,I_dec,w_dec]=findpeaks(hough_vector);
             [V_clear,I_clear,w_clear]=clear_dec(V_dec,I_dec,w_dec,rho,seuil_clear);
        end
    end
    
end
%%
%permet de des piques dont le nombre de vote est inférieur à la moyenne
%%
function [V_res,I_res,w_res]= clearMoy(V_dec,ind_dec,w)
    %retrait des lignes dont le nombre de vote est < à la moyenne
    m=mean(V_dec); 
    t=[V_dec ind_dec];
    t=[t w];
    t(t(:,1)<m, :)=[];
    
    if(isempty(t)==0)
        V_res=t(:,1);
        I_res= t(:,2);
        w_res = t(:,3);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
end
%%
%permet de retier les piques dont le nombre de vote est inférieur à la
%moyenne et selectionne  parmis le reste 3 piques à equi_distance (retourne
%-1 si il n'y a pas de piques à égales distance.
%si plusieurs groupe de 3 sont selectionner, retoune le groupe de trois
%avec la plus grande distance les séparant
%%
function [V_res,I_res,w_res]= clearMoySelectThree(V,ind,w,rho,s)%s est le seuil
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
       
        ma=-999999999;%une très pette valeur
        min_ind=-1;
        for i=1:nb_ligne_test
            dist=indice_equiDist(i,2);
            ind_3=indice_equiDist(i,1);         
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
%%
%permet de retirer les piques dont le nombre de vote est inférieur à la
%moyenne et selectionne le pique ayant le plus de vote
%%
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
%%
%Selectionne les 3 piques ayant la prominence la plus elevé 
%%
function [Vout,Iout,wout] = clear3max(V,I,w,prominence)
    Vout=[];
    Iout=[];
    wout=[];
    %trie des peaks en fonction du nombre de vote
    [vsort isort]=sort(prominence,'descend');
    [rows,cols] = size(isort);
    %selection des 3 plus piques aillant le plus de vote
    if(length(isort)>=3)
        Vout=V(isort(1:3));
        Iout=I(isort(1:3));
        wout=w(isort(1:3)); 
    end
end
%%
%retirer les piques ayant un nombre de vote inférieur à la moyenne
%calcul la médianne des distance entre les piques
%retire les piques ayant une distance trop éloigner de la médianne (à un seuil près défini par s)
%%
function [V_res,I_res,w_res]= clear_dec(V_dec,ind_dec,w,rho,s)
    V_res=[];
    I_res=[];
    w_res=[];
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
       distance_next=rho_peaks_next-rho_peaks ;
       dist=[dist ;distance_next];
    end
    mdist=0;
    taillemdist=length(dist);
    %retrait des distance < mean(distance)/2 : permet de virer les doublons
    %trop proche
    dist(dist(:,1)<mean(dist(:,1))/2, :)=[];
    mean(dist(:,1));
    %on trie les disctance par ordre décroissant
    [vsort isort]=sort(dist,'descend');
    %si le nombre de distance est impaire
    %if(mod(taillemdist,2)~=0)
        %On selectionne la medianne
        %mdist=median(vsort,'all');
    mdist=median(vsort);
    %pause;
    %si il est paire
    %else 
        
     %   mid=taillemdist/2;
     %   mid_next=mid+1
        %mdist=max(vsort(mid),vsort(mid_next));
        %mdist=max(dist(:,mid),vsort(mid_next));
    %end
    %mdist
    seuil_accepted=(mdist/100)*s;
    mdist-seuil_accepted;
    mdist+seuil_accepted;
    res=[];
    for i=2:length(ind_dec)-1
        rho_peaks_previous=rho(ind_dec(i-1));
        rho_peaks=rho(ind_dec(i));
        rho_peaks_next=rho(ind_dec(i+1));
        distance_next=rho_peaks_next-rho_peaks ;
        rho_peaks_previous=rho_peaks-rho_peaks_previous ;
        if((distance_next>=mdist-seuil_accepted && distance_next<=mdist+seuil_accepted) && (rho_peaks_previous>=mdist-seuil_accepted && rho_peaks_previous<=mdist+seuil_accepted))
            res=[res;t(i-1,1) t(i-1,2) t(i-1,3)];
            res=[res;t(i,1) t(i,2) t(i,3)];
            res=[res;t(i+1,1) t(i+1,2) t(i+1,3)];
        end
    end

    res=unique(res,'rows');
    if(isempty(res)==0)
        V_res=res(:,1);
        I_res= res(:,2);
        w_res = res(:,3);
    end
    %V_res=res(:,1);
    %I_res= res(:,2);
    %w_res = res(:,3);
end

