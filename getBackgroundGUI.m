function [mask] = getBackgroundGUI(fluo, param)
smoothed = imgaussfilt(fluo, param.smoothing);

% Get otsu threshold
gfpcounts = imhist(smoothed, 2^16);
gfpotsu = otsuthresh(gfpcounts);

% Binarize and dilate
bin = imbinarize(smoothed, gfpotsu);
mask = ~imdilate(bin, strel('disk', param.dilate));
end



