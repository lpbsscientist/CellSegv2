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


allCurrCells = unique(curr)';
allPrevCells = unique(prev)';

% Convert to categorical for getting counts
catPrev = categorical(prev);
catAllPrevCells = categorical(allPrevCells);

% Obtain for every cell in the curr frame the cell in the previous frame
% which has the most area in common
corresp = zeros(max(allCurrCells), 1);
allMaxCounts = zeros(max(allCurrCells), 1);
for cell = allCurrCells
    % Disregard bg and border
    if cell <= 0
        continue
    end
    
    % Get number of counts 
    counts = histcounts(catPrev(curr==cell), catAllPrevCells); 
    [maxCounts, maxCountIx] = max(counts);
    
    % Check if new cell (i.e. matches to background), set it to max+1
    corr = allPrevCells(maxCountIx);
    if corr <= 0
        corresp(cell) = max([allPrevCells, corresp']) + 1;
    else
        corresp(cell) = corr;
    end
    
    % commenting the above snippet creates a memory of background
    % corresp(cell) = corr;
    allMaxCounts(cell) = maxCounts;
end


% Change the current values of cells
mask = curr;
for cell = allCurrCells
    % Disregard bg and border
    if cell <= 0
        continue
    end

    mask(curr==cell) = corresp(cell);
end

end