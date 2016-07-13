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
% Extract patches from Washington dataset.
%
% Author: Ludovic Trottier

function [washingtonPatches, washingtonMasks] = extractPatchesFromWashingtonRGBD()

global opts

if opts.util.verbose; fprintf('Adding patches from Washington dataset.\n'); end

rfSize = opts.ufl.rfSize;

% gather patches from the training images
washingtonPatches = zeros(opts.ufl.nWashingtonRGBDPatches, rfSize*rfSize*8);
washingtonMasks = zeros(opts.ufl.nWashingtonRGBDPatches, rfSize*rfSize*8);

% load washington dataset
load(opts.ufl.washingtonRGBDImages, 'preprocFeatures', 'preprocMasks');
N = length(preprocFeatures);

% randomly traverse the data
rperm = randperm(opts.ufl.nWashingtonRGBDPatches);
for it = 1:opts.ufl.nWashingtonRGBDPatches
    if (mod(it,10000) == 0), fprintf('Extracting patches: %d / %d\n', it, opts.ufl.nPatches); end
    % get the position of the image
    i = mod(rperm(it)-1,N)+1;
    I = preprocFeatures{i};
    M = preprocMasks{i};
    imgSize = size(I);
    % a patch is accepted if it has less than 100*opts.ufl.maskedNotMaskedRatio percent masked values.
    first = true;
    stopCondition = false;
    while stopCondition || first
        % hack for simulating a do-while
        first = false;
        % randomly select the row and column of the patch
        row = randi(imgSize(1) - rfSize + 1);
        col = randi(imgSize(2) - rfSize + 1);
        % compute the mask
        mask = M(row:row+rfSize-1, col:col+rfSize-1, :);
        % verify if it does not have too much masked values
        stopCondition = sum(sum(mask(:,:,2))) ./ numel(mask) < opts.ufl.maskedNotMaskedRatio;
    end
    % compute the patch
    patch = I(row:row+rfSize-1, col:col+rfSize-1, :);
    % keep the patch and its mask
    washingtonPatches(it,:) = patch(:);
    repmask = cat(3, repmat(mask(:,:,1), 1, 1, 4), repmat(mask(:,:,2), 1, 1, 4));
    washingtonMasks(it,:) = repmask(:);
    
end

end
