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
% Convolutional extraction with spatial pyramid pooling.
%
% Author: Ludovic Trottier

function [ F ] = extractUFLFeatures( dictionary, preprocFeatures, preprocMasks, zcaWhitenParameters )

global opts

if opts.util.verbose; fprintf('Extracting features...\n'); end

N = size(preprocFeatures,1);
imgDim = [opts.grasp.imgSize opts.grasp.imgSize 8];
maskDim = [opts.grasp.imgSize opts.grasp.imgSize 2];
rfSize = opts.ufl.rfSize;
nAtoms = opts.ufl.nAtoms * (1 + opts.ufl.splitPolarities);
F = zeros(N, nAtoms*4);

% ZCA whitening (with low-pass) of all patches
if opts.ufl.zcaWhiten
    P = zcaWhitenParameters.P;
    M = zcaWhitenParameters.M;
end

for i = 1:N
    if opts.util.verbose && (mod(i,1000) == 0); fprintf(' it %d / %d\n', i, N); end

    % Extract all patches from the image
    img = reshape(preprocFeatures(i,:), imgDim);
    patches = im2colstep(img, [rfSize rfSize imgDim(3)])';
    
    % Extract the masks of all patches
    mask = reshape(preprocMasks(i,:), maskDim);
    masks = logical(im2colstep(double(cat(3, repmat(mask(:,:,1), 1, 1, 4), repmat(mask(:,:,2), 1, 1, 4))), [rfSize rfSize imgDim(3)]))';

    % whiten each channel k/rgb/d/n individually of each patch individually (for rgb, this corresponds to contrast normalization)
    caseWiseWhiten_k_rgb_d_n
    
    % zca whitening
    if opts.ufl.zcaWhiten
        patches = bsxfun(@minus, patches, M) * P;
    end
    
    % Remask the hole thing
    patches = patches .* masks;
    
    % Apply sparse coding to the patches
    curF = runSC(dictionary, patches, masks);
    
    % reshape to nAtoms-channel image
    prows = imgDim(1)-rfSize+1;
    pcols = imgDim(2)-rfSize+1;
    curF = reshape(curF, prows, pcols, nAtoms);
    
    % pool over quadrants and concatenate
    F(i, :) = quadrantPooling(curF);
    
end

if opts.util.verbose; fprintf('Extracting features done.\n'); end