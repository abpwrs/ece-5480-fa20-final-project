function [coin_mask] = generateCoinMaskSimple(I)
    I_hsv = rgb2hsv(I);
    edge_image = edge(I_hsv(:,:,2));
    strelly = strel('disk', 5);
    edge_image_dil = imdilate(edge_image, strelly);
    edge_image_fill = imfill(edge_image_dil, 'holes');
    edge_image_err = imerode(edge_image_fill, strelly);

    perim = bwperim(edge_image_err, 8);
    coin_mask = imfill(perim,'holes');

%     obj_areas = struct2array(regionprops(I_morph, 'area'))';
%     obj_classes = kmeans(obj_areas,2);
%  
%     c2_mean = mean(obj_areas(obj_classes==2));
%     c2_std = std(obj_areas(obj_classes==2));
%     c2_UT = c2_mean + 2*c2_std;
%     c2_LT = c2_mean - 2*c2_std;
% 
%     coin_mask = bwareafilt(I_morph, [c2_LT c2_UT]);
end

