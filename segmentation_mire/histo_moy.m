clear all

path_sgmMire='../DATA/PNG/sgm_mire/';
%obtient la liste des images 
filelist_sgm=[dir(strcat(path_sgmMire,'*.png'));dir(strcat(path_sgmMire,'*.PNG'))];
nfiles = length(filelist_sgm);

fig=figure('Name','Segmentation de mire');
sum=zeros(256,1);
for i = 1:nfiles
    path_name=strcat(strcat(path_sgmMire, '/'), filelist_sgm(i).name)
    SGM=imread(path_name);
    SGM_nonzero = nonzeros(SGM);
    [counts,x]=imhist(SGM_nonzero);
    %bar(counts);
    sum=sum+counts;
    %pause;  
end
sum=sum / 60;
bar(sum);
%h=histogram(sum,256)
%h.Orientation = 'horizontal';