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
% Get new features from all RGBD.
% Apply simple preprocessing (resizing and removing outlier depth values).
%
% Author: Ludovic Trottier

function [preprocFeatures, preprocMasks] = getNewFeatFromAllRGBD(graspRectImgs)


global opts

if opts.util.verbose
    fprintf('Pre-processing images...\n')
    pause(2)
end

% N = sum(cellfun(@(x)(length(x)), graspRectImgs));
preprocFeatures = {};
preprocMasks = {};

for i = 1:length(graspRectImgs)
    for j = 1:length(graspRectImgs{i})
        [curI,D,N,IMask,DMask] = getNewFeatFromRGBD( ...
            graspRectImgs{i}{j}(:,:,1:3), ...  % rgb
            graspRectImgs{i}{j}(:,:,4), ... % d
            ones(size(graspRectImgs{i}{j},1), size(graspRectImgs{i}{j},2)), ... % nothing is masked in the original image
            opts.grasp.imgSize, ... % number of row
            opts.grasp.imgSize, ... % number of column
            0, ... % do not invert depth values
            opts.grasp.depthStdCutoff, ... % outlier depth cutoff
            opts.grasp.maskThresh); % mask threshold after resize
        
        % Compute gray channel
        channelK = rgb2gray(curI);
        
        % Save vectorized features and masks
        preprocFeatures{i}{j} = [channelK(:)' curI(:)' D(:)' N(:)'];
        preprocMasks{i}{j} = [IMask(:)' DMask(:)'];
    end
    
    if opts.util.verbose && (mod(i,1) == 0)
        fprintf(' it %d of %d \n', i, length(graspRectImgs));
    end
end

if opts.util.verbose
    fprintf('Pre-processing images done.\n');
end

end

