function [mask] = cellWatershedGUI3(bf, bgmask, dtr, ccRows, ccCols, param, demo)
% Performs watershed segmentation based on the brightfield image. Uses the
% background determined by bgmask as well as the cell points indexed by
% ccRows and ccCols as seeds for algorithm. param is a struct with the
% necessary parameters. demo specifies whether a figure with intermediary
% results should be created.
%
% Parameters (elements of param struct):
% smooth            (default: 2) Radius of gaussian blur to be applied to 
%                   bright field image.
% center_dilate     (default: 2) Radius of circle to be drawn around every
%                   cell center before using it as seed for watershed

if nargin < 7
    demo=0;
end


% Get cellcenter mask
imsize = size(bf);
cellcenter = zeros(imsize(1), imsize(2));

for i = 1:length(ccRows)
    cellcenter(ccRows(i), ccCols(i)) = 1;
end
cellcenter_dil = imdilate(cellcenter, strel('disk', param.center_dilate));

% Subtract distance transform from brightfield to get watershed topology
topo = single(bf);
topo(~bgmask) = topo(~bgmask) - 20*dtr(~bgmask);

% Smooth topology, run watershet
smooth_bf = imgaussfilt(topo, param.smooth);
toshed_bf = imimposemin(smooth_bf, bgmask | cellcenter_dil);
mask = uint16(watershed(toshed_bf));

% Set value of background to -1
tmp = mask(bgmask);
bgvals = unique(tmp);
for val=bgvals'
    mask(mask==val) = 0;
end

% If demo is activated, show image and seeds
if demo
    in8bit = uint8(rescale(bf, 0, 255));
    figure
    montage({in8bit, bgmask | cellcenter_dil});
end

end
