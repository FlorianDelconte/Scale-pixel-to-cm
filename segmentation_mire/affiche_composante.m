function [] = affiche_composante(I_RGB,R,G,B,I_HSV,H,S,V)
    subplot(2,4,1);
    imshow(I_RGB); hold on;
    title('RGB')
    subplot(2,4,2);
    imshow(R);
    title('R')
    subplot(2,4,3);
    imshow(G);
    title('G')
    subplot(2,4,4);
    imshow(B);
    title('B')
    subplot(2,4,5);
    imshow(I_HSV);
    title('HSV')
    subplot(2,4,6);
    imshow(H);
    title('H')
    subplot(2,4,7);
    imshow(S);
    title('S')
    subplot(2,4,8);
    imshow(V);
    title('V')
end