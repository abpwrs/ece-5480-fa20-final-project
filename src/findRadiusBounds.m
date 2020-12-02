function [min_radius, max_radius] = findRadiusBounds(coin_mask)
%FINDRADIUSBOUNDS Summary of this function goes here
%   Detailed explanation goes here

    stats = regionprops('table',coin_mask,'Centroid','EquivDiameter','Eccentricity');
    stats( stats.Eccentricity == 0 | stats.Eccentricity > 0.5 , : ) = [];

    radii = stats.EquivDiameter/2;
    range_buffer = (max(radii)-min(radii))/2;

    min_radius = floor(min(radii)-range_buffer);
    max_radius = ceil(max(radii)+range_buffer);
end

