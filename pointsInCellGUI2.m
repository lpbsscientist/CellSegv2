function [rowi, coli] = pointsInCellGUI2(bf, bgmask, param)
% Documentation
%
% erode=2, dilate=4, close=6, blur=3, distsmooth = 2
% bfcounts = imhist(bf, 2^16);
% bfotsu = otsuthresh(bfcounts);
% 

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
