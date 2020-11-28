% ECE:5480 Digital Image Processing
% Final Project Exploratory Script
% Mikayla Biggs & Alexander Powers

%% Read image file
% this should work on all OS
src_dir = pwd();
filesep_idx = strfind(src_dir, filesep);
data_folder = strcat(src_dir(1:filesep_idx(end)), 'data/');
I = imread(strcat(data_folder, 'PandD.tif'));
figure(1);imshow(I,[]);
I = rgb2hsv(I);

%% Overview of Image features
figure(2);
R = I(:,:,1);
G = I(:,:,2);
B = I(:,:,3);

R_fft = log(abs(fftshift(fft2(R)))) + 1;
G_fft = log(abs(fftshift(fft2(G)))) + 1;
B_fft = log(abs(fftshift(fft2(B)))) + 1;

subplot(3,3,1);
imshow(R,[]);
title('Red Channel');

subplot(3,3,2);
imshow(G,[]);
title('Green Channel');

subplot(3,3,3);
imshow(B,[]);
title('Blue Channel');


subplot(3,3,4);
imshow(R_fft,[]);
title('Red Channel FFT');

subplot(3,3,5);
imshow(G_fft,[]);
title('Green Channel FFT');

subplot(3,3,6);
imshow(B_fft,[]);
title('Blue Channel FFT');


subplot(3,3,7);
imhist(R);
title('Red Channel Hist');

subplot(3,3,8);
imhist(G);
title('Green Channel Hist');

subplot(3,3,9);
imhist(B);
title('Blue Channel Hist');

%% median filtering
filter_mag = 30;
R=I(:,:,1); R = medfilt2(R, [filter_mag filter_mag]);
G=I(:,:,2); G = medfilt2(G, [filter_mag filter_mag]);
B=I(:,:,3); B = medfilt2(B, [filter_mag filter_mag]);
J=cat(3,R,G,B);
figure(3); imshow(J,[]);


%% rotational median filtering
R=I(:,:,1); R = rmfilter(R);
G=I(:,:,2); G = rmfilter(G);
B=I(:,:,3); B = rmfilter(B);
J=cat(3,R,G,B);
figure(4); imshow(J,[]);

%% 
figure(1000); imshow(uint8(J),[])
imwrite(uint8(J),strcat(data_folder, 'PandD_rmfilter.png'))

%% 
src_dir = pwd();
filesep_idx = strfind(src_dir, filesep);
data_folder = strcat(src_dir(1:filesep_idx(end)), 'data/');
I = imread(strcat(data_folder, 'PandD_rmfilter.png'));

figure(1);imshow(I,[]);

morph_data = zeros(size(I));

% I_gray = rgb2gray(I);
% figure(2);imshow(I_gray,[]);
% 
% I_gray_histeq = histeq(I_gray);
% figure(3);imshow(I_gray_histeq);

% I_thresh = optithd(I_gray);
% figure(4);imshow(I_thresh,[]);

disk5 = strel('disk',5);
disk10 = strel('disk',10);
disk15 = strel('disk',15);
disk20 = strel('disk',20);

for channel=1:3
    channel
    I_edge = edge(I(:,:,channel), 'sobel');
    figure(5);imshow(I_edge,[]);

    I_close = imclose(I_edge,disk5);
    figure(100+channel);imshow(I_close,[]);
    morph_data(:,:,channel)=I_close;
end

%% intersect all of the morph data from each channel
morph_data = logical(morph_data);

intersected_edge_masks = morph_data(:,:,1) & morph_data(:,:,2) & morph_data(:,:,3);
figure(90); imshow(intersected_edge_masks, []);
% intersected_closed = imclose(intersected_edge_masks, disk15);
i_dil = imdilate(intersected_edge_masks,disk10);
figure(91);imshow(i_dil,[])
i_fil = imfill(i_dil, 'holes');
figure(92); imshow(i_fil,[]);
i_err = imerode(i_fil,disk10);
figure(93);imshow(i_err,[])

i_open = imopen(i_err,disk15);
figure(94);imshow(i_open,[])

min_radius = 20;
max_radius = 100;

% detection method
[centers, radii, metric] = imfindcircles(i_open, [min_radius max_radius]);

figure(7);imshow(I,[]);
viscircles(centers, radii, 'EdgeColor','b');


%%

vert_edge_kernel = [-1 0 1; -2 0 2; -1 0 1];
vert_edges = conv2(I_gray, vert_edge_kernel);
figure(1);imshow(vert_edges1,[]);
edges = abs(vert_edges) > mean(abs(vert_edges),'all');
figure(2);imshow(edges,[])












