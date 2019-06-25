function [mask] = getBackgroundGUI(fluo, param, demo)

if nargin<3
    demo=0;
end

smoothed = imgaussfilt(fluo, param.smoothing);

% Get otsu threshold
gfpcounts = imhist(smoothed, 2^16);
gfpotsu = otsuthresh(gfpcounts);

% Binarize and dilate
bin = imbinarize(smoothed, gfpotsu);
mask = ~imdilate(bin, strel('disk', param.dilate));

% If demo is activated, show intermediary images
if demo
    in8bit = uint8(rescale(fluo, 0, 255));

    figure
    montage({in8bit, bin, mask},...
            'ThumbnailSize', uint16(size(in8bit)/2));
end



end



