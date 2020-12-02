function [coin_mask] = removeNoisyBackground(I)
    I_hsv = rgb2hsv(I);
    I_gray = rgb2gray(I);
    I_hue = imbinarize(I_hsv(:,:,1));
    I_filt = medfilt2(I_gray, [250 250]);
    I_gray(I_hue) = I_filt(I_hue);
    I_bin = imclearborder(imcomplement(imbinarize(I_gray)));
    I_morph = imfill(I_bin, 'holes');
    obj_areas = struct2array(regionprops(I_morph, 'area'))';
    obj_classes = kmeans(obj_areas,2);
    c2_mean = mean(obj_areas(obj_classes==2));
    c2_std = std(obj_areas(obj_classes==2));
    c2_UT = c2_mean + 2*c2_std;
    c2_LT = c2_mean - 2*c2_std;

    coin_mask = bwareafilt(I_morph, [c2_LT c2_UT]);
end