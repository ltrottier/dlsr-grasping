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
% Interpolates masked data (e.g. the depth channel). Uses MATLAB's
% scattered interpolation functionality to do the interpolation, ignoring
% masked-out points.
%
% Can optionally provide the interpolation method to use, if not given,
% defaults to linear.
%
% Author: Ian Lenz

function filled = interpMaskedData(data, mask, method)

% Default method to linear if not provided
if nargin < 3
    method = 'linear';
end

% Don't do anything if everything is masked out
if ~any(mask(:))
    filled = data;
    return;
end

mask = logical(mask);

% Make a grid for X,Y coords, and pick the masked-in points
[X,Y] = meshgrid(1:size(data,2),1:size(data,1));

% Known points
Xg = X(mask);
Yg = Y(mask);

% "Query" points, to be filled
Xq = X(~mask);
Yq = Y(~mask);

Vg = data(mask);

% Run the interpolation, and read out the query points
F = scatteredInterpolant(Xg,Yg,Vg,method);
Vq = F(Xq,Yq);

% Initialize the returned data with the given data, and replace the
% masked-out points with their interpolated values.
filled = data;

if ~isempty(Vq)
    filled(~mask) = Vq;
end