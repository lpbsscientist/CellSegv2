function [out] = extractFluorescence(filename, r, z, c)
% Extracts TOTAL fluorescence of cells over time at a given region r,
% z-position z and channel c. filename has to be the name of a file created
% using cellSeg2.

file = matfile(filename);
fluoInfo = file.cellFluo;

size_all = size(fluoInfo);
size_t = size_all(3);

maxcells = 0;
for t=1:size_t
    nbcells = length(fluoInfo{r,z,t,c});
    if nbcells > maxcells
        maxcells = nbcells;
    end
end

out = zeros(maxcells, size_t);

for t=1:size_t
    fluoVec = fluoInfo{r,z,t,c};
    nbcells = length(fluoVec);
    out(:,t) = [fluoVec; zeros(maxcells-nbcells, 1)];    
end

end