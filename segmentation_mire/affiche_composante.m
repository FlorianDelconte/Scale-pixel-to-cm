close all
path='../DATA/truth_ground/img/512_512/';
name1='fva_huawei_E009H_1.jpg'
name2='huawei_E010H_label.jpg'
name3='huawei_E001B_label.jpg'
name4='huawei_E008B_3.jpg'
name5='huawei_E066H_1.jpg'
name6='huawei_E091B_2.jpg'
%RGB image
I_RGB=imread(strcat(path,name6));
fig=figure('Name','Segmentation de mire');
% Composante rouge
R = I_RGB(:,:,1);
% Composante verte
G = I_RGB(:,:,2);
% Composante bleue
B = I_RGB(:,:,3);

%HSV image
I_HSV=rgb2hsv(I_RGB);
% Composante H
H = I_HSV(:,:,1);
% Composante S
S = I_HSV(:,:,2);
% Composante V
V = I_HSV(:,:,3);

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
truesize(fig);

%corners = detectHarrisFeatures(I);
%plot(corners.selectStrongest(300));