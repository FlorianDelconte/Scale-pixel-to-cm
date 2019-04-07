close all
path='../DATA/truth_ground/img/512_512/';
name='PointsDetected(a).jpg'
name_test='huawei_E010H_label.jpg'
pth_img=strcat(path, name_test)

[I_RGB,R,G,B,I_HSV,H,S,V]=create_composante(path,name_test);
I1 = imread(B);
figure,imshow(I1); hold on;

[imagePoints,boardSize]  = detectCheckerboardPoints(I1)
plot(imagePoints(:, 1, 1, 1),imagePoints(:, 2, 1, 1), 'ro'); 