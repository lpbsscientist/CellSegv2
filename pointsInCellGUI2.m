function [rowi, coli] = pointsInCellGUI2(bf, bgmask, param, demo)
% Using brightfield image, determines points that lie within cells. Points
% that are within the background, as determined by bgmask, are excluded.
% param contains all necessary parameters for the image processing
% operations. demo specifies whether a plot with all intermediary steps
% should be created.
%
% Parameters (elements of param struct):
% .blur     (default: 3) Determines blur of gaussian filter on brightfield
%           image
% .erode    (default: 2) Radius of erode operation, removes small noise
% .dilate   (default: 4) Adds to thresholded image, make sure we have the
%           entire border
% .close    (default: 6) Parameter of close operation, to connect almost
%           closed borders
% .distsmooth (default: 2) Smooth distance transform, to avoid multiple 
%           maxima that are too close together. Allows for small
%           non-convexities.



if nargin < 4
    demo=0;
end

% Filtering
blurred = imgaussfilt(bf, param.blur);

% Thresholding
counts = imhist(bf, 2^16);
otsu = otsuthresh(counts);
threshed = imbinarize(blurred, otsu);

% Erode, dilate and close to identify border
eroded = imerode(threshed, strel('disk', param.erode));
dilated = imdilate(eroded, strel('disk', param.dilate));
border = imclose(dilated, strel('disk', param.close));

disttr = bwdist(border);
smoothdisttr = imgaussfilt(disttr, param.distsmooth);

% Distance transform
cellcenter = imregionalmax(smoothdisttr);

% Remove those points that are on background
cellcenter = cellcenter & ~bgmask;

% Return indices of cell centers
[rowi, coli] = find(cellcenter);

% If demo is activated, show intermediary images
if demo
    in8bit = uint8(rescale(bf, 0, 255));
    sdr_plot = uint8(smoothdisttr*10);

    figure
    montage({in8bit, threshed, eroded, dilated, border, sdr_plot},...
            'ThumbnailSize', uint16(size(in8bit)/2));
end

