function [done] = tmp_part2_func(file_obj, data_folder, figure_dir)
    I = imread(strcat(data_folder, file_obj.name)); 
    
    f1 = figure(1);imshow(I); title("Original Image");
    saveas(f1, strcat(figure_dir, 'f1.png'));
    % Remove Noisy Background (Coin Mask Generation)
    is_complex = logical(numel(strfind(file_obj.name, 'complex')));

%     if is_complex
%         coin_mask = removeNoisyBackground(I);
%     else
%         coin_mask = generateCoinMaskSimple(I);
%     end

    coin_mask = generateCoinMask(I);
    
    f100 = figure(100);
    imshow(coin_mask); title("Morphology Based Coin Mask");
    saveas(f100, strcat(figure_dir, 'coin_mask.png'));

    % Hough Transform
    [min_radius, max_radius] = findRadiusBounds(coin_mask);

    % detection method 
    [centers, radii, ~] = imfindcircles(coin_mask, [min_radius max_radius], 'ObjectPolarity','bright', 'Sensitivity', 0.9);

    % Display Detected Circles
    f2 = figure(2);imshow(I,[]); title("Circles Detected by Hough");
    viscircles(centers, radii, 'EdgeColor','b');
    saveas(f2, strcat(figure_dir, 'circles.png'));

    % Label Map and Channel-wise Mask Generation
    mask = generateChannelMask(centers, radii, coin_mask);
    label_map = generateLabelMap(mask, radii, coin_mask);

    % Segmentation Label Overlay
    overlay = labeloverlay(I, label_map);
    f3 = figure(3); imshow(overlay,[]); title("Label Overlay");
    saveas(f3, strcat(figure_dir, 'label_overlay.png'));

    f4 = figure(4); imshow(label_map,[]);
    saveas(f4, strcat(figure_dir, 'label_map.png'));

    % more visualizations of segmentation
    BW_coin_mask = label_map > 0;
    f5 = figure(5);imshow(BW_coin_mask,[]); title("Coin Mask");
    saveas(f5, strcat(figure_dir, 'hough_coin_mask.png'));
    
    
    f50 = figure(50);
    extracted_coin_image = uint8(BW_coin_mask) .* I;
    imshow(extracted_coin_image,[]);title("Coin Image");
    saveas(f50, strcat(figure_dir, 'coin_image.png'));

    
    
    % radii based classification using 1D kmeans
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

    f6 = figure(6); imshow(I,[]); title("K-Means Stage One: Quarter Classification");
    viscircles(quarter_centers, quarter_radii,'Color','b'); 
    viscircles(other_centers, other_radii,'Color', 'r'); 
    text(10,30, quarter_name, 'Color', 'b', 'FontSize', 15, 'FontWeight', 'bold');
    text(10,80, other_name, 'Color', 'r', 'FontSize', 15, 'FontWeight', 'bold');
    saveas(f6, strcat(figure_dir, 'kmeans_stage1.png'));




    % generate 7D colour + radii clustering features
    [features, feature_image] = featureExtraction(I, other_mask, other_radii);

    f60 = figure(60);
    imshow(feature_image,[]);title("Color Feature Image");
    saveas(f60, strcat(figure_dir, 'color_feature_image.png'));

    
    f61 = figure(61);
    coin_feature_image = uint8(BW_coin_mask) .* feature_image;
    imshow(coin_feature_image,[]);title("Coin Color Feature Image");
    saveas(f61, strcat(figure_dir, 'coin_color_feature_image.png'));
    
    % color based classification using 7D kmeans
    k = 2; % 3 --> part2
    radii_based_labels =  kmeans(features, k);

    class_1 = other_radii(radii_based_labels==1);
    class_2 = other_radii(radii_based_labels==2);

    mu_1 = mean(class_1);
    mu_2 = mean(class_2);

    centers_1 = other_centers(radii_based_labels==1,:);
    centers_2 = other_centers(radii_based_labels==2,:);

    if mu_1 > mu_2
        class1_name = sprintf("pennies");
        class1_color = 'b';
        class2_name = sprintf("dimes");
        class2_color = 'r';
    else
        class1_name = sprintf("dimes");
        class1_color = 'r';
        class2_name = sprintf("pennies");
        class2_color = 'b';
    end
    class3_name = sprintf("quarters");



    f7 = figure(7); imshow(I,[]);  
    viscircles(centers_1, class_1,'Color', class1_color); 
    viscircles(centers_2, class_2,'Color', class2_color); 
    viscircles(quarter_centers, quarter_radii,'Color', 'g'); 

    title('Class Labeled Image');
    text(10,30, class1_name, 'Color', class1_color, 'FontSize', 15, 'FontWeight', 'bold');
    text(10,80, class2_name, 'Color', class2_color, 'FontSize', 15, 'FontWeight', 'bold');
    text(10,130, class3_name, 'Color', 'g', 'FontSize', 15, 'FontWeight', 'bold');
    saveas(f7, strcat(figure_dir, 'kmeans_stage2.png'));

    done = 1;
end

