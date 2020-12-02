% snippets of code that are helpful but unused in final solution


%% median filtering 
% this takes awhile
% R = I(:, :, 1); 
% R = rmfilter(R);
% G = I(:, :, 2); 
% G = rmfilter(G);
% B = I(:, :, 3); 
% B = rmfilter(B);
% I_median = cat(3, R, G, B);
% imwrite(I_median, strcat(data_folder, 'PandD_rmfilter.png'));

% I_median = imread(strcat(data_folder, 'PandD_rmfilter.png'));


%% multi thresh -- never worked

thresh = multithresh(I_masked,2);
seg_I = imquantize(I_masked,thresh);
% RGB = label2rgb(seg_I); 	 
figure(8);imshow(seg_I,[]);


%% fix lighting
% IInv = imcomplement(I);
% 
% IInv_reduced = imreducehaze(IInv, 'Method','approx','ContrastEnhancement','boost');
% I_reinv = imcomplement(IInv_reduced);
% figure(1), montage({I, I_reinv});

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
