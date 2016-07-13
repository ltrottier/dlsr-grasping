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
% Takes in RGB, depth, and mask images, and generates a set of features of
% the given size (numR x numC)
%
% All generated features will be of this given dimension. Bounds are set by
% the mask, the other dimension will be padded so that the image is
% centered. All channels are scaled together
%
% Last argument just tells whether or not to flip the depth channel - for
% some data, depth numbers increase as they get further from us, for some
% it's the other way around, so this lets us choose
%
% Generates:
% I: color image scaled into the [0 1] range.
%
% D: Depth image - to get this, we interpolate then downsample the given
% depth. We also drop the mean and filter out extreme outliers
%
% N: surface normals, 3 channels (X,Y,Z) - averaged from normals computed
% on the interpolated depth image
%
% IMask: Color image mask. Since we don't use the RGBD dataset mask for the
% color image, just masks out the padding needed to fit the target image
% size
%
% DMask: Mask for the depth and normal features. Based on the input mask,
% rescaled, with some additional outliers masked out
%
% Author: Ian Lenz
% Modified by: Ludovic Trottier

function [I,D,N,IMask,DMask] = getNewFeatFromRGBD(I1,D1,mask,numR,numC,negateDepth,depthStdCutoff,maskThresh)

if nargin < 8
    maskThresh = 0.75;
end

if nargin < 7
    depthStdCutoff = 4;
end

if nargin < 6
    negateDepth = 0;
end

if negateDepth
    D1 = -D1;
end

% Get rid of points where we don't have any depth values (probably points
% where Kinect couldn't get a value for some reason)
mask = mask.*(D1 ~= 0);

% Interpolate to get better data for downsampling/computing normals
D1 = D1.*mask;

% Do two passes of outlier removal since big outliers (as are present in
% some cases) can really skew the std, and leave other outliers well within
% the acceptable range. So, take these out and then recompute the std. If
% there aren't any huge outliers, std won't shift much and the 2nd pass
% won't eliminate that much more.
[D1,mask] = removeOutliers(D1,mask,depthStdCutoff);
[D1,mask] = removeOutliers(D1,mask,depthStdCutoff);
D1 = smartInterpMaskedData(D1,mask);

% Get normals from full-res image, then downsample
N = getSurfNorm(D1);
[N,~] = padImage(N,numR,numC);

% Downsample depth image and get new mask. 
[D,DMask] = padMaskedImage2(D1,mask,numR,numC);
% Since masks may be resized, need to re-convert them to binary by thresholding
DMask = DMask > maskThresh;
% Re-mask the depth data and the normals
D = D .* DMask;
N = N .* repmat(DMask, 1, 1, 3);

% Downsample rgb image and get new mask. 
I1 = I1 ./ 255;
[I,IMask] = padImage(I1,numR,numC);
% Since masks may be resized, need to re-convert them to binary by thresholding
IMask = IMask > maskThresh;
% Re-mask the rgb data (should not be necessary, but just in case)
I = I .* repmat(IMask, 1, 1, 3);

