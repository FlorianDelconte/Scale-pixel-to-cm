function [r, c] = hough_bin_pixels(bw, theta, rho, peak,n)
    [y, x] = find(bw);
    x = x - 1;
    y = y - 1;
    
    %calcul du theta du peaks en degree 
    theta_degree = theta(peak(2)) * pi / 180;

    %calcul du rho associé à chaque pixel différent de 0
    rho_xy = x*cos(theta_degree) + y*sin(theta_degree);
    nrho = length(rho);
    
    %normalisation des rho_xy
    slope = (nrho - 1)/(rho(end) - rho(1));  
    rho_bin_index = round(slope*(rho_xy - rho(1)) + 1);
    
    idx = find(rho_bin_index == peak(1));
    r = y(idx) + 1; 
    c = x(idx) + 1;
    
    for i=1:n
        
        ind_t = find(rho_bin_index == peak(1)+i);
        r_t = y(ind_t) + 1; 
        c_t = x(ind_t) + 1;
        
        idx=[idx;ind_t];
        r=[r;r_t];
        c=[c;c_t];
        
        ind_t = find(rho_bin_index == peak(1)-i);
        r_t = y(ind_t) + 1; 
        c_t = x(ind_t) + 1;        
        idx=[idx;ind_t];
        r=[r;r_t];
        c=[c;c_t];
        
    end
    
    r_range = max(r) - min(r);
    c_range = max(c) - min(c);
    if r_range > c_range
        sorting_order = [1 2];
    else
        sorting_order = [2 1];
    end
    [rc_new] = sortrows([r c], sorting_order);
    r = rc_new(:,1);
    c = rc_new(:,2);
    
%     size(bw);
%     bw2 = false(size(bw));
%     bw2(sub2ind(size(bw), r, c)) = true;
    
    
    