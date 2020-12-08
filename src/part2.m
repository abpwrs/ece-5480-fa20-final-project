% ECE:5480 Digital Image Processing
% Final Project Part Two
% Mikayla Biggs & Alexander Powers

%% Read in Coin Images
src_dir = pwd();
fname = '2-simple_res-0125.jpg';
filesep_idx = strfind(src_dir, filesep);
data_folder = strcat(src_dir(1:filesep_idx(end)), 'data/');
I = imread(strcat(data_folder, fname));
is_complex = logical(numel(strfind(fname, 'complex')));
figure(1000);imshow(I)
%% Remove Noisy Background (Coin Mask Generation)
% if is_complex
%     coin_mask = generateCoinMaskComplex(I);
% else
%     coin_mask = generateCoinMaskSimple(I);
% end
% 
% coin_mask = generateCoinMask(I);
% figure(100); imshow(coin_mask, [])



% all background noise is red and blue. blast those channels with a median
% filter -- bad bg is also in green channel

% R = I(:,:,1);
% G = I(:,:,2);
% B = I(:,:,3);
% figure(1); imshow(R);
% figure(2); imshow(G);
% figure(3); imshow(B);
% d = 25;
% R = medfilt2(R, [d d]);
% B = medfilt2(B, [d d]);
% figure(4); imshow(R);
% figure(5); imshow(G);
% figure(6); imshow(B);
% I_reproc = cat(3, R, G, B);
% figure(7);imshow(I_reproc)

%% blur adding
I_gray = rescale(double(rgb2gray(I)),0,1);

figure(2000); imshow(I_gray,[])'
%%
additive_blur_image = zeros(size(I_gray));
for blur = 1:2:51
    blur_image = medfilt2(I_gray, [blur blur]);
    additive_blur_image = additive_blur_image + blur_image;
end
%%

figure(1); imshow(additive_blur_image,[]);
%%
rescaled_additive_blur = rescale(additive_blur_image,0, 255);
figure(1); imshow(rescaled_additive_blur,[]);

%% optithd
I_optithd = optithd(rescaled_additive_blur);
figure(1); imshow(I_optithd,[]);

%% inv optithd
I_optithd_inv = imcomplement(I_optithd);
figure(1); imshow(I_optithd_inv,[]);

%% clear border -- decent result, but it doesn't line up with the coin edges that well
I_optithd_inv_borderclear = imclearborder(I_optithd_inv);
figure(1); imshow(I_optithd_inv_borderclear,[]);

% coin_mask = I_optithd_inv_borderclear;

%% active contour

active_contour_fit = activecontour(I_gray, I_optithd_inv_borderclear);
figure(2); imshow(active_contour_fit,[]);

coin_mask = active_contour_fit;
%%
bin_additive_blur = imbinarize(rescaled_additive_blur);
figure(1); imshow(bin_additive_blur,[]);

%%
% binarize

% increasingly large opening operators until some condition indicates we
% start loosing coins
%% Hough Transform
[min_radius, max_radius] = findRadiusBounds(coin_mask);

% detection method 
[centers, radii, metric] = imfindcircles(coin_mask, [min_radius max_radius], 'ObjectPolarity','bright', 'Sensitivity', 0.9);

% Display Detected Circles
figure(1);imshow(I,[]);
viscircles(centers, radii, 'EdgeColor','b');

%% Label Map and Channel-wise Mask Generation
mask = generateChannelMask(centers, radii, coin_mask);
label_map = generateLabelMap(mask, radii, coin_mask);

%% Segmentation Label Overlay
overlay = labeloverlay(I, label_map);
figure(2); imshow(overlay,[]);
figure(3); imshow(label_map,[]);

% more visualizations of segmentation
BW_coin_mask = label_map > 0;
figure(4);imshow(BW_coin_mask,[]);

%% radii based classification using 1D kmeans
k = 2; % 3 --> part2
radii_based_labels =  kmeans(radii, k);
mu_1 = mean(radii(radii_based_labels==1));
mu_2 = mean(radii(radii_based_labels==2));
if mu_1 > mu_2
    quarter_radii = radii(radii_based_labels==1,:);
    quarter_centers = centers(radii_based_labels==1,:);
    quarter_mu = mu_1;
    other_radii = radii(radii_based_labels==2,:);
    other_centers = centers(radii_based_labels==2,:);
    
    other_mask = mask(:,:,radii_based_labels==2);
else
    quarter_radii = radii(radii_based_labels==2,:);
    quarter_centers = centers(radii_based_labels==2,:);
    quarter_mu = mu_1;
    other_radii = radii(radii_based_labels==1,:);
    other_centers = centers(radii_based_labels==1,:);
    other_mask = mask(:,:,radii_based_labels==1);

end


quarter_name=sprintf('Quarters');
other_name=sprintf('Other');

figure(5); imshow(I,[]);  
viscircles(quarter_centers, quarter_radii,'Color','b'); 
viscircles(other_centers, other_radii,'Color', 'r'); 
title('Class Labeled Image');
text(10,30, quarter_name, 'Color', 'b', 'FontSize', 15, 'FontWeight', 'bold');
text(10,80, other_name, 'Color', 'r', 'FontSize', 15, 'FontWeight', 'bold');




%% generate 7D colour + radii clustering features

I_hsv = rgb2hsv(I);
n_coins = size(other_mask,3);
features = ones(n_coins,7);
features(:,7) = other_radii;
for coin_idx=1:n_coins
    % rgb features
    color_coin_mask = I .* uint8(other_mask(:,:,coin_idx));
    for channel_idx=1:3
        channel = color_coin_mask(:,:,channel_idx);
        channel_sum = sum(channel, 'all');
        channel_elem_count = sum(uint8(other_mask(:,:,coin_idx)),'all');
        features(coin_idx, channel_idx) = (channel_sum / channel_elem_count)/256;
    end
    
    % hsv features
    color_coin_mask = I_hsv .* double(other_mask(:,:,coin_idx));
    offset = 3;
    for channel_idx=1:3
        channel = color_coin_mask(:,:,channel_idx);
        channel_sum = sum(channel, 'all');
        channel_elem_count = sum(uint8(other_mask(:,:,coin_idx)),'all');
        features(coin_idx, channel_idx+offset) = (channel_sum / channel_elem_count);
    end
end
%% color based classification using ?-D kmeans
k = 2; % 3 --> part2
radii_based_labels =  kmeans(features, k);
class_1 = other_radii(radii_based_labels==1);
class_2 = other_radii(radii_based_labels==2);
mu_1 = mean(class_1);
mu_2 = mean(class_2);
centers_1 = other_centers(radii_based_labels==1,:);
centers_2 = other_centers(radii_based_labels==2,:);
class_image = zeros(size(label_map));
class1_name = get_class_name_mu1_k3(mu_1,mu_2, quarter_mu);
class2_name = get_class_name_mu1_k3(mu_2,quarter_mu, mu_1);
class3_name = get_class_name_mu1_k3(quarter_mu,mu_1, mu_2);



figure(6); imshow(I,[]);  
viscircles(centers_1, class_1,'Color','b'); 
viscircles(centers_2, class_2,'Color', 'r'); 
viscircles(quarter_centers, quarter_radii,'Color', 'g'); 
title('Class Labeled Image');
text(10,30, class1_name, 'Color', 'b', 'FontSize', 15, 'FontWeight', 'bold');
text(10,80, class2_name, 'Color', 'r', 'FontSize', 15, 'FontWeight', 'bold');
text(10,130, class3_name, 'Color', 'g', 'FontSize', 15, 'FontWeight', 'bold');
