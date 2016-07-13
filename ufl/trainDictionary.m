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
% Randomly sample patches from the dataset, then train a dictionary.
%
% Author: Ludovic Trottier

function [ dictionary, zcaWhitenParameters ] = trainDictionary(preprocFeatures, preprocMasks)

global opts

if opts.util.verbose; fprintf('Training dictionary using %s.\n', opts.ufl.dlMethod); end

rfSize = opts.ufl.rfSize;
[N, dim] = size(preprocFeatures);

imgSize = opts.grasp.imgSize;
% gather patches from the training images
patches = zeros(opts.ufl.nPatches, rfSize*rfSize*8);
masks = zeros(opts.ufl.nPatches, rfSize*rfSize*8);

% randomly traverse the data
rperm = randperm(opts.ufl.nPatches);
for it = 1:opts.ufl.nPatches
    if opts.util.verbose
        if (mod(it,10000) == 0) fprintf('Extracting patches: %d / %d\n', it, opts.ufl.nPatches); end
    end
    % get the position of the image
    i = mod(rperm(it)-1,N)+1;
    % a patch is accepted if it has less than 100*opts.ufl.maskedNotMaskedRatio percent masked values.
    first = true;
    stopCondition = false;
    while stopCondition || first
        % hack for simulating a do-while
        first = false;
        % randomly select the row and column of the patch
        row = randi(imgSize - rfSize + 1);
        col = randi(imgSize - rfSize + 1);
        % compute the mask
        mask = reshape(preprocMasks(i,:), imgSize, imgSize, 2);
        mask = mask(row:row+rfSize-1, col:col+rfSize-1, :);
        % verify if it does not have too much masked values
        stopCondition = sum(mask(:)) ./ numel(mask) < opts.ufl.maskedNotMaskedRatio;
    end
    % compute the patch
    patch = reshape(preprocFeatures(i,:), imgSize, imgSize, 8);
    patch = patch(row:row+rfSize-1, col:col+rfSize-1, :);
    % keep the patch and its mask
    patches(it,:) = patch(:);
    
    repmask = cat(3, repmat(mask(:,:,1), 1, 1, 4), repmat(mask(:,:,2), 1, 1, 4));
    masks(it,:) = repmask(:);
    
end

if opts.util.verbose; fprintf('Extracting patches done.\n'); end

if opts.ufl.addWashingtonRGBDPatches
    [washingtonPatches, washingtonMasks] = extractPatchesFromWashingtonRGBD();
    patches = cat(1, patches, washingtonPatches);
    masks = cat(1, masks, washingtonMasks);
end

% whiten each channel k/rgb/d/n individually of each patch individually (for rgb, this corresponds to contrast normalization)
caseWiseWhiten_k_rgb_d_n

% ZCA whitening (with low-pass) of all patches
if opts.ufl.zcaWhiten
    patches(~masks) = NaN;
    C = nancov(patches);
    M = nanmean(patches);
    [V,D] = eig(C);
    P = V * diag(sqrt(1./(diag(D) + 0.1))) * V';
    patches(~masks) = 0;
    patches = bsxfun(@minus, patches, M) * P;
    zcaWhitenParameters.P = P;
    zcaWhitenParameters.M = M;
else
    zcaWhitenParameters = [];
end

% Remask the hole thing
patches = patches .* masks;

% run the chosen dictionary learning approach
dictionary = runDL(patches);


end