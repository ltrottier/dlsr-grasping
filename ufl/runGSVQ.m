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
% Perform GSVQ optimization.
%
% Author: Adam Coates

function dictionary = runGSVQ(X, k, iterations, batch_size)

global opts

% initialize dictionary
dictionary = randn(k, size(X,2));
dictionary = bsxfun(@rdivide, dictionary, sqrt(sum(dictionary.^2,2)+1e-20));

for itr=1:iterations
    if opts.util.verbose; fprintf(' it %d / %d\n', itr, iterations); end
    
    % do assignment + accumulation
    [summation,counts] = gsvq_step(X, dictionary, batch_size);
    
    % reinit empty clusters
    I=find(sum(summation.^2,2) < 0.001);
    summation(I,:) = randn(length(I), size(X,2));
    
    % normalize
    dictionary = bsxfun(@rdivide, summation, sqrt(sum(summation.^2,2)+1e-20));
end


function [summation, counts] = gsvq_step(X, dictionary, batch_size)

summation = zeros(size(dictionary));
counts = zeros(size(dictionary,1),1);

k = size(dictionary,1);

tic;
for i=1:batch_size:size(X,1)
    lastInd=min(i+batch_size-1, size(X,1));
    m = lastInd - i + 1;
    
    dots = dictionary*X(i:lastInd,:)';
    [val,labels] = max(abs(dots)); % get labels
    
    E = sparse(labels,1:m,1,k,m,m); % labels as indicator matrix
    counts = counts + sum(E,2);  % sum up counts
    
    dots = dots .* E; % dots is now sparse
    summation = summation + dots * X(i:lastInd,:); % take sum, weighted by dot product
end
