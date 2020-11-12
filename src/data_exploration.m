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

