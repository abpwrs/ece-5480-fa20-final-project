function [coin_mask] = generateCoinMask(I)
    I_gray = rescale(double(rgb2gray(I)),0,1);

    figure( 101); imshow(I_gray,[])
    %
    additive_blur_image = zeros(size(I_gray));
    for blur = 1:2:51
        blur_image = medfilt2(I_gray, [blur blur]);
        additive_blur_image = additive_blur_image + blur_image;
    end
    %

    figure(102); imshow(additive_blur_image,[]);
    %
    rescaled_additive_blur = rescale(additive_blur_image,0, 255);
    figure(103); imshow(rescaled_additive_blur,[]);

    % optithd
    I_optithd = optithd(rescaled_additive_blur);
    figure(104); imshow(I_optithd,[]);

    % inv optithd
    I_optithd_inv = imcomplement(I_optithd);
    figure(105); imshow(I_optithd_inv,[]);

    % need opening to sep coins from border before clearing it.
    I_optithd_inv_opened = activecontour(I_gray, I_optithd_inv);
    figure(106); imshow(I_optithd_inv_opened,[]);
        
    % clear border -- decent result, but it doesn't line up with the coin edges that well
    I_optithd_inv_borderclear = imclearborder(I_optithd_inv_opened);
    figure(107); imshow(I_optithd_inv_borderclear,[]);

    % coin_mask = I_optithd_inv_borderclear;

    % active contour    
    active_contour_fit = activecontour(I_gray, I_optithd_inv_borderclear);
    figure(108); imshow(active_contour_fit,[]);

    active_contour_fit_filled = imfill(active_contour_fit, 'holes');
    figure(109); imshow(active_contour_fit_filled,[]);

    active_contour_fit_filled_opened = imopen(active_contour_fit_filled, strel('disk', 5));
    figure(110); imshow(active_contour_fit_filled_opened,[]);

    %
    areas = struct2array(regionprops(active_contour_fit_filled_opened,'Area'))';

    % cluster areas
    cluster_labels = kmeans(areas, 2);

    % cutoff is min(large group) - max(small group) 
    group1 = areas(cluster_labels==1);
    group2 = areas(cluster_labels==2);

    if mean(group1) > mean(group2)
        pixel_cutoff = min(group1) - max(group2);
    else
        pixel_cutoff = min(group2) - max(group1);
    end

    % apply pixel cutoff to bwareaopen
    opened = bwareaopen(active_contour_fit_filled_opened, pixel_cutoff);
    figure(111); imshow(opened);

%     figure(100000); imshowpair(active_contour_fit_filled_opened, opened, "montage");title("Small Mask Deletetion");

    coin_mask = opened;
end

