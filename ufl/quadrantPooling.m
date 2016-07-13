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
% Pool features in each quadrant.
%
% Author: Ludovic Trottier

function [ pooledX ] = quadrantPooling( X )

global opts

[prows, pcols, pdepth] = size(X);

rowStride = round(prows/opts.ufl.poolingQuadrant);
colStride = round(pcols/opts.ufl.poolingQuadrant);

pooledX = zeros(1, pdepth*opts.ufl.poolingQuadrant*opts.ufl.poolingQuadrant);

if strcmp(opts.ufl.poolingType, 'sum')
    poolingFn = @sum;
elseif strcmp(opts.ufl.poolingType, 'max')
    poolingFn = @maxPooling;
end

% keep track of the position of the quadrant in the pooledX vector
pos = 1;

for row = 1:opts.ufl.poolingQuadrant
    % get row index of quadrant by accounting for the last quadrant
    if row < opts.ufl.poolingQuadrant
        rowIndex = (row-1)*rowStride + 1 : row*rowStride;
    else
        rowIndex = (row-1)*rowStride + 1 : prows;
    end
    
    for col = 1:opts.ufl.poolingQuadrant 
        % get col index of quadrant by accounting for the last quadrant
        if col < opts.ufl.poolingQuadrant
            colIndex = (col-1)*colStride + 1 : col*colStride;
        else
            colIndex = (col-1)*colStride + 1 : pcols;
        end
    
        pooledX(pos : pos + pdepth - 1) = poolingFn(poolingFn(X(rowIndex, colIndex,:), 1), 2);
        pos = pos + pdepth;
    end
end


end

function p = maxPooling(x, dim)

p = max(abs(x),[],dim);
neg = p ~= max(x,[],dim);
p(neg) = -p(neg);

end
