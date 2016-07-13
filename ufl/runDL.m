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
% Dictionary learning optimization.
%
% Author: Ludovic Trottier

function [ dictionary ] = runDL( patches )

global opts

if opts.util.verbose; fprintf('Dictionary optimization...\n'); end

if strcmp(opts.ufl.dlMethod, 'kmeans')
    
    dictionary = runKMeans(patches, opts.ufl.nAtoms, opts.ufl.dlNEpochs, opts.ufl.dlBatchSize);
    
elseif strcmp(opts.ufl.dlMethod, 'nkmeans')
    
    dictionary = runKMeans(patches, opts.ufl.nAtoms, opts.ufl.dlNEpochs, opts.ufl.dlBatchSize);
    dictionary = bsxfun(@rdivide, dictionary, sqrt(sum(dictionary.^2,2)+1e-20));
    
elseif strcmp(opts.ufl.dlMethod, 'rp')
    
    dictionary = datasample(patches, opts.ufl.nAtoms, 'Replace', false);
    dictionary = bsxfun(@rdivide, dictionary, sqrt(sum(dictionary.^2,2)+1e-20));
    
elseif strcmp(opts.ufl.dlMethod, 'rand')
    
    dictionary = randn(opts.ufl.nAtoms, size(patches,2));
    dictionary = bsxfun(@rdivide, dictionary, sqrt(sum(dictionary.^2,2)+1e-20));
    
elseif strcmp(opts.ufl.dlMethod, 'gsvq')
    
    dictionary = runGSVQ(patches, opts.ufl.nAtoms, opts.ufl.dlNEpochs, opts.ufl.dlBatchSize);
    
elseif strcmp(opts.ufl.dlMethod, 'odl-lasso')
    
    param.mode = 2;
    param.batchsize = opts.ufl.dlBatchSize;
    param.iter = opts.ufl.dlNEpochs;
    param.numThreads = opts.ufl.numThreads;
    param.K = opts.ufl.nAtoms;
    param.lambda = opts.ufl.dlLambda;
    param.verbose = opts.util.verbose;

    dictionary = mexTrainDL(patches',param)';
    
elseif strcmp(opts.ufl.dlMethod, 'odl-omp')
    
    param.mode = 3;
    param.batchsize = opts.ufl.dlBatchSize;
    param.iter = opts.ufl.dlNEpochs;
    param.numThreads = opts.ufl.numThreads;
    param.K = opts.ufl.nAtoms;
    param.lambda = opts.ufl.dlLambda;
    param.verbose = opts.util.verbose;
    
    dictionary = mexTrainDL(patches',param)';
    
end

if opts.ufl.showDictionary
    rfSize = opts.ufl.rfSize;
    figure('units','normalized','outerposition',[0 0 1 1])
    subplot(1,4,1); imshow(displayPatches(dictionary(:,0*rfSize*rfSize+1 : 1*rfSize*rfSize)'), 'InitialMagnification', 'fit'); drawnow;
    subplot(1,4,2); imshow(displayPatches(dictionary(:,1*rfSize*rfSize+1 : 4*rfSize*rfSize)'), 'InitialMagnification', 'fit'); drawnow;
    subplot(1,4,3); imshow(displayPatches(dictionary(:,4*rfSize*rfSize+1 : 5*rfSize*rfSize)'), 'InitialMagnification', 'fit'); drawnow;
    subplot(1,4,4); imshow(displayPatches(dictionary(:,5*rfSize*rfSize+1 : 8*rfSize*rfSize)'), 'InitialMagnification', 'fit'); drawnow;
    tightfig;
    
    pause(1);
end

if opts.util.verbose; fprintf('Dictionary optimization done.\n'); end

end

