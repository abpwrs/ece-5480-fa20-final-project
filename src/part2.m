% ECE:5480 Digital Image Processing
% Final Project Part Two
% Mikayla Biggs & Alexander Powers



%% trying part1 on our data

src_dir = pwd();
filesep_idx = strfind(src_dir, filesep);
data_folder = strcat(src_dir(1:filesep_idx(end)), 'data/');
I = imread(strcat(data_folder, '3.jpg'));

%%
I_histeq = histeq(I);
figure(1);imshow(I,[]);
figure(2);imshow(I_histeq,[]);

%%
I_histeq = adapthisteq(rgb2gray(I));
figure(1);imshow(I,[]);
figure(2);imshow(I_histeq,[]);

%% fix lighting
IInv = imcomplement(I);

IInv_reduced = imreducehaze(IInv, 'Method','approx','ContrastEnhancement','boost');
I_reinv = imcomplement(IInv_reduced);
figure, montage({I, I_reinv});

%% median filter  l channel in lab color format
I_lab = rgb2lab(I);
L = I_lab(:,:,1);
A = I_lab(:,:,2);
B = I_lab(:,:,3);
k = 20;
L_median = medfilt2(L, [k k]);
a_cont = A;%histeq(A);
b_cont = B;%histeq(B);
I_lab(:,:,1) = L_median;
I_lab(:,:,2) = a_cont;
I_lab(:,:,3) = b_cont;
RGB_reco = lab2rgb(I_lab);
figure(1); imshow(I,[]);
figure(2); imshow(RGB_reco,[]);

%%
I_histeq = histeq(I_reinv);
figure(1);imshow(I,[]);
figure(2);imshow(I_histeq,[]);

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

%% Noisy Background Removal 
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
c2_UT = c2_mean + 3*c2_std;
c2_LT = c2_mean - 2*c2_std;

coin_mask = bwareafilt(I_morph, [c2_LT c2_UT]);

%% Hough Transform
%% green channel coin mask
I_bin = imbinarize(RGB_reco(:,:,2));
I_bin = imopen(I_bin,strel('disk',20));
% coin_mask = imclearborder(imcomplement(I_bin));
coin_mask = imclearborder(imcomplement(I_bin));
figure(1);imshow(coin_mask)
%% Hough Transform
min_radius = 30;
max_radius = 2000; % increase this due to increased resolution and quarters

% skipping the fill holes operation and just using dilated image
% filling fills in the whole paper...
% NOTE: missing one coin on image zero

% detection method -- TODO: fix detection so all coins are captured
[centers, radii, metric] = imfindcircles(coin_mask, [min_radius max_radius], 'ObjectPolarity','bright','Sensitivity',0.9);

%%
% coin_mask = activecontour(I_gray, coin_mask);
% stats = regionprops('table',coin_mask,'Centroid','EquivDiameter','Eccentricity');
% stats( stats.Eccentricity == 0 | stats.Eccentricity > 0.5 , : ) = [];
% 
% centers = stats.Centroid;
% radii = stats.EquivDiameter/2;
%% 
figure(1);imshow(I,[]);
viscircles(centers, radii, 'EdgeColor','b');

%% Segmentation reconstruction from centers and radii
% based on https://www.mathworks.com/matlabcentral/fileexchange/47905-createcirclesmask-m

[x_size, y_size] = size(coin_mask);
n_coins = numel(radii);

xc = centers(:,1);
yc = centers(:,2);
[xx, yy] = meshgrid(1:y_size,1:x_size);

mask = false(x_size, y_size, n_coins);
label_map = uint8(zeros(x_size, y_size));
for ii = 1:numel(radii)
    % coin mask
	mask(:, :, ii) = hypot(xx - xc(ii), yy - yc(ii)) <= radii(ii);
    % label map
    tmp_mask = uint8(ones(size(coin_mask))) * ii;
    tmp_mask = tmp_mask .* uint8(mask(:, :, ii));
    label_map = uint8(label_map + tmp_mask);
end
label_map = uint8(label_map);

%% segmentation label overlay
overlay = labeloverlay(I, label_map);
figure(2); imshow(overlay,[]);
figure(3); imshow(label_map,[]);

%% more visualizations of segmentation
BW_coin_mask = label_map > 0;
figure(4);imshow(BW_coin_mask,[]);


%%


%% plot channel histograms
figure(6);
for channel=1:3 
    subplot(3,1,channel)
    I_channel = double(I_masked(:,:,channel));
    idx = I_channel > 0;
    histogram(I_channel(idx));
end

%% radius hist
figure(1000); histogram(radii,50)

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

figure(8); imshow(I,[]);  
viscircles(quarter_centers, quarter_radii,'Color','b'); 
viscircles(other_centers, other_radii,'Color', 'r'); 
title('Class Labeled Image');
text(10,30, quarter_name, 'Color', 'b', 'FontSize', 15, 'FontWeight', 'bold');
text(10,80, other_name, 'Color', 'r', 'FontSize', 15, 'FontWeight', 'bold');


%% hist eq I_masked to improve feature extraction
% I_masked = I .* double(BW_coin_mask);
% figure(5); imshow(I_masked,[]);
% I_masked_histeq = zeros(size(I_masked));
% for c=1:3
%     I_masked_histeq(:,:,c) = adapthisteq(I_masked(:,:,c));
%     figure(100+c);imshow(I_masked_histeq(:,:,c),[])
% end
% figure(7);imshow(uint8(I_masked_histeq), [])

%% generate 6D colour clustering features



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
radii_based_labels =  kmeans(other_radii, k);

class_1 = other_radii(radii_based_labels==1);
class_2 = other_radii(radii_based_labels==2);

mu_1 = mean(class_1);
mu_2 = mean(class_2);

centers_1 = other_centers(radii_based_labels==1,:);
centers_2 = other_centers(radii_based_labels==2,:);

class_image = zeros(size(label_map));


class1_name = get_class_name_mu1_k3(mu_1,mu_2, quarter_mu);
class2_name = get_class_name_mu1_k3(mu_2,quarter_mu, mu_1);



figure(8); imshow(I,[]);  
viscircles(centers_1, class_1,'Color','b'); 
viscircles(centers_2, class_2,'Color', 'r'); 
% viscircles(centers_3, class_3,'Color', 'g'); 

title('Class Labeled Image');
text(10,30, class1_name, 'Color', 'b', 'FontSize', 15, 'FontWeight', 'bold');
text(10,80, class2_name, 'Color', 'r', 'FontSize', 15, 'FontWeight', 'bold');
% text(10,130, class3_name, 'Color', 'g', 'FontSize', 15, 'FontWeight', 'bold');




