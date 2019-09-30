function res = fixBorderWidth(seg, width)
% Allows to set the width of the border between two cells. Takes as input a
% segmented image as output by cellWatershedGUI3, and outputs the image
% with borders set to the user defined width. As a preprocessing step, the
% borders that run through a single cell (such as when two cells are
% merged) are removed. 

% Close operation on every cell with strel of size one, to remove borders
% that go through cell body
% Do this in blocks of 200x200 (maximum speed)
res = blockproc(seg, [200, 200], @(x) inner(x));

% Make borders wider by performing dilate with strel of size width
se = strel('disk', floor(width/2));
bg = res==0;
dilated = imdilate(bg, se);
res(dilated) = 0;

end


function res = inner(block)
seg = block.data;
res = seg;
cells = unique(seg);
cells = cells(cells>0);
for cell=cells'
    mask = seg==cell;
    se = strel('disk', 1);
    closed = imclose(mask, se);
    res(closed) = cell;
end
end
