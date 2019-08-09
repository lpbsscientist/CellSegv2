function [rowi, coli] = pointsInCellGUI3(dtr, bgmask, param, demo)
% Using distance transform, determines points that lie within cells. Points
% that are within the background, as determined by bgmask, are excluded.
% param contains all necessary parameters for the image processing
% operations. demo specifies whether a plot with all intermediary steps
% should be created.
%
% Parameters (elements of param struct):
% .distsmooth (default: 2) Smooth distance transform, to avoid multiple 
%           maxima that are too close together. Allows for small
%           non-convexities.



if nargin < 4
    demo=0;
end

% Distance transform
smoothdisttr = imgaussfilt(dtr, param.distsmooth);

% Find maxima with minimal distance between them
hmaxtransf = imhmax(smoothdisttr, 2);
cellcenter = imregionalmax(hmaxtransf);

% Remove those points that are on background
cellcenter = cellcenter & ~bgmask;

% Return indices of centroids of minimal regions
cc = bwconncomp(cellcenter);
s = regionprops(cc, 'Centroid');
ncc = length(s);

rowi = zeros(ncc,1);
coli = zeros(ncc,1);
for i=1:ncc
    centr = s(i).Centroid;
    rowi(i) = int32(centr(2));
    coli(i) = int32(centr(1));
end

%[rowi, coli] = find(cellcenter);

% If demo is activated, show intermediary images
if demo
    in8bit = uint8(rescale(dtr, 0, 255));
    sdr_plot = uint8(smoothdisttr*10);

    figure
    montage({in8bit, threshed, eroded, dilated, border, sdr_plot},...
            'ThumbnailSize', uint16(size(in8bit)/2));
end

