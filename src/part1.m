% ECE:5480 Digital Image Processing
% Final Project Part One
% Mikayla Biggs & Alexander Powers

src_dir = pwd();
filesep_idx = strfind(src_dir, filesep);
data_folder = strcat(src_dir(1:filesep_idx(end)), 'data/');
I = imread(strcat(data_folder, 'PandD.tif'));

%% color channel preprocessing to remove lines

%% lol, just hit it with a massive median filter
% median filtering
filter_mag = 30;
R=I(:,:,1); R = medfilt2(R, [filter_mag filter_mag]);
G=I(:,:,2); G = medfilt2(G, [filter_mag filter_mag]);
B=I(:,:,3); B = medfilt2(B, [filter_mag filter_mag]);
J=cat(3,R,G,B);
figure(100); imshow(J,[]);


%% circle detection using circular hough transform
% https://www.mathworks.com/help/images/ref/imfindcircles.html

% radius values -- for part2 this needs to be adaptive to image scale
min_radius = 20;
max_radius = 5000;

% detection method
[centers, radii, metric] = imfindcircles(J, [min_radius max_radius]);

figure(1);imshow(J,[]);
viscircles(centers, radii, 'EdgeColor','b');

