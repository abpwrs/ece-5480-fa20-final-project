% ECE:5480 Digital Image Processing
% Final Project Part Two
% Mikayla Biggs & Alexander Powers



%% trying part1 on our data

src_dir = pwd();
filesep_idx = strfind(src_dir, filesep);
data_folder = strcat(src_dir(1:filesep_idx(end)), 'data/');
I = imread(strcat(data_folder, '0.jpg'));

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
morph_data = false(size(I));

disk5 = strel('disk', 5);
disk10 = strel('disk', 10);
disk15 = strel('disk', 15);

for channel=1:3
    I_edge = edge(I(:,:,channel), 'sobel');
    figure(200+channel); imshow(I_edge,[])
    I_close = imclose(I_edge, disk10);
    morph_data(:,:,channel)=I_close;
    figure(300+channel); imshow(I_close,[])

end

intersected_edge_masks = morph_data(:, :, 1) & morph_data(:, :, 2) & morph_data(:, :, 3);
figure(101);imshow(intersected_edge_masks,[]);
i_dil = imdilate(intersected_edge_masks, disk10);
figure(102);imshow(i_dil,[]);
i_fil = imfill(i_dil, 'holes');
figure(103);imshow(i_fill,[]);
i_err = imerode(i_fil, disk10);
figure(104);imshow(i_err,[]);
i_open = imopen(i_err, disk15);
figure(105);imshow(i_open,[]);

%% Hough Transform
min_radius = 30;
max_radius = 700; % increase this due to increased resolution and quarters

% skipping the fill holes operation and just using dilated image
% filling fills in the whole paper...
% NOTE: missing one coin on image zero

% detection method
[centers, radii, metric] = imfindcircles(i_dil, [min_radius max_radius]);
%% 
figure(1);imshow(I,[]);
viscircles(centers, radii, 'EdgeColor','b');

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
figure(2); imshow(overlay,[]);
figure(3); imshow(label_map,[]);

%% more visualizations of segmentation
BW_coin_mask = label_map > 0;
figure(4);imshow(BW_coin_mask,[]);
I_masked = I .* uint8(BW_coin_mask);
figure(5); imshow(I_masked,[]);

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

k = 3; % 3 --> part2
thresh_labels =  kmeans(radii, k);

class_1 = radii(thresh_labels==1);
class_2 = radii(thresh_labels==2);
class_3 = radii(thresh_labels==3);

mu_1 = mean(class_1);
mu_2 = mean(class_2);
mu_3 = mean(class_3);

centers_1 = centers(thresh_labels==1,:);
centers_2 = centers(thresh_labels==2,:);
centers_3 = centers(thresh_labels==3,:);

class_image = zeros(size(label_map));

for i=1:size(mask,3)
   coin_mask = mask(:,:,i);
   coin_mask_labeled = coin_mask*(thresh_labels(i));
   class_image = class_image+coin_mask_labeled;
end

class1_name = get_class_name_mu1_k3(mu_1,mu_2, mu_3);
class2_name = get_class_name_mu1_k3(mu_2,mu_3, mu_1);
class3_name = get_class_name_mu1_k3(mu_3,mu_1, mu_2);

shaded_label_img = labeloverlay(I,class_image);
figure(7); 
imshow(shaded_label_img, []);

figure(8); imshow(I,[]);  
viscircles(centers_1, class_1,'Color','b'); 
viscircles(centers_2, class_2,'Color', 'r'); 
viscircles(centers_3, class_3,'Color', 'g'); 

title('Class Labeled Image');
text(10,30, class1_name, 'Color', 'b', 'FontSize', 15, 'FontWeight', 'bold');
text(10,80, class2_name, 'Color', 'r', 'FontSize', 15, 'FontWeight', 'bold');
text(10,130, class3_name, 'Color', 'g', 'FontSize', 15, 'FontWeight', 'bold');




