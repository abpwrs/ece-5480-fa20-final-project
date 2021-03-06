% ECE:5480 Digital Image Processing
% Final Project Part Two
% Mikayla Biggs & Alexander Powers

%% Read in Coin Images
src_dir = pwd();
fname = '1-complex.jpg';
filesep_idx = strfind(src_dir, filesep);
data_folder = strcat(src_dir(1:filesep_idx(end)), 'data/');
I = imread(strcat(data_folder, fname));
is_complex = logical(numel(strfind(fname, 'complex')));
figure(1000);imshow(I)
%% Remove Noisy Background (Coin Mask Generation)
coin_mask = generateCoinMask(I);

%%
imshow(coin_mask)
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
[features, feature_image] = featureExtraction(I, other_mask, other_radii);

%% color based classification using ?-D kmeans
% color based classification using 7D kmeans
k = 2; % 3 --> part2
radii_based_labels =  kmeans(features, k);

class_1 = other_radii(radii_based_labels==1);
class_2 = other_radii(radii_based_labels==2);

mu_1 = mean(class_1);
mu_2 = mean(class_2);

centers_1 = other_centers(radii_based_labels==1,:);
centers_2 = other_centers(radii_based_labels==2,:);

if mu_1 > mu_2
    class1_name = sprintf("pennies");
    class1_color = 'b';
    class2_name = sprintf("dimes");
    class2_color = 'r';
else
    class1_name = sprintf("dimes");
    class1_color = 'r';
    class2_name = sprintf("pennies");
    class2_color = 'b';
end
class3_name = sprintf("quarters");



f7 = figure(7); imshow(I,[]);  
viscircles(centers_1, class_1,'Color', class1_color); 
viscircles(centers_2, class_2,'Color', class2_color); 
viscircles(quarter_centers, quarter_radii,'Color', 'g'); 

title('Class Labeled Image');
text(10,30, class1_name, 'Color', class1_color, 'FontSize', 15, 'FontWeight', 'bold');
text(10,80, class2_name, 'Color', class2_color, 'FontSize', 15, 'FontWeight', 'bold');
text(10,130, class3_name, 'Color', 'g', 'FontSize', 15, 'FontWeight', 'bold');

