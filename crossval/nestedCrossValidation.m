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
% Main script for performing nested cross validation. Make sure loadOverallParameters has
% been called prior to executing this.
%
% Author: Ludovic Trottier


% load grasp rgbd images from pcd file or from mat file
% you should load them from pcd if this is the first time, then you can just load them
if opts.learn.dataFromPcd
    [ graspRectImgs, graspRectClasses ] = loadRGBDGraspImages();
else
    if opts.util.verbose; fprintf('Loading dataset from %s.mat file... ', opts.learn.graspImagesMatfile); end
    load(opts.learn.graspImagesMatfile, 'graspRectImgs', 'graspRectClasses')
    if opts.util.verbose; fprintf('done.\n'); end
end

[preprocGraspRectImgs, preprocGraspRectMasks] = getNewFeatFromAllRGBD(graspRectImgs);

% Load from previous run if available
if exist(opts.learn.savefile, 'file') == 0
    save(opts.learn.savefile, 'opts')
end
loadedVariables = load(opts.learn.savefile, 'ncvl1');
if isempty(fieldnames(loadedVariables))
    if opts.util.verbose; fprintf('Starting Optimization.\n\n'); end
    ncvl1.cvFoldIndex = splitDataCrossValidation(getAllFileIdx(graspRectImgs));
    ncvl1.fold = 1;
    ncvl1.accTrainCV = zeros(1, opts.learn.cvFold);
    ncvl1.accTestCV = zeros(1, opts.learn.cvFold);
    save(opts.learn.savefile, 'ncvl1', '-append');
else
    if opts.util.verbose; fprintf('Resuming previous run from %s.\n\n', opts.learn.savefile); end
    ncvl1 = loadedVariables.ncvl1;
end

for fold = ncvl1.fold:opts.learn.cvFold
    
    if opts.util.verbose; fprintf('Fold %d...\n', fold); end
    
    optimizeHyperparameters(preprocGraspRectImgs, preprocGraspRectMasks, graspRectClasses, ncvl1.cvFoldIndex(fold).trainIdx)
    
    if opts.util.verbose; fprintf('Fold %d train-test phase...\n', fold); end
    
    [ accTrain, accTest ] = recognizeTrainTestUFLAndSVM( ...
        preprocGraspRectImgs(ncvl1.cvFoldIndex(fold).trainIdx), ...
        preprocGraspRectMasks(ncvl1.cvFoldIndex(fold).trainIdx), ...
        graspRectClasses(ncvl1.cvFoldIndex(fold).trainIdx), ...
        preprocGraspRectImgs(ncvl1.cvFoldIndex(fold).testIdx), ...
        preprocGraspRectMasks(ncvl1.cvFoldIndex(fold).testIdx), ...
        graspRectClasses(ncvl1.cvFoldIndex(fold).testIdx) );
    
    ncvl1.accTrainCV(fold) = accTrain;
    ncvl1.accTestCV(fold) = accTest;
    
    ncvl1.fold = fold+1;
    save(opts.learn.savefile, 'ncvl1', '-append')
    
    if opts.util.verbose
        fprintf('Fold %d done. Mean Accuracy: Train %f %%, Test %f %%. \n', fold, accTrain, accTest)
    end
end

fprintf('Mean accuracy after nested CV: Train = %f %%, Test = %f %%. \n', mean(ncvl1.accTrainCV), mean(ncvl1.accTestCV))
