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
% Gets the surface normals for a given depth image. Normalizes them so
% the L2 norm for each point is 1 (MATLAB doesn't do this for us)
%
% Author: Ian Lenz

function N = getSurfNorm(D)

[Nx, Ny, Nz] = surfnorm(D);

N = zeros([size(Nx,1) size(Nx,2) 3]);
N(:,:,1) = Nx;
N(:,:,2) = Ny;
N(:,:,3) = Nz;

N = bsxfun(@rdivide,N,sqrt(sum(N.^2,3)));