% The MIT License (MIT)
%
% Copyright (c) 2016 Ludovic Trottier
%
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.
%
%
% Load the Washington grasping rectangle dataset containing RGB and depth 
% information (as pcd files) into RGBD images.
%
% Author: Ludovic Trottier

function loadWashingtonRGBDDataset()

global opts

files = dir([opts.ufl.washingtonDataPath filesep '*.pcd']);

preprocFeatures = cell(1, length(files));
preprocMasks = cell(1, length(files));

for i = 1:length(files)
    filename = files(i).name(1:end-4);
    pcdFile = [opts.ufl.washingtonDataPath filesep filename '.pcd'];
    cropFile = [opts.ufl.washingtonDataPath filesep filename '_crop.png'];
    locFile = [opts.ufl.washingtonDataPath filesep filename '_loc.txt'];
    offset = load(locFile);
    
    I = graspPCDToRGBDImage(pcdFile, cropFile, offset);
    
    [curI,D,N,IMask,DMask] = getNewFeatFromRGBD( ...
        I(:,:,1:3), ...  % rgb
        I(:,:,4), ... % d
        ones(size(I,1), size(I,2)), ... % nothing is masked in the original image
        size(I,1), ... % number of row
        size(I,2), ... % number of column
        0, ... % do not invert depth values
        opts.grasp.depthStdCutoff, ... % outlier depth cutoff
        opts.grasp.maskThresh); % mask threshold after resize
    
    % Compute gray channel
    channelK = rgb2gray(curI);
    
    % Save vectorized features and masks
    preprocFeatures{i} = cat(3, channelK, curI, D, N);
    preprocMasks{i} = cat(3, IMask, DMask);
    
    %     figure
    %     subplot(1,2,1)
    %     imshow(I(:,:,1:3)./255)
    %     subplot(1,2,2)
    %     D = I(:,:,4);
    %     imshow((D - min(D(:))) ./ (max(D(:)) - min(D(:))))
    
end

save(opts.ufl.washingtonRGBDImages, 'preprocFeatures', 'preprocMasks');

end



