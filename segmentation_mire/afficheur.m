close all
path='../DATA/truth_ground/img/512_512/';

%name1='fva_huawei_E009H_1.jpg'
%name2='huawei_E010H_label.jpg'
%name3='huawei_E001B_label.jpg'
%name4='huawei_E008B_3.jpg'
%name5='huawei_E066H_1.jpg'.{jpg,png}
%name6='huawei_E091B_2.jpg'
edge_detector='Canny'%'Sobel''Prewitt''Roberts''log''Canny''approxcanny'
filelist=[dir(strcat(path,'*.jpg'));dir(strcat(path,'*.JPG'))]
%filelist = dir([path,'*.{JPG,jpg}']);
nfiles = length(filelist)
fig=figure('Name','Segmentation de mire');
for i = 1:nfiles
    filelist(i).name
    [I_RGB,R,G,B,I_HSV,H,S,V] = create_composante(filelist(i).folder,filelist(i).name);
    affiche_composante(I_RGB,R,G,B,I_HSV,H,S,V)
    R = edge(R,edge_detector);
    G = edge(G,edge_detector);
    B = edge(B,edge_detector);
    H = edge(H,edge_detector);
    S = edge(S,edge_detector);
    V = edge(V,edge_detector);
    
    %affiche_composante(I_RGB,R,G,B,I_HSV,H,S,V)
    %corners = detectHarrisFeatures(S,'FilterSize', 81);

    %plot(s,corners.selectStrongest(100));
    
     %BW = imbinarize(S,0.3);
     %imshow(BW); hold on;
%     corners = detectHarrisFeatures(BW,'FilterSize', 111);
%     plot(corners.selectStrongest(30));
    truesize(fig);
    pause;
end
close all
%corners = detectHarrisFeatures(I);
%plot(corners.selectStrongest(300));