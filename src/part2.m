% ECE:5480 Digital Image Processing
% Final Project Part Two
% Mikayla Biggs & Alexander Powers

%% Read in Coin Images
src_dir = pwd();
filesep_idx = strfind(src_dir, filesep);
data_folder = strcat(src_dir(1:filesep_idx(end)), 'data/');
I = imread(strcat(data_folder, '1-complex_res-0125.jpg'));

%% fix lighting
IInv = imcomplement(I);

IInv_reduced = imreducehaze(IInv, 'Method','approx','ContrastEnhancement','boost');
I_reinv = imcomplement(IInv_reduced);
figure(1), montage({I, I_reinv});

%% Remove Noisy Background (Coin Mask Generation)
coin_mask = removeNoisyBackground(I);

%% Hough Transform
min_radius = 10;
max_radius = 2000; % increase this due to increased resolution and quarters

% detection method 
[centers, radii, metric] = imfindcircles(coin_mask, [min_radius max_radius], 'ObjectPolarity','bright','Sensitivity',0.9);

% Display Detected Circles
figure(2);imshow(I,[]);
viscircles(centers, radii, 'EdgeColor','b');

%% Label Map and Channel-wise Mask Generation
mask = generateChannelMask(centers, radii, coin_mask);
label_map = generateLabelMap(mask, radii, coin_mask);

%% Segmentation Label Overlay
overlay = labeloverlay(I, label_map);
figure(3); imshow(overlay,[]);
figure(4); imshow(label_map,[]);

% more visualizations of segmentation
BW_coin_mask = label_map > 0;
figure(5);imshow(BW_coin_mask,[]);

%% All in one 7D kmeans 
I_hsv = rgb2hsv(I);
n_coins = size(mask,3);
features = ones(n_coins,7);
features(:,7) = radii;
for coin_idx=1:n_coins
    % rgb features
    color_coin_mask = I .* uint8(mask(:,:,coin_idx));
    for channel_idx=1:3
        channel = color_coin_mask(:,:,channel_idx);
        channel_sum = sum(channel, 'all');
        channel_elem_count = sum(uint8(mask(:,:,coin_idx)),'all');
        features(coin_idx, channel_idx) = (channel_sum / channel_elem_count)/256;
    end
    
    % hsv features
    color_coin_mask = I_hsv .* double(mask(:,:,coin_idx));
    offset = 3;
    for channel_idx=1:3
        channel = color_coin_mask(:,:,channel_idx);
        channel_sum = sum(channel, 'all');
        channel_elem_count = sum(uint8(mask(:,:,coin_idx)),'all');
        features(coin_idx, channel_idx+offset) = (channel_sum / channel_elem_count);
    end
end

k = 3; % 3 --> part2
radii_based_labels =  kmeans(features, k);

class_1 = radii(radii_based_labels==1);
class_2 = radii(radii_based_labels==2);
class_3 = radii(radii_based_labels==3);

mu_1 = mean(class_1);
mu_2 = mean(class_2);
mu_3 = mean(class_3);

centers_1 = centers(radii_based_labels==1,:);
centers_2 = centers(radii_based_labels==2,:);
centers_3 = centers(radii_based_labels==3,:);

class1_name = get_class_name_mu1_k3(mu_1,mu_2,mu_3);
class2_name = get_class_name_mu1_k3(mu_2,mu_3,mu_1);
class3_name = get_class_name_mu1_k3(mu_3,mu_1, mu_2);

figure(10); imshow(I,[]);  
viscircles(centers_1, class_1,'Color','b'); 
viscircles(centers_2, class_2,'Color', 'r'); 
viscircles(centers_3, class_3,'Color', 'g'); 

title('Class Labeled Image');
text(10,30, class1_name, 'Color', 'b', 'FontSize', 15, 'FontWeight', 'bold');
text(10,80, class2_name, 'Color', 'r', 'FontSize', 15, 'FontWeight', 'bold');
text(10,130, class3_name, 'Color', 'g', 'FontSize', 15, 'FontWeight', 'bold');


%% median filter  l channel in lab color format
% I_lab = rgb2lab(I);
% L = I_lab(:,:,1);
% A = I_lab(:,:,2);
% B = I_lab(:,:,3);
% k = 20;
% L_median = medfilt2(L, [k k]);
% a_cont = A;%histeq(A);
% b_cont = B;%histeq(B);
% I_lab(:,:,1) = L_median;
% I_lab(:,:,2) = a_cont;
% I_lab(:,:,3) = b_cont;
% RGB_reco = lab2rgb(I_lab);
% figure(1); imshow(I,[]);
% figure(2); imshow(RGB_reco,[]);

%%
% I_histeq = histeq(I_reinv);
% figure(1);imshow(I,[]);
% figure(2);imshow(I_histeq,[]);

%% median filtering 
% this takes awhile
% R = I(:, :, 1); 
% R = rmfilter(R);
% G = I(:, :, 2); 
% G = rmfilter(G);
% B = I(:, :, 3); 
% B = rmfilter(B);
% I_median = cat(3, R, G, B);
% imwrite(I_median, strcat(data_folder, '0_rmfilter.png'));
% 
% I_median = imread(strcat(data_folder, '0_rmfilter.png'));


%% morphological processing
% morph_data = false(size(I));
% 
% disk5 = strel('disk', 5);
% disk10 = strel('disk', 10);
% disk15 = strel('disk', 15);
% 
% for channel=1:3
%     I_edge = edge(I(:,:,channel), 'sobel');
%     figure(200+channel); imshow(I_edge,[])
%     I_close = imclose(I_edge, disk10);
%     morph_data(:,:,channel)=I_close;
%     figure(300+channel); imshow(I_close,[])
% 
% end
% 
% intersected_edge_masks = morph_data(:, :, 1) & morph_data(:, :, 2) & morph_data(:, :, 3);
% figure(101);imshow(intersected_edge_masks,[]);
% i_dil = imdilate(intersected_edge_masks, disk10);
% figure(102);imshow(i_dil,[]);
% i_fil = imfill(i_dil, 'holes');
% figure(103);imshow(i_fil,[]);
% i_err = imerode(i_fil, disk10);
% figure(104);imshow(i_err,[]);
% i_open = imopen(i_err, disk15);
% figure(105);imshow(i_open,[]);
%%
% coin_mask = activecontour(I_gray, coin_mask);
% stats = regionprops('table',coin_mask,'Centroid','EquivDiameter','Eccentricity');
% stats( stats.Eccentricity == 0 | stats.Eccentricity > 0.5 , : ) = [];
% 
% centers = stats.Centroid;
% radii = stats.EquivDiameter/2;
%% plot channel histograms
% figure(6);
% for channel=1:3 
%     subplot(3,1,channel)
%     I_channel = double(I_masked(:,:,channel));
%     idx = I_channel > 0;
%     histogram(I_channel(idx));
% end

%% radius hist
% figure(1000); histogram(radii,50)
%% hist eq I_masked to improve feature extraction
% I_masked = I .* double(BW_coin_mask);
% figure(5); imshow(I_masked,[]);
% I_masked_histeq = zeros(size(I_masked));
% for c=1:3
%     I_masked_histeq(:,:,c) = adapthisteq(I_masked(:,:,c));
%     figure(100+c);imshow(I_masked_histeq(:,:,c),[])
% end
% figure(7);imshow(uint8(I_masked_histeq), [])
