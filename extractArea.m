function [out] = extractArea(filename, r, z, c)
% Extracts total area of cells over time at a given region r,
% z-position z and channel c. filename has to be the name of a file created
% using cellSeg2.

file = matfile(filename);
areaInfo = file.cellArea;

size_all = size(areaInfo);
size_t = size_all(3);

maxcells = 0;
for t=1:size_t
    nbcells = length(areaInfo{r,z,t,c});
    if nbcells > maxcells
        maxcells = nbcells;
    end
end

out = zeros(maxcells, size_t);

for t=1:size_t
    areaVec = areaInfo{r,z,t,c};
    nbcells = length(areaVec);
    out(:,t) = [areaVec, zeros(maxcells-nbcells, 1)];    
end

end