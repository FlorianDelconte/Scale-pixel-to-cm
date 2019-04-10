function [I_RGB,R,G,B,I_HSV,H1,S,V] = detect_contour(I_RGB,R,G,B,I_HSV,H1,S,V,methode)
    R = edge(R,methode);
    [H,T,R]=hough(R,'Theta',44:0.5:46);
    P=houghpeaks(H,2);
    lines=houghlines(R,T,R,P,'FillGap',5,'MinLength',7)
    figure, imshow(R), hold on
max_len = 0;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

   % Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end
    
    G = edge(G,methode);
      [H,T,R]=hough(G,'Theta',44:0.5:46);
    B = edge(B,methode);
      [H,T,R]=hough(B,'Theta',44:0.5:46);
    H1 = edge(H1,methode);
      [H,T,R]=hough(H,'Theta',44:0.5:46);
    S = edge(S,methode);
      [H,T,R]=hough(S,'Theta',44:0.5:46);
    V = edge(V,methode);
      [H,T,R]=hough(V,'Theta',44:0.5:46);
end