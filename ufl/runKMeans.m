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
% Perform KMeans optimization.
%
% Author: Ludovic Trottier

function centroids = runKMeans(X, k, iterations, batch_size)

global opts

centroids = randn(k,size(X,2))*0.1;

for itr = 1:iterations
    
    if opts.util.verbose; fprintf(' it %d / %d\n', itr, iterations); end

    c2 = 0.5*sum(centroids.^2,2);
    
    summation = zeros(k, size(X,2));
    counts = zeros(k, 1);
    
    for i=1:batch_size:size(X,1)
        lastIndex=min(i+batch_size-1, size(X,1));
        m = lastIndex - i + 1;
        
        [~,labels] = max(bsxfun(@minus,centroids*X(i:lastIndex,:)',c2));
        
        S = sparse(1:m,labels,1,m,k,m); % labels as indicator matrix
        summation = summation + S'*X(i:lastIndex,:);
        counts = counts + sum(S,1)';
    end
    
    centroids = bsxfun(@rdivide, summation, counts);
    
    % just zap empty centroids so they don't introduce NaNs everywhere.
    centroids(counts == 0, :) = 0;
end

end