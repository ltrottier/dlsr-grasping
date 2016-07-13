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
% Performs simple whitening (subtract mean, divide by std) on a case-wise
% basis on the given features. Used for depth data, since we'd like each
% depth patch to be zero-mean, and scaled separately (so patches with a
% wider std. don't get more weight).
%
% Assumes these are all the same "type" of feature, so we can whiten them
% all together (use the same mean and std for all features).
%
% Author: Ian Lenz
% Modified by: Ludovic Trottier

function [feat,featStd] = caseWiseWhiten(feat,mask,minStd)

% Don't go below some minimum std. for whitening. This is to make sure that
% cases with low std's (flat table, etc.) don't get exaggerated too much,
% distorting appearance.
if nargin < 3
    minStd = 10;
end

featMean = maskmean(feat,~mask,2);
feat = bsxfun(@minus,feat,featMean);
feat(~mask) = 0;
featVar = maskvar(feat, ~mask, 2);
featStd = sqrt(featVar + minStd);
feat = bsxfun(@rdivide,feat,featStd);
feat(~mask) = 0;

end