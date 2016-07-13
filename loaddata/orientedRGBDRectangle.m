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
% Extract a patch from the given image corresponding to the given rectangle
% corners. Rectangle does not have to be axis-aligned.
%
% rectPoints is a 4x2 matrix, where each row is a point, and the columns
% represent the X and Y coordinates. The line segment from points 1 to 2
% corresponds to one of the gripper plates. 
%
% Author: Ian Lenz
% Modified by: Ludovic Trottier

function I3 = orientedRGBDRectangle(I,rectPoints)

global opts

if any(isnan(rectPoints(:)))
    I3 = NaN;
    return;
end

% Compute the gripper angle based on the orientation from points 1 to 2
gripAng = atan2(rectPoints(1,2) - rectPoints(2,2),rectPoints(1,1)-rectPoints(2,1));
gripAng = rad2deg(gripAng);

% Find the image englobing the rectangle and rotate it
minXY = round(min(rectPoints, [], 1));
maxXY = round(max(rectPoints, [], 1));
I3 = imrotate(I(minXY(2):maxXY(2), minXY(1):maxXY(1), :), gripAng, 'bilinear');
I3(:,:,1:3) = round(I3(:,:,1:3));

% Find the rectangle points in the rotate englobing image
localPoints = bsxfun(@minus, round(rectPoints), minXY - 1);
pointsImage = zeros(maxXY(2) - minXY(2) + 1, maxXY(1) - minXY(1) + 1);
pointsImage(sub2ind(size(pointsImage), localPoints(:,2), localPoints(:,1))) = 255;
pointsImageRot = imrotate(pointsImage, gripAng, 'bilinear');
[row, col] = find(pointsImageRot);

% Keep the subimage
I3 = I3(min(row)+1:max(row)-1, min(col)+1:max(col)-1,:);

if isempty(I3)
    warning('orientedRGBDRectangle:I3 is empty.')
end

% subplot(1,2,1)
% imshow(I3(:,:,1:3)./255)
% subplot(1,2,2)
% imshow(I2(:,:,1:3)./255)
% drawnow
% pause(0.2)
end
