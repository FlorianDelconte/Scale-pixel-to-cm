function [I_RGB,R,G,B,I_HSV,H,S,V] = detect_contour(I_RGB,R,G,B,I_HSV,H,S,V,methode)
    R = edge(R,methode);
    G = edge(G,methode);
    B = edge(B,methode);
    H = edge(H,methode);
    S = edge(S,methode);
    V = edge(V,methode);
end