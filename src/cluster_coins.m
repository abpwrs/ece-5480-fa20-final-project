function [classification] = cluster_coins(I, masks, radii, k)
    % performs 7D clustering of coins using features
    % [R G B H S V radius]
    I_hsv = rgb2hsv(I);
    n_coins = size(masks,3);
    features = ones(n_coins,7);
    features(:,7) = radii;
    for coin_idx=1:n_coins
        % rgb features
        color_coin_mask = I .* uint8(masks(:,:,coin_idx));
        for channel_idx=1:3
            channel = color_coin_mask(:,:,channel_idx);
            channel_sum = sum(channel, 'all');
            channel_elem_count = sum(uint8(masks(:,:,coin_idx)),'all');
            features(coin_idx, channel_idx) = (channel_sum / channel_elem_count)/256;
        end

        % hsv features
        color_coin_mask = I_hsv .* double(masks(:,:,coin_idx));
        offset = 3;
        for channel_idx=1:3
            channel = color_coin_mask(:,:,channel_idx);
            channel_sum = sum(channel, 'all');
            channel_elem_count = sum(uint8(masks(:,:,coin_idx)),'all');
            features(coin_idx, channel_idx+offset) = (channel_sum / channel_elem_count);
        end
    end

    classification =  kmeans(features, k);
end

