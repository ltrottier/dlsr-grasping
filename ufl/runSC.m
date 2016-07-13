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
% Perform sparse coding optimization.
%
% Author: Ludovic Trottier

function [ F ] = runSC(dictionary, patches, masks)

global opts

if strcmp(opts.ufl.scMethod, 'kmeans-tri') 
    % compute 'triangle' activation function
    xx = sum(patches.^2, 2);
    cc = sum(dictionary.^2, 2)';
    xc = patches * dictionary';
    z = sqrt( bsxfun(@plus, cc, bsxfun(@minus, xx, 2*xc)) ); % distances
    mu = mean(z, 2); % average distance to centroids for each patch
    F = max(bsxfun(@minus, mu, z), 0);

elseif strcmp(opts.ufl.scMethod, 'soft-threshold')
    
    F = wthresh(patches * dictionary', 's', opts.ufl.scLambda);
    
elseif strcmp(opts.ufl.scMethod, 'lasso')
    
    param.lambda = opts.ufl.scLambda;
    param.numThreads = opts.ufl.numThreads; 
    param.mode = 2;
    param.verbose = false;
    
    if opts.ufl.scUseMask
        F = full(mexLassoMask(patches',dictionary', logical(masks)', param))';
    else
        F = full(mexLasso(patches',dictionary', param))';
    end
    
elseif strcmp(opts.ufl.scMethod, 'omp')
    
    param.L = opts.ufl.scLambda;
    param.numThreads = opts.ufl.numThreads; 
    param.verbose = false;
    
    if opts.ufl.scUseMask
        F = full(mexOMPMask(patches',dictionary', logical(masks)', param))';
    else
        F = full(mexOMP(patches',dictionary', param))';
    end
end

if opts.ufl.splitPolarities
    neg = F < 0;
    Fpos = F;
    Fpos(neg) = 0;
    Fneg = F;
    Fneg(~neg) = 0;
    Fneg = -Fneg;
    F = [Fpos Fneg];
end

end

