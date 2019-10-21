function [] = extractData(filename, outfile_mask, outfile_im, region)
% Function to extract segmentation masks and the corresponding nd2 frames
% simultaeously for a given region. The frames are saved in the tif files
% specified in outfile_mask and outfile_im (WHICH MUST HAVE ENDING .tif).
file = matfile(filename);

meta = file.meta;
imgfile = meta.imgfile;
rect = meta.rects{region};
pos = meta.posLookup(region);
bfchannel = meta.param.gen.bf_ch;

bfInitLogging('OFF');
reader = loci.formats.Memoizer(bfGetReader(), 0);
reader.setId(imgfile);
reader.setSeries(pos-1);
nt = reader.getSizeT;

firstwrite = true;
for t=1:nt
    maskCell = file.segMasks(region, 1, t);
    mask = maskCell{1,1};
    if isempty(mask)
        continue
    end
    
    disp("hello")
    
    ix = reader.getIndex(0, bfchannel-1, t-1) + 1;
    frame = bfGetPlane(reader, ix, rect(1), rect(2), rect(3), rect(4));
    
    if firstwrite
        imwrite(mask, outfile_mask)
        imwrite(frame, outfile_im)
        firstwrite=false;
    else
        imwrite(mask, outfile_mask, 'WriteMode', 'append')
        imwrite(frame, outfile_im, 'WriteMode','append')
    end
end

end