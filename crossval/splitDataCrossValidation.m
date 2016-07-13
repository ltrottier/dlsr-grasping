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
% Perform per image split of the data and save the file no of each splits.
%
% Author: Ludovic Trottier

function cvFoldIndex = splitDataCrossValidation(fileIdx)

global opts

if strcmp(opts.learn.splitType, 'image')
    
    nImages = length(fileIdx);
    indices = crossvalind('Kfold', nImages, opts.learn.cvFold);

    for i = 1:opts.learn.cvFold
        cvFoldIndex(i).testIdx = fileIdx(indices == i);
        cvFoldIndex(i).trainIdx = fileIdx(indices ~= i);
    end

elseif strcmp(opts.learn.splitType, 'object')
    load(opts.learn.objectLabelsMatFile, 'objectLabels')
    fileObjectLabels = objectLabels(fileIdx);
    uniqueObjects = unique(objectLabels(objectLabels ~= 0));
    indices = crossvalind('Kfold', length(uniqueObjects), opts.learn.cvFold);
    
    for i = 1:opts.learn.cvFold
        testObjects = uniqueObjects(indices == i)';
        cvFoldIndex(i).testIdx = fileIdx(logical(sum(bsxfun(@eq, fileObjectLabels, testObjects), 1)));
        
        trainObjects = uniqueObjects(indices ~= i)';
        cvFoldIndex(i).trainIdx = fileIdx(logical(sum(bsxfun(@eq, fileObjectLabels, trainObjects), 1)));
        
        % verify that all images are used
        if ~all(sort([ cvFoldIndex(i).trainIdx cvFoldIndex(i).testIdx ]) == fileIdx)
            error('splitDataCrossValidation:error1', 'Some image were not used.')
        end
        % verify that no images are shared
        if sum(sum(bsxfun(@eq, cvFoldIndex(i).trainIdx, cvFoldIndex(i).testIdx'))) ~= 0
            error('splitDataCrossValidation:error2', 'Images are shared')
        end
        % verify that no object are shared
        if sum(sum(bsxfun(@eq, objectLabels(cvFoldIndex(i).trainIdx), objectLabels(cvFoldIndex(i).testIdx)'))) ~= 0
            error('splitDataCrossValidation:error3', 'Object are shared')
        end
    end
    
end

end