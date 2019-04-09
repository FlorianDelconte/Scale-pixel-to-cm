close all
path='../DATA/truth_ground/img/512_512/';
name='PointsDetected(a).jpg'
name_test='huawei_E010H_label.jpg'
pth_img=strcat(path, name_test)

[I_RGB,R,G,B,I_HSV,H,S,V]=create_composante(path,name_test);
%I1 = imread(B);
figure,imshow(S); hold on;
corners = detectHarrisFeatures(S,'FilterSize', 81);
plot(corners.selectStrongest(30));
%[imagePoints,boardSize]  = detectCheckerboardPoints(B)
%plot(imagePoints(:, 1, 1, 1),imagePoints(:, 2, 1, 1), 'ro'); 