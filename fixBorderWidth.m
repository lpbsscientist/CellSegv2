function res = fixBorderWidth(seg, width)

res = seg;

% Close operation on every cell with strel of size one, to remove borders
% that go through cell body
cells = unique(seg);
for cell=cells'
    mask = seg==cell;
    se = strel('disk', 1);
    closed = imclose(mask, se);
    res(closed) = cell;
end

% Make borders wider by performing dilate with strel of size width
se = strel('disk', floor(width/2));
bg = res==0;
dilated = imdilate(bg, se);
res(dilated) = 0;

end