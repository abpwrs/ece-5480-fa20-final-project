function [mask] = generateChannelMask(centers, radii, coin_mask)
    [x_size, y_size] = size(coin_mask);
    n_coins = numel(radii);

    xc = centers(:,1);
    yc = centers(:,2);
    [xx, yy] = meshgrid(1:y_size,1:x_size);

    mask = false(x_size, y_size, n_coins);
    
    for ii = 1:numel(radii)
        mask(:, :, ii) = hypot(xx - xc(ii), yy - yc(ii)) <= radii(ii);
    end
end