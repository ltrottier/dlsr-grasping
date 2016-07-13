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
% Extends an image to the given dimensions. Scales so that at least one
% dimension will exactly match the target dimension.
% The other will either also match or be smaller, and be centered and padded 
% by zeros on either side.
%
% Author: Ian Lenz

function [I2, mask] = padImage(I,newR,newC)

% Compute ratios of the target/current dimensions
rRatio = newR/size(I,1);
cRatio = newC/size(I,2);

% Use these to figure out which dimension needs padding and resize
% accordingly, so that one dimension is "tight" to the new size
if rRatio < cRatio
    I = imresize(I,[newR NaN]);
else
    I = imresize(I,[NaN newC]);
end

% Place the resized image into the full-sized image
[numR, numC, numDims] = size(I);

rStart = round((newR-numR)/2) + 1;
cStart = round((newC-numC)/2) + 1;

I2 = zeros(newR,newC,numDims);

I2(rStart:rStart+numR-1,cStart:cStart+numC-1,:) = I;

% Mask out padding
mask = zeros(newR,newC);

mask(rStart:rStart+numR-1,cStart:cStart+numC-1) = 1;