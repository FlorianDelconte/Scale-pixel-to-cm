function [] = affiche_composante(I_RGB,R,G,B,I_HSV,H,S,V)
    
    subplot(2,4,1);
    imshow(I_RGB); hold on;
    %corners = detectHarrisFeatures(R,'FilterSize', 81);
    %plot(corners.selectStrongest(100));
    title('RGB')
    subplot(2,4,2);
    imshow(R);hold on;
    corners = detectMinEigenFeatures(R,'FilterSize', 37);
    plot(corners.selectStrongest(16));
    title('R')
    subplot(2,4,3);
    imshow(G);hold on;
    corners = detectMinEigenFeatures(G,'FilterSize', 37);
    plot(corners.selectStrongest(16));
    title('G')
    subplot(2,4,4);
    imshow(B);hold on;
    corners = detectMinEigenFeatures(B,'FilterSize', 37);
    plot(corners.selectStrongest(16));
    title('B')
    subplot(2,4,5);
    imshow(I_HSV);hold on;
    %corners = detectHarrisFeatures(I_HSV,'FilterSize', 81);
    %plot(corners.selectStrongest(100));
    title('HSV')
    subplot(2,4,6);
    imshow(H);hold on;
    corners = detectMinEigenFeatures(H,'FilterSize', 37);
    plot(corners.selectStrongest(16));
    title('H')
    subplot(2,4,7);
    imshow(S);hold on;
    corners = detectMinEigenFeatures(S,'FilterSize', 37);
    plot(corners.selectStrongest(16));
    title('S')
    subplot(2,4,8);
    imshow(V);hold on;
    corners = detectMinEigenFeatures(V,'FilterSize', 37);
    plot(corners.selectStrongest(16));
    title('V')
end