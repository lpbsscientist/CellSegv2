function [mask] = cellWatershedGUI2(bf, bgmask, ccRows, ccCols, param, demo)

if nargin < 6
    demo=0;
end


% Get cellcenter mask
imsize = size(bf);
cellcenter = zeros(imsize(1), imsize(2));

for i = 1:length(ccRows)
    cellcenter(ccRows(i), ccCols(i)) = 1;
end
cellcenter_dil = imdilate(cellcenter, strel('disk', param.center_dilate));

% Run watershed on smoothed brightfield / phase contrast image
smooth_bf = imgaussfilt(bf, param.smooth);
toshed_bf = imimposemin(smooth_bf, bgmask | cellcenter_dil);
mask = watershed(toshed_bf);

% Set value of background to -1
tmp = mask(bgmask);
bgval = tmp(1);
mask(mask==bgval) = -1;

% If demo is activated, show image and seeds
if demo
    in8bit = uint8(rescale(bf, 0, 255));
    figure
    montage({in8bit, bgmask | cellcenter_dil});
end

end
