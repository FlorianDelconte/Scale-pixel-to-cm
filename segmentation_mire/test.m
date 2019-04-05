close all
path='../DATA/truth_ground/img/512_512/';
name='huawei_E091B_2.jpg'
pth_img=strcat(path, name)
I1=imread(pth_img);
figure,imshow(pth_img); hold on;
[imagePoints, boardSize] = detectCheckerboardPoints(I1)



plot(imagePoints(:,1), imagePoints(:,2), 'ro');