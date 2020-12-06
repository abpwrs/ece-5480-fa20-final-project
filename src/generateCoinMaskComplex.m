function [coin_mask] = generateCoinMaskComplex(I)
    I_hsv = rgb2hsv(I);
    I_gray = rgb2gray(I);
    I_hue = imdilate(imbinarize(I_hsv(:,:,1)), strel('disk',10));
    I_filt = medfilt2(I_gray, [50 50]);
    I_gray(I_hue) = I_filt(I_hue);
    I_bin = imclearborder(imcomplement(imbinarize(I_gray)));
    coin_mask = imfill(I_bin, 'holes');
end

