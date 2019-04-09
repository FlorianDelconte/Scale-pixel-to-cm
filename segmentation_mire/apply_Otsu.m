function [I_RGB,R,G,B,I_HSV,H,S,V] = apply_Otsu(I_RGB,R,G,B,I_HSV,H,S,V)

    level=graythresh(R);
    R=im2bw(R,level);
    
    level=graythresh(G);
    G=im2bw(G,level);
    
    level=graythresh(B);
    B=im2bw(B,level);

    level=graythresh(H);
    H=im2bw(H,level);
    
    level=graythresh(S);
    S=im2bw(S,level);
    
    level=graythresh(V);
    V=im2bw(V,level);
end