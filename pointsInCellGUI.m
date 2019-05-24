function [rowi, coli] = pointsInCellGUI(bf, gfp, param)
% Documentation
%
%

noartif_strel = 'disk';
intracell_strel = 'disk';
border_strel = 'disk';
method = 'adaptive';

% Filtering
gfpBl = imgaussfilt(gfp, param.gfp_sigma);
bfBl = imgaussfilt(bf, param.bf_sigma);

% Thresholding
bingfp = imbinarize(gfpBl, param.gfpThresh);
binbf = imbinarize(bfBl, param.bfThresh);

% Remove BF artifacts
noartif_eroded = imerode(bingfp, strel(noartif_strel, param.noartif_erode));
noartifacts = imdilate(noartif_eroded, strel(noartif_strel, param.noartif_dilate));
binbf_noA = and(binbf, noartifacts);

% Identify intracellular regions
dilated_gfp = imdilate(bingfp, strel(intracell_strel, param.intracell_dilate));
border = imerode(binbf_noA, strel(border_strel, param.border_erode));
intracellular = and(dilated_gfp, ~border);

% Distance transform
disttr = bwdist(~intracellular);
smoothdisttr = imgaussfilt(disttr, param.disttr_sigma);
cellcenter = imregionalmax(smoothdisttr);

% Return indices of cell centers
[rowi, coli] = find(cellcenter);
