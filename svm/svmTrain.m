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
% SVM training optimization.
%
% Author: Adam Coates

function theta = svmTrain(X, Y, C, maxIter, maxFunEvals)

global opts

if opts.util.verbose; fprintf('Training SVM...\n'); end

if nargin < 5
    maxFunEvals = 1000;
end

if nargin < 4
    maxIter = 1000;
end

X = [X, ones(size(X,1),1)];
numClasses = max(Y);
w0 = zeros(size(X,2)*numClasses, 1);
if opts.util.verbose
    displayStyle = 'iter';
else
    displayStyle = 'off';
end


w = minFunc(@my_l2svmloss, w0, struct('MaxIter', maxIter, 'MaxFunEvals', maxFunEvals, 'Display', displayStyle), ...
    X, Y, numClasses, C);

theta = reshape(w, size(X,2), numClasses);

if opts.util.verbose; fprintf('Training SVM done.\n'); end

end

% 1-vs-all L2-svm loss function;  similar to LibLinear.
function [loss, g] = my_l2svmloss(w, X, y, K, C)
[M,N] = size(X);
theta = reshape(w, N,K);
Y = bsxfun(@(y,ypos) 2*(y==ypos)-1, y, 1:K);

margin = max(0, 1 - Y .* (X*theta));
loss = (0.5 * sum(theta.^2)) + C*mean(margin.^2);
loss = sum(loss);
g = theta - 2*C/M * (X' * (margin .* Y));

% adjust for intercept term
loss = loss - 0.5 * sum(theta(end,:).^2);
g(end,:) = g(end, :) - theta(end,:);

g = g(:);

%[v,i] = max(X*theta,[],2);
%sum(i ~= y) / length(y)
end