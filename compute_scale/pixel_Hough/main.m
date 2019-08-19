%%
%fonction for call makeOnePixelHough to pictures set
%-------entrée--------
%pathToRepoImg_RGB :path to picture rgb
%pathToRepoImg_SGM :path to segmented mire
%Warning : rgb picture and segmented mire need to have the same filename
%%
function main(pathToRepoImg_RGB , pathToRepoImg_SGM, pathToWrite)
    %path to the repository you want release lineHoughPixel
    path_write=pathToWrite;
    %path to rgb picture
    path_repo_img=pathToRepoImg_RGB;
    %path to sgm picture
    path_repo_sgm=pathToRepoImg_SGM;
    %extension of picture treated
    extension='*.png';
    extensionMaj='*.PNG';
    %make a list of all picture in the img repository, default picture
    %extension is '*.png'
    filelist_img=[dir(strcat(path_repo_img,extension));dir(strcat(path_repo_img,extensionMaj))];
    %number of file in the
    nfiles = length(filelist_img);
    %for each file in repo
    for i = 1 :nfiles
        %give the file name
        img_name=filelist_img(i).name
        %if(img_name=="huawei_E066H_1.png")
            %concat file name and repository
            path_name_img=strcat(strcat(path_repo_img, '/'), img_name);
            path_name_sgm=strcat(strcat(path_repo_sgm, '/'), img_name);
            %read rgb picture
            img=imread(path_name_img);
            %read sgm picture
            img_sgm=imread(path_name_sgm);
            %give the pixel associated to hough line
            [hough_line_pixels,hough_line_pixels_dec]=makeOnePixelHough(img,img_sgm);
            %check if they are line to detect
            if(isempty(hough_line_pixels)==0 && isempty(hough_line_pixels_dec)==0)
                write_file(strcat(path_write,strrep(img_name, '.png', '.dat')),hough_line_pixels);
                write_file(strcat(path_write,strrep(img_name, '.png', '_dec.dat')),hough_line_pixels_dec);  
            end
        %end
    end
end
%%
%fonction to write date at path specified
%file_name: pathtowrite data
%pixels_lines: data
%%
function write_file(file_name,pixels_lines)
    %data pattern : 
    %: X11 Y11 X21 Y21 X31 Y31 ... 
    %: X12 Y12 X22 Y22 X32 Y32 ... 
    %: X13 Y13 X23 Y23 X33 Y33 ... 
    %: X14 Y14 X24 Y24 X34 Y34 ... 
   
    [nbligne,nblcolonne] = size(pixels_lines);
    writematrix(pixels_lines(:,:),[file_name] ,'Delimiter','space');
end