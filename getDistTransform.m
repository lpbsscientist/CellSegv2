function dtr = getDistTransform(bf, param)
% .blur     (default: 3) Determines blur of gaussian filter on brightfield
%           image
% .erode    (default: 2) Radius of erode operation, removes small noise
% .dilate   (default: 4) Adds to thresholded image, make sure we have the
%           entire border
% .close    (default: 6) Parameter of close operation, to connect almost
%           closed borders

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

% Distance transform
dtr = bwdist(border);
