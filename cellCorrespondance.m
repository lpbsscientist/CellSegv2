function [mask] = cellCorrespondance(prev, curr)
% Ensures that number between current and previous frame correspond
% Prev and curr are both masks obtained with cellWatershed


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
    
%     % Check if new cell (i.e. matches to background), set it to max+1
      corr = allPrevCells(maxCountIx);
%     if corr <= 0
%         corresp(cell) = max([allPrevCells, corresp']) + 1;
%     else
%         corresp(cell) = corr;
%     end
    % commenting the above snippet creates a memory of background
    corresp(cell) = corr;
    allMaxCounts(cell) = maxCounts;
end

% % Ensure one-to-one mapping
% for cell = allPrevCells
%      % Disregard bg and border
%     if cell <= 0
%         continue
%     end
% 
%     ix = find(corresp == cell);
%     
%     % Handle case that more than one map to the same previous cell
%     if length(ix) > 1
%         [~, maxix] = max(allMaxCounts(ix));
%         nomaxix = ix(ix ~= maxix);
%         
%         % Change those index that don't cover the maximal area of the
%         % previous cell to a new index
%         for i = nomaxix
%             corresp(i) = max(corresp) + 1;
%         end
%     end
%     
%     % Handle case that no cell maps to previous cell
%     if isempty(ix)
%         % TODO: What?
%     end
% end
%     
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