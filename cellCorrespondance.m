function [mask] = cellCorrespondance(prev, curr)
% Ensures that number between current and previous frame correspond
% Prev and curr are both masks obtained with cellWatershed
%
% For every cell in the current frame, looks at to which cells its pixels
% belonged in the previous frame. Then it takes the cell id with the
% largest amount of pixels in common to be the cell number.
%
% Exception to this:
% If a cell is determined to be background, it is considered
% as a new cell and given a new id. 

% Notes for improvement: By far the most time is spent on getting the
% counts. Could be made faster by subsampling the map.

map = [prev(:), curr(:)];
[unique_rows,~,ix] = unique(map, 'rows');
counts = histcounts(categorical(ix), categorical(1:max(ix)));

% Group by current cell, find cell from previous with the largest overlap
[g, oldval] = findgroups(unique_rows(:,2));
newval = splitapply(@inner, counts', unique_rows(:,1), g);

% When the new value is zero, create a new cell
new_is_zero = find(newval==0);
new_ix = max(newval) + 1;
for cell=new_is_zero'
    if oldval(cell)==0
        % Leave background as background
        continue
    end
    newval(cell)=new_ix;
    new_ix = new_ix+1;
end

% Exchange values in curr to form final mask using a lookup table, where
% entry n+1 specifies the new value corresponding to the old value n.
lookup = zeros(max(oldval+1),1);
lookup(oldval+1) = newval;
mask = lookup(curr+1);

end


function out = inner(c, v)
% Takes counts and values, returns value with highest count
[~, maxix] = max(c);
out = v(maxix);
end
