function [] = affichage_harris(I_RGB,R,G,B,I_HSV,H,S,V,nbCorners,filter_size)
    subplot(2,4,1);
    imshow(I_RGB); hold on;
    %corners = detectHarrisFeatures(R,'FilterSize', 81);
    %plot(corners.selectStrongest(100));
    title('RGB');
    subplot(2,4,2);
    imshow(R);hold on;
    corners = detectHarrisFeatures(R,'FilterSize', filter_size);
    plot(corners.selectStrongest(nbCorners));
    title('R');
    subplot(2,4,3);
    imshow(G);hold on;
    corners = detectHarrisFeatures(G,'FilterSize', filter_size);
    plot(corners.selectStrongest(nbCorners));
    title('G');
    subplot(2,4,4);
    imshow(B);hold on;
    corners = detectHarrisFeatures(B,'FilterSize', filter_size);
    plot(corners.selectStrongest(nbCorners));
    title('B');
    subplot(2,4,5);
    imshow(I_HSV);hold on;
    %corners = detectHarrisFeatures(I_HSV,'FilterSize', 81);
    %plot(corners.selectStrongest(100));
    title('HSV')
    subplot(2,4,6);
    imshow(H);hold on;
    corners = detectHarrisFeatures(H,'FilterSize', filter_size);
    plot(corners.selectStrongest(nbCorners));
    title('H')
    subplot(2,4,7);
    imshow(S);hold on;
    corners = detectHarrisFeatures(S,'FilterSize', filter_size);
    plot(corners.selectStrongest(nbCorners));
    title('S');
    subplot(2,4,8);
    imshow(V);hold on;
    corners = detectHarrisFeatures(V,'FilterSize', filter_size);
    plot(corners.selectStrongest(nbCorners));
    title('V');
end