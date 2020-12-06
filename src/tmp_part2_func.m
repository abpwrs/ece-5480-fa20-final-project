function [done] = tmp_part2_func(file_obj, data_folder, figure_dir)
    I = imread(strcat(data_folder, file_obj.name)); 
    
    f1 = figure(1);imshow(I);
    saveas(f1, strcat(figure_dir, 'f1.png'));
    % Remove Noisy Background (Coin Mask Generation)
    coin_mask = removeNoisyBackground(I);
    
    f100 = figure(100);
    imshow(coin_mask);
    saveas(f100, strcat(figure_dir, 'f100.png'));

    % Hough Transform
    [min_radius, max_radius] = findRadiusBounds(coin_mask);

    % detection method 
    [centers, radii, ~] = imfindcircles(coin_mask, [min_radius max_radius], 'ObjectPolarity','bright','Sensitivity',0.9);

    % Display Detected Circles
    f2 = figure(2);imshow(I,[]);
    viscircles(centers, radii, 'EdgeColor','b');
    saveas(f2, strcat(figure_dir, 'f2.png'));

    % Label Map and Channel-wise Mask Generation
    mask = generateChannelMask(centers, radii, coin_mask);
    label_map = generateLabelMap(mask, radii, coin_mask);

    % Segmentation Label Overlay
    overlay = labeloverlay(I, label_map);
    f3 = figure(3); imshow(overlay,[]);
    saveas(f3, strcat(figure_dir, 'f3.png'));

    f4 = figure(4); imshow(label_map,[]);
    saveas(f4, strcat(figure_dir, 'f4.png'));

    % more visualizations of segmentation
    BW_coin_mask = label_map > 0;
    f5 = figure(5);imshow(BW_coin_mask,[]);
    saveas(f5, strcat(figure_dir, 'f5.png'));

    % All in one 7D kmeans 
    k = 3; % 3 --> part2
    class_labels = cluster_coins(I, mask, radii, k);

    class_1 = radii(class_labels==1);
    class_2 = radii(class_labels==2);
    class_3 = radii(class_labels==3);

    mu_1 = mean(class_1);
    mu_2 = mean(class_2);
    mu_3 = mean(class_3);

    centers_1 = centers(class_labels==1,:);
    centers_2 = centers(class_labels==2,:);
    centers_3 = centers(class_labels==3,:);

    class1_name = get_class_name_mu1_k3(mu_1,mu_2,mu_3);
    class2_name = get_class_name_mu1_k3(mu_2,mu_3,mu_1);
    class3_name = get_class_name_mu1_k3(mu_3,mu_1, mu_2);

    f6 = figure(6); imshow(I,[]);  
    viscircles(centers_1, class_1,'Color','b'); 
    viscircles(centers_2, class_2,'Color', 'r'); 
    viscircles(centers_3, class_3,'Color', 'g'); 

    title('Class Labeled Image');
    text(10,30, class1_name, 'Color', 'b', 'FontSize', 15, 'FontWeight', 'bold');
    text(10,80, class2_name, 'Color', 'r', 'FontSize', 15, 'FontWeight', 'bold');
    text(10,130, class3_name, 'Color', 'g', 'FontSize', 15, 'FontWeight', 'bold');
    saveas(f6, strcat(figure_dir, 'f6.png'));
    done = 1;
end

