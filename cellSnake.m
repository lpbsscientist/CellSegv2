function newMask = cellSnake(im, mask, nb)

% BASIS VERSION, POOR PERFORMANCE
% % TODO: Get largest connected component
% sm = imgaussfilt(imcomplement(im), 1);
% newCell = activecontour(sm, mask==nb, 10);
% 
% % Set old cell shape to background, then new cell mask to the number
% newMask = mask;
% newMask(newMask==nb)=0;
% newMask(newCell)=nb;


% Get derivatives
im = imgaussfilt(double(im), 1);

dx = diff(double(im), 1, 1);
dy = diff(double(im), 1, 2);

% Approximate centroid using 25 randomly sampled pixels of the segment
linidx = find(mask==nb);
sampleidx = randsample(linidx, 25, true);
[rowi, coli] = ind2sub(size(mask), sampleidx);
centr_x = mean(coli);
centr_y = mean(rowi);

% Get mask of pixels which we look at
roi = mask==nb;
roi = logical(imdilate(roi, strel('octagon', 6)) - imerode(roi, strel('octagon', 6)));

% Get polar coordinates and radial derivative values for all pixels in roi
roi_li = find(roi);
[yix, xix] = ind2sub(size(roi), roi_li);
relpos_x = xix - centr_x;
relpos_y = yix - centr_y;
r = sqrt(relpos_x.^2 + relpos_y.^2);

sin_th = relpos_y ./ r;
cos_th = relpos_x ./ r;

dr = cos_th .* double(dx(roi)) + sin_th .* double(dy(roi));

th = asin(sin_th);
th(relpos_x<0) = -th(relpos_x<0) + pi;
th = wrapTo2Pi(th);

% Group into sectors, find max of every sector
nsectors = 36;
sector = int16(ceil(th*nsectors/2/pi));
sect_max = splitapply(@find_max_coord, dr, xix, yix, sector);

% Get resulting polygon
imsize = size(im);
%posmax = sect_max(:,1)>0;
newcell = poly2mask(sect_max(:,2), sect_max(:,3), imsize(1), imsize(2));

% Change mask
newMask = mask;
newMask(newMask==nb)=0;
newMask(newcell)=nb;



end

function out = find_max_coord(val, x, y)
[mval, ix] = max(val);
mx = x(ix);
my = y(ix);
out = [mval, mx, my];
end

