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