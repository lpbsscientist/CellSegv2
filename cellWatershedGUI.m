function [mask] = cellWatershedGUI(bf, gfp, ccRows, ccCols, param)



% Strels
surefg_strel = 'disk';
sureborder_strel = 'disk';
noartif_strel = 'disk';
border_strel = 'disk';
method = 'adaptive';
cellcenter_strel = 'disk';


% Algorithm
% Binarize gfp and bf image
gfpBl = imgaussfilt(gfp, param.gfp_sigma);
bingfp = imbinarize(gfpBl, method);
bfBl = imgaussfilt(bf, param.bf_sigma);

binbf = imbinarize(bfBl, method);


% Get masks without artifacts 
noartifacts = imdilate(bingfp, strel(noartif_strel, param.noartif_dilate));
binbf_noA = and(binbf, noartifacts);

% Identify border and sure background
border = imerode(binbf_noA, strel(border_strel, param.border_erode));

surefg = imdilate(bingfp, strel(surefg_strel, param.surefg_dilate));
sureborder = imdilate(border, strel(sureborder_strel, param.sureborder_dilate));

surebg = ~(surefg | sureborder);

% Get cellcenter mask
imsize = size(bf);
cellcenter = zeros(imsize(1), imsize(2));

for i = 1:length(ccRows)
    cellcenter(ccRows(i), ccCols(i)) = 1;
end
cellcenter_dil = imdilate(cellcenter, strel(cellcenter_strel, param.cellcenter_dilate));

% Run watershed on smoothed brightfield / phase contrast image
smooth_bf = imgaussfilt(bf, param.bf_smoothing);
toshed_bf = imimposemin(smooth_bf, surebg | cellcenter_dil);
mask = watershed(toshed_bf);


% Set value of background to -1
bgmask = mask(surebg);
bgval = bgmask(1);
mask(mask==bgval) = -1;

end
