function [I_RGB,R,G,B,I_HSV,H,S,V] = treshold(I_RGB,R,G,B,I_HSV,H,S,V,seuil)


    R=im2bw(R,seuil);

    G=im2bw(G,seuil);

    B=im2bw(B,seuil);


    H=im2bw(H,seuil);

    S=im2bw(S,seuil);

    V=im2bw(V,seuil);
end