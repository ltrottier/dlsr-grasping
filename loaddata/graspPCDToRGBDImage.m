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
% Loads the given instance number from the given directory (containing the
% grasping dataset), and returns the RGB-D data as a 4-channel image, with
% RGB as channels 1-3 and D as channel 4.
%
% Author: Ian Lenz
% Modified by: Ludovic Trottier

function I = graspPCDToRGBDImage(pcdFile, imFile, offset)

if nargin < 3
    offset = [0 0];
end

[points, imPoints] = readGraspingPcd(pcdFile);

I = double(imread(imFile));

if ischar(imPoints) && strcmp(imPoints, 'ordered')
    D = zeros(size(I,1),size(I,2));
    D(1:end) = points(:,3);
    
%     figure; imshow((D - min(D(:)) ) / (max(D(:)) - min(D(:))))
%     figure; imshow(I(:,:,1:3)./255)

    D(isnan(D)) = 0;
    I(:,:,4) = D;
else
    D = zeros(size(I,2),size(I,1));
    if size(imPoints,2) == 1
        D(imPoints) = points(:,3);
    elseif size(imPoints,2) == 2
        imPoints = bsxfun(@minus, imPoints, offset);
        D(sub2ind(size(D), imPoints(:,1), imPoints(:,2))) = points(:,3);
    end
    
    I(:,:,4) = D';
    
%     figure; imshow((D' - min(D(:)) ) / (max(D(:)) - min(D(:))))
%     figure; imshow(I(:,:,1:3)./255)

end


end

function [points,imPoints,rgb] = readGraspingPcd(fname)
% Read PCD data
% fname - Path to the PCD file
% data - Nx6 matrix where each row is a point, with 
%        fields x y z rgb imX imY 
%        or     x y z rgb index
%        x, y, z are the 3D coordinates of the point
%        rgb is the color of the point packed into a float (unpack using unpackRGBFloat)
%        imX and imY are the horizontal and vertical pixel locations of the point in the original Kinect image.
%        index are the column major index of the X Y positions
%
% Author: Kevin Lai
% Modified by: Ludovic Trottier

fid = fopen(fname,'rt');

isBinary = false;
nPts = 0;
nDims = -1;
line = [];
format = [];
headerLength = 0;
IS_NEW = true;
while length(line) < 4 | ~strcmp(line(1:4),'DATA')
   line = fgetl(fid);
   if ~ischar(line)
      % end of file reached before finished parsing. No data
      data = zeros(0,6);
      return;
   end

   headerLength = headerLength + length(line) + 1;

   if length(line) >= 4 && strcmp(line(1:6), 'FIELDS')
       fields = textscan(line, '%s');
       fields = fields{1};
       fieldIndex = any(cellfun(@(x)(strcmp(x,'index')), fields));
       imXimYIndex = any(cellfun(@(x)(strcmp(x,'imX')), fields) & cellfun(@(x)(strcmp(x,'imY')), fields));
   end
   
   if length(line) >= 4 && strcmp(line(1:4),'TYPE') %COLUMNS
      while ~isempty(line)
         [t line] = strtok(line);
         if nDims > -1 && strcmp(t,'F')
            format = [format '%f '];
         elseif nDims > -1 && strcmp(t,'U')
            format = [format '%d '];
         end
         nDims = nDims+1;
      end
   end      

   if length(line) >= 7 && strcmp(line(1:7),'COLUMNS')
      IS_NEW = false;
      while ~isempty(line)
         [ig line] = strtok(line);
         format = [format '%f '];
         nDims = nDims+1;
      end
   end

   if length(line) >= 6 && strcmp(line(1:6),'POINTS')
      [ig l2] = strtok(line);
      nPts = sscanf(l2,'%d');
   end

   if length(line) >= 4 && strcmp(line(1:4),'DATA')
      if length(line) == 11 && strcmp(line(6:11),'binary')
         isBinary = true;
      end
   end
end
format(end) = [];

if isBinary
   paddingLength = 4096*ceil(headerLength/4096);
   padding = fread(fid,paddingLength-headerLength,'uint8');
end

if isBinary && IS_NEW
   data = zeros(nPts,nDims);
   format = regexp(format,' ','split');
   for i=1:nPts
      for j=1:length(format)
         if strcmp(format{j},'%d') 
            pt = fread(fid,1,'uint32');
         else
            pt = fread(fid,1,'float');
         end
         data(i,j) = pt;
      end
   end
elseif isBinary && ~IS_NEW
   pts = fread(fid,inf,'float');
   data = zeros(nDims,nPts);
   data(:) = pts;
   data = data';
else
   format = [format '\n'];
   C = textscan(fid,format);

   points = cell2mat(C(1:3));
   rgb = unpackRGBFloat(C{4});
   if fieldIndex
        imPoints = C{end};
   elseif imXimYIndex
        imPoints = cell2mat(C(5:6));
   else
       imPoints = 'ordered';
   end
end
fclose(fid);

end

function rgb = unpackRGBFloat(rgbfloatdata)
% Unpack RGB float data into separate color values
% rgbfloatdata - the RGB data packed into Nx1 floats
% rgb - Nx3 unpacked RGB values
%
% Author: Kevin Lai

mask = hex2dec('000000FF');
rgb = typecast(rgbfloatdata,'uint32');

r = uint8(bitand(bitshift(rgb,-16),mask));
g = uint8(bitand(bitshift(rgb,-8),mask));
b = uint8(bitand(rgb,mask));
rgb = [r g b];

end
