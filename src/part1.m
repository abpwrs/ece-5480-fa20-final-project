% ECE:5480 Digital Image Processing
% Final Project Part One
% Mikayla Biggs & Alexander Powers

src_dir = pwd();
filesep_idx = strfind(src_dir, filesep);
data_folder = strcat(src_dir(1:filesep_idx(end)), 'data/');
I = imread(strcat(data_folder, 'PandD.tif'));

%% median filtering
% this takes awhile
% R = I(:, :, 1); 
% R = rmfilter(R);
% G = I(:, :, 2); 
% G = rmfilter(G);
% B = I(:, :, 3); 
% B = rmfilter(B);
% I_median = cat(3, R, G, B);

I_median = imread(strcat(data_folder, 'PandD_rmfilter.png'));

%% morphological processing
morph_data = false(size(I_median));

disk5 = strel('disk', 5);
disk10 = strel('disk', 10);
disk15 = strel('disk', 15);

for channel=1:3
    I_edge = edge(I(:,:,channel), 'sobel');
    I_close = imclose(I_edge, disk5);
    morph_data(:,:,channel)=I_close;
end

intersected_edge_masks = morph_data(:, :, 1) & morph_data(:, :, 2) & morph_data(:, :, 3);
i_dil = imdilate(intersected_edge_masks, disk10);
i_fil = imfill(i_dil, 'holes');
i_err = imerode(i_fil, disk10);
i_open = imopen(i_err,disk15);

%% Hough Transform
min_radius = 20;
max_radius = 100;

% detection method
[centers, radii, metric] = imfindcircles(i_open, [min_radius max_radius]);

% figure(1);imshow(I,[]);
% viscircles(centers, radii, 'EdgeColor','b');

%% Segmentation reconstruction from centers and radii
% based on https://www.mathworks.com/matlabcentral/fileexchange/47905-createcirclesmask-m

[x_size, y_size] = size(i_open);
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
    tmp_mask = uint8(ones(size(i_open))) * ii;
    tmp_mask = tmp_mask .* uint8(mask(:, :, ii));
    label_map = uint8(label_map + tmp_mask);
end
label_map = uint8(label_map);

%% segmentation label overlay
overlay = labeloverlay(I, label_map);
figure(1); imshow(overlay,[]);
figure(2); imshow(label_map,[]);

%% classification into pennies and dimes
BW_coin_mask = label_map > 0;
figure(3);imshow(BW_coin_mask,[]);
I_masked = I .* uint8(BW_coin_mask);
figure(4); imshow(I_masked,[]);
I_masked_eq = histeq(I_masked);
figure(5);imshow(I_masked_eq,[]);
%[L, centers] = imsegkmeans(I_masked, 3);

%%
figure(6);
for channel=1:3 
    subplot(3,1,channel)
    I_channel = double(I_masked(:,:,channel));
    idx = I_channel > 0;
    hist(I_channel(idx));
end
%% classification label overlay
class_labeloverlay = labeloverlay(I, L);
figure(7);imshow(class_labeloverlay,[]);

%% multi thresh

thresh = multithresh(I_masked,2);
seg_I = imquantize(I_masked,thresh);
% RGB = label2rgb(seg_I); 	 
figure(8);imshow(seg_I,[]);

%% radii based classification
thresh = 48.0;

thresh_labels =  kmeans(radii,2);

class_info = cat(2, thresh_labels, radii);
class_1 = radii(thresh_labels==1);
class_2 = radii(thresh_labels==2);

mu_1 = mean(class_1);
mu_2 = mean(class_2);
centers_1 = centers(thresh_labels==1,:);
centers_2 = centers(thresh_labels==2,:);

class_image = zeros(size(label_map));

for i=1:size(mask,3)
   coin_mask = mask(:,:,i);
   coin_mask_labeled = coin_mask*(classification(i)+1);
   class_image = class_image+coin_mask_labeled;
end

if mu_1 > mu_2
    class1_name=sprintf('pennies');
    class2_name=sprintf('dimes');
else
    class1_name=sprintf('dimes');
    class2_name=sprintf('pennies');
end

shaded_label_img = labeloverlay(I,class_image);
figure(9), imshow(I,[]);  
viscircles(centers_1, class_1,'Color','b'); 
viscircles(centers_2, class_2,'Color', 'r'); 
title('Class Labeled Image');
text(10,30, class1_name, 'Color', 'b', 'FontSize', 15, 'FontWeight', 'bold');
text(10,80, class2_name, 'Color', 'r', 'FontSize', 15, 'FontWeight', 'bold');
