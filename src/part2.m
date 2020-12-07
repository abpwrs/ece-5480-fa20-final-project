% ECE:5480 Digital Image Processing
% Final Project Part Two
% Mikayla Biggs & Alexander Powers

%% Read in Coin Images
src_dir = pwd();
fname = '1-simple_res-05.jpg';
filesep_idx = strfind(src_dir, filesep);
data_folder = strcat(src_dir(1:filesep_idx(end)), 'data/');
I = imread(strcat(data_folder, fname));
is_complex = logical(numel(strfind(fname, 'complex')));

%% Remove Noisy Background (Coin Mask Generation)
if is_complex
    coin_mask = removeNoisyBackground(I);
else
    coin_mask = generateCoinMaskSimple(I);
end


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
