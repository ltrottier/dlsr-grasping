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
% Load a grasping rectangle dataset containing RGB and depth information (as pcd files) 
% into RGBD images.
%
% Author: Ludovic Trottier

function [ graspRectImgs, graspRectClasses ] = loadRGBDGraspImages()


global opts

graspRectImgs = cell(1, opts.learn.maxFile);
graspRectClasses = cell(1, opts.learn.maxFile);

if opts.util.verbose
    fprintf('Loading dataset from raw files.\n');
    pause(2)
end

for i = 1:opts.learn.maxFile
    pcdFile = sprintf('%s/pcd%04d.txt', opts.learn.dataPath, i);
    
    if opts.util.verbose && (mod(i,1) == 0)
        fprintf(' it %d of %d \n', i, opts.learn.maxFile);
    end
    
    if ~exist(pcdFile,'file')
        continue
    end
    
    % Load original RGBD image
    pcdFile = sprintf('%s/pcd%04d.txt',opts.learn.dataPath,i);
    imFile = sprintf('%s/pcd%04dr.png',opts.learn.dataPath,i);
    I = graspPCDToRGBDImage(pcdFile, imFile);
    
    % Load positive grasp rectangle positions
    rectFilePos = sprintf('%s/pcd%04dcpos.txt',opts.learn.dataPath,i);
    rectPointsPos = load(rectFilePos);
    nRectPos = size(rectPointsPos,1)/4;
    
    % Load negative grasp rectangle positions
    rectFileNeg = sprintf('%s/pcd%04dcneg.txt',opts.learn.dataPath,i);
    rectPointsNeg = load(rectFileNeg);
    nRectNeg = size(rectPointsNeg,1)/4;
   
    % Load positive grasp rotated RGBD images
    for j = 1:nRectPos
        startInd = (j-1)*4 + 1;
        curI = orientedRGBDRectangle(I,rectPointsPos(startInd:startInd+3,:));
        if size(curI,1) > 1
            graspRectImgs{i}{end+1} = curI;
            graspRectClasses{i}(end+1) = 1;
        end
    end
    
    % Load negative grasp rotated RGBD images
    for j = 1:nRectNeg
        startInd = (j-1)*4 + 1;
        curI = orientedRGBDRectangle(I,rectPointsNeg(startInd:startInd+3,:));
        if size(curI,1) > 1
            graspRectImgs{i}{end+1} = curI;
            graspRectClasses{i}(end+1) = 2;
        end
    end

    
end

if ~isempty(opts.learn.graspImagesMatfile)
    if opts.util.verbose
        fprintf('Dataset saved to: %s.mat\n', opts.learn.graspImagesMatfile); 
    end
    save(opts.learn.graspImagesMatfile, 'graspRectImgs', 'graspRectClasses')
end


end

