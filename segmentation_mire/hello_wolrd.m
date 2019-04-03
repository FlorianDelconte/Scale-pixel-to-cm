name='D01-L1-6.JPG';
I=imread(name);
fig=figure('Name','Segmentation de mire');
subplot(1,2,1);

corners = detectHarrisFeatures(I);

imshow(I); hold on;
plot(corners.selectStrongest(300));
truesize(fig);