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
% Example of grasp recognition main file.
%
% Author: Ludovic Trottier

clear; clc; close all;

% load global variable opts containing all parameters
loadOverallParameters

% set hyper-parameters
opts.ufl.dlMethod = 'kmeans';
opts.ufl.dlLambda = 15;
opts.ufl.dlNEpochs = 100;
opts.ufl.nAtoms = 300;
opts.ufl.nPatches = 100000;
opts.ufl.scMethod = 'kmeans-tri';
opts.ufl.scLambda = 0.5;
opts.ufl.scUseMask = false;
opts.ufl.splitPolarities = true;
opts.ufl.addWashingtonRGBDPatches = false;
opts.ufl.showDictionary = true;
opts.ufl.poolingType = 'sum';
opts.svm.C = 1;
opts.learn.savefile = [pwd filesep 'save' filesep 'tutorial.mat'];

% load grasp rgbd images from pcd file or from mat file
if opts.learn.dataFromPcd
    [ graspRectImgs, graspRectClasses ] = loadRGBDGraspImages();
else
    if opts.util.verbose; fprintf('Loading dataset from %s.mat file... ', opts.learn.graspImagesMatfile); end
    load(opts.learn.graspImagesMatfile, 'graspRectImgs', 'graspRectClasses')
    if opts.util.verbose; fprintf('done.\n'); end
end

[preprocGraspRectImgs, preprocGraspRectMasks] = getNewFeatFromAllRGBD(graspRectImgs);

cvFoldIndex = splitDataCrossValidation(getAllFileIdx(graspRectImgs));
accTrainCV = zeros(1, opts.learn.cvFold);
accTestCV = zeros(1, opts.learn.cvFold);

if opts.util.verbose; fprintf('%d-fold CV...\n', opts.learn.cvFold); end

for fold = 1:opts.learn.cvFold
    
    if opts.util.verbose; fprintf('Fold %d...\n', fold); end
   
    [ accTrain, accTest ] = recognizeTrainTestUFLAndSVM( ...
        preprocGraspRectImgs(cvFoldIndex(fold).trainIdx), ...
        preprocGraspRectMasks(cvFoldIndex(fold).trainIdx), ...
        graspRectClasses(cvFoldIndex(fold).trainIdx), ...
        preprocGraspRectImgs(cvFoldIndex(fold).testIdx), ...
        preprocGraspRectMasks(cvFoldIndex(fold).testIdx), ...
        graspRectClasses(cvFoldIndex(fold).testIdx) );
    
    accTrainCV(fold) = accTrain;
    accTestCV(fold) = accTest;
    
    save(opts.learn.savefile, 'accTrainCV', 'accTestCV')
    
    if opts.util.verbose
        fprintf('Fold %d done. Mean Accuracy: Train %f %%, Test %f %%. \n', fold, accTrain, accTest)
    end
end

if opts.util.verbose; fprintf('%d-fold CV done.\n', opts.learn.cvFold); end
fprintf('Mean accuracy : Train = %f %%, Test = %f %%. \n', mean(accTrainCV), mean(accTestCV))
