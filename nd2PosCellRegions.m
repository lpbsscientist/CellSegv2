function [rects] = nd2PosCellRegions(file, pos, colToUse, ...
                                     margin, threshFactor)
% Function that returns rectangles of interesting regions for a given
% position. 
%
% rects = nd2PosCellRegions(file, pos, colToUse, threshFactor)
% returns a Matlab cell of rectangles that bound all cell-containing
% regions of the position. Individual rectangles are returned as vectors as
% follows: [x, y, width, height], where x, y marks the indices of the 
% top-left corner.
%
% Parameters:
% (note that all optional values can be set to default by giving [] as input)
% file              Path to nd2 file containing images, or initialized
%                   bfopen reader
% pos               Index of position (1-based indexing)
% colToUse          Color channels to use for cell detection (vector)
% margin            Margin to be added around every interesting region,
%                   single value or vector of values for every color in
%                   colToUse. Default set to zero.
% threshFactor      Threshold for detection of interesting region, either
%                   single value or vector of values for every color in 
%                   colToUse. Default value set to 1.
% 
% Detailed methodology is given at the end of the script.

% Set default values
if nargin < 4 || isempty(margin)
    margin = 0;
end
if nargin < 5 || isempty(threshFactor)
    threshFactor = 3;
end

% Convert margin and threshFactor to vector if int given
if isscalar(margin)
    margin = margin * ones(length(colToUse), 1);
end
if isscalar(threshFactor)
    threshFactor = threshFactor * ones(length(colToUse), 1);
end

if isa(file, 'char')
    % Create reader object if input is string
    reader = bfGetReader(file);
elseif isa(file, 'loci.formats.ChannelSeparator')
    % Set reader to be input if file is a reader
    reader = file;
end


% Verification of input
if pos > reader.getSeriesCount()
    error(['Error: Position %i does not exist, only %i positions avaliable.\n' ...
           'Note that position uses 1-based indexing.'], ...
          pos, reader.getSeriesCount())
end

% Define which position to use
reader.setSeries(pos-1)

% Iterate through z positions
sizeZ = reader.getSizeZ;
Zmasks = cell(sizeZ, 1);
for iZ = 1:sizeZ
    Cmasks = cell(length(colToUse), 1);
    for j = 1:length(colToUse)
        iC = colToUse(j);
        firstIx = reader.getIndex(iZ-1, iC-1, 0) + 1;
        lastIx = reader.getIndex(iZ-1, iC-1, reader.getSizeT-1) + 1;
        
        % Get cell containing region on last image, using first image as
        % reference
        Cmasks{j} = findInterestRegions(bfGetPlane(reader, lastIx), ...
                                        bfGetPlane(reader, firstIx), ...
                                        margin(j), threshFactor(j));
    end
    
    % Combine color masks with logical and
    Zmasks{iZ} = flatMasks(Cmasks, @and);
end

% Combine Z masks with logical or
finalMask = flatMasks(Zmasks, @or);

% Draw bounding rectangles on final mask
rects = boundingRects(finalMask, 0);

% Close reader if input is file name
if isa(file, 'char')
    reader.close()
end

end

%--------------------------------------------------------------------------
function [mask] = flatMasks(masks, combiner)
% Takes as input a cell of masks, flattens it using the
% combiner function specified by the function handle 'combiner'. Typical
% combiners are @and or @or
mask = masks{1};
for i = 2:length(masks)
    mask = combiner(mask, masks{i});
end
end

%--------------------------------------------------------------------------
function [rects] = boundingRects(binaryImg, margin)
% Takes binary input image, identifies connected components, then draws a
% bounding rectangle around every connected component. Then for every
% connected component it returns a mask of the size of the original image
% where the rectangle is indicated. 
% If margin input is specified, adds a margin of the specified amount of
% pixels around the rectangle

% Set margin to 0 if not specified.
if nargin == 1 || isempty(margin)
    margin = 0;
end

% Identify connected components and their bounding box
cc = bwconncomp(binaryImg);
boundbox = regionprops(cc, 'BoundingBox');

% Create mask for every bounding rectangle
rects = cell(length(boundbox), 1); %allocate memory
for i = 1:length(boundbox)
    theBox = boundbox(i).BoundingBox;
    
    x = int32(floor(theBox(1) - margin));
    y = int32(floor(theBox(2) - margin));
    w = int32(ceil(theBox(3) + 2*margin));
    h = int32(ceil(theBox(4) + 2*margin));
    rects{i} = constrainRect([x, y, w, h], size(binaryImg));
end

end

%--------------------------------------------------------------------------
function [out] = constrainRect(in, imgSize)
% Constrains input rectangle to lie within the image.
% inputRect and output format: [x, y, w, h], where x,y are indices of
% top-left corner

imgHeight = imgSize(1);
imgWidth = imgSize(2);

top = in(2);
bottom = in(2) + in(4) - 1;
left = in(1);
right = in(1) + in(3) - 1;

top = max(1, top);
bottom = min(imgHeight, bottom);
left = max(1, left);
right = min(imgWidth, right);

height = bottom - top + 1;
width = right - left + 1;

out = [left, top, width, height];
end

%--------------------------------------------------------------------------
function [mask] = findInterestRegions(img, refimg, margin, threshFactor)
% FINDINTERESTREGIONS
% Takes input image img, returns an image mask that draws rectangles
% around regions from the image that contain a signal.
% Optionally takes reference image as input, based on which the image
% statistics (mode and standard deviation) will be calculated.

% Set default values if not provided
if nargin < 4 || isempty(threshFactor)
    threshFactor = 1;
end
if nargin < 3 || isempty(margin)
    margin = 10;
end
if nargin < 2 || isempty(refimg)
    refimg = img;
end

% Normalize image using mode and standard deviation
imgMode = mode(refimg, 'all');
imgStd = std(double(refimg), 0, 'all');
normImg = (img - imgMode)/imgStd;

% Threshold image, retain only pixels that deviate by more than
% (threshFactor * standard deviation) from the image mean
thresh = abs(normImg) >= threshFactor;

% Erode with diamond kernel to remove single, unconnected 
% signal points
eroded = imerode(thresh, strel('diamond', 2));

% Dilate with diamond kernel, to make components connected
dilated = imdilate(eroded, strel('diamond', 50));

% Return individual masks of bounding rectangles
rects = boundingRects(dilated, margin);
indivMasks = cell(length(rects), 1);
for i = 1:length(rects)
    indivMasks{i} = rectToMask(size(img), rects{i});
end

mask = flatMasks(indivMasks, @or);
end

%--------------------------------------------------------------------------
function [mask] = rectToMask(imgSize, rect)
% Converts rectangle to image mask
top = rect(2);
bottom = rect(2) + rect(4) - 1;
left = rect(1);
right = rect(1) + rect(3) - 1;

mask = zeros(imgSize);
mask(top:bottom, left:right) = 1;
end

%--------------------------------------------------------------------------
% METHODOLOGY
%
% LOADING THE IMAGES:
% In order to save memory and for faster loading, the method does not load
% the entire nd2 file into memory. Instead, it uses a reader object, as
% obtained by the function bfGetReader of the bfopen MATLAB toolbox. This
% allows to obtain the images seperately. By construction of the reader
% object, one has to set the reader to the series before accessing the
% image itself. The series corresponds in this case to the position on the
% microscope, where the image was taken. Then, individual images can be
% accessed using the function bfGetPlane(reader, index). The index itself
% can be obtained using the function reader.getIndex(z, c, t). Note that
% the getIndex method uses zero-based indexing and returns a zero-based
% index, while the index of bfGetPlane is 1-based.
%
%
% IDENTIFYING CELLS ON GIVEN COLOR CHANNEL AND Z STACK:
% (as done in the function findInterestRegions)
% The following is done for every Z stack and every color channel: On the
% first image taken for a given color channel and z stack, we calculate the 
% mode and the standard deviation of the image. Then, on the last image we
% identify pixels that deviate more than by a given threshold factor times
% the previously calculated standard deviation from the mode. Those pixels
% are thresholded to obtain a binary image.
% 
% This binary image is then filtered using first an erode operation with a
% small-sized (radius = 2) diamond kernel, in order to remove small single
% pixels that correspond to stochastic noise. Then, we perform a dilate
% operation with a large-sized (radius = 50) diamond kernel to ensure that
% neighboring cells are connected. On the resulting binary image, we
% identify connected components and then draw a bounding box around them. 
% To this bounding box we add a margin on every side, in order to ensure to
% not loose any cell pixels on the boundary. However, note that already the
% filtering with the large-sized kernel adds some safety margin. 
%
% For every rectangle found in that way, we create a binary image mask
% where all pixels contained within the rectangle take value 1, and all
% pixels outside of the rectangle take value 0. The resulting masks (one
% for every rectangle) are then combined by using the logical or operator,
% yielding a single mask of interesting regions for a given color channel
% and z stack.
%
% 
% MASK REDUCTION
% Having obtained a mask for every color channel and z stack, we now have
% to combine this information to yield one single mask for the input
% position. This is done as follows: Color channel masks are reduced using 
% a logical and operation, based on the heuristic that cells will have
% background fluorescence on every color channel. By using different color
% channels, one can therefore reduce the effects of artifacts in the
% microscopy image of a single fluorescence channel. Meanwhile, Z stacks
% are reduced using a logical or operation. This is in order to ensure that
% all pixels on which something interesting is detected at some Z stacks
% are retained. 
% 
%
% THE OUTPUT
% Having done the reduction of the masks, we again draw rectangles around
% the connected components of the mask. These rectangles will then define 
% the final crops and are returned as an output of the function.

