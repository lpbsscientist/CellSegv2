function [mask] = getBackgroundGUI(fluo, firstfluo, param, demo)
% Identifies regions which we are sure to be background. Requires
% fluorescence image where cells exhibit a lot of background fluorescence
% and cell bodies can be distinguished from the background by eye. 
% param contains all parameters for the conducted image processing
% operations. Demo specifies whether to create a figure of intermediary
% results.
%
% Parameters (elements of param struct):
% .smoothing    (default: 5) Large smoothing parameter of fluorescent image
% .dilate       (default: 10) Dilation operation parameter, to be sure to
%               capture only background

if nargin<4
    demo=0;
end

smoothed = imgaussfilt(fluo, param.smoothing);
vignette = imgaussfilt(firstfluo, param.smoothing * 100);
corrected = int32(smoothed) - int32(vignette);
positive = int16(corrected - min(corrected, [], 'all'));

% Get otsu threshold
gfpcounts = imhist(positive, 2^16);
gfpotsu = otsuthresh(gfpcounts);

% Binarize and dilate
bin = imbinarize(positive, gfpotsu);
%mask = ~imdilate(bin, strel('disk', param.dilate));
% Changed for BF
mask = ~imdilate(bin, strel('disk', param.dilate*10));

% If demo is activated, show intermediary images
if demo
    in8bit = uint8(rescale(fluo, 0, 255));

    figure
    montage({in8bit, bin, mask},...
            'ThumbnailSize', uint16(size(in8bit)/2));
end

end



