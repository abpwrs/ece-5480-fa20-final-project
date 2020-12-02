function [label_map] = generateLabelMap(mask, radii, coin_mask)
    [x_size, y_size] = size(coin_mask);
    label_map = uint8(zeros(x_size, y_size));
    for ii = 1:numel(radii)
        tmp_mask = uint8(ones(size(coin_mask))) * ii;
        tmp_mask = tmp_mask .* uint8(mask(:, :, ii));
        label_map = uint8(label_map + tmp_mask);
    end
    label_map = uint8(label_map);
end