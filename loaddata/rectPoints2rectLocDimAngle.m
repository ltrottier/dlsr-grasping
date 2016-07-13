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
% Transforms rectangle points of the form [x1 y1 ; x2 y2 ; x3 y3 ; x4 y4]
% into a rectangle representation of the form [centerX, centerY, width, height, angle]
% 
% e.g.: rectPoints2rectLocDimAngle([260 299.194 ; 286 305 ; 291 283 ; 265 277.194 ])
%       [275.5000  291.0970   26.6404   22.5610   -167.4119]
%
% Author: Ludovic Trottier

function [ R ] = rectPoints2rectLocDimAngle( rectPoints )

R = zeros(1,5);
PDist = squareform(pdist(rectPoints));

% Compute the center coordinates from the max distance in x and y
R(1) = (max(rectPoints(:,1)) + min(rectPoints(:,1)))/2;
R(2) = (max(rectPoints(:,2)) + min(rectPoints(:,2)))/2;

% Compute the width from the distance between point 1 and 2
R(3) = PDist(1,2);

% Compute the height from the distance between point 2 and 3
R(4) = PDist(2,3);

% Compute the gripper angle based on the orientation from points 1 to 2
R(5) = atan2(rectPoints(1,2) - rectPoints(2,2), rectPoints(1,1) - rectPoints(2,1));
R(5) = rad2deg(R(5));

end

