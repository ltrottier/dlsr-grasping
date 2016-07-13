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
% Hyper-parameter optimization with cross-validation.
%
% Author: Ludovic Trottier

function optimizeHyperparameters( preprocGraspRectImgs, preprocGraspRectMasks, graspRectClasses, fileIdx  )

global opts

if opts.util.verbose; fprintf('Nested CV...\n'); end

% check if using 'natural' encoding
if isempty(opts.crossval.dlLambda)
    natural = true;
    paramSetCV = cartesianProduct({opts.crossval.svmC, opts.crossval.scLambda});
else
    natural = false;
    paramSetCV = cartesianProduct({opts.crossval.svmC, opts.crossval.scLambda, opts.crossval.dlLambda});
end

if opts.util.verbose
    fprintf('CV hyper-parameters:\n')
    disp(paramSetCV)
end

nUple = size(paramSetCV, 1);

warning('off', 'MATLAB:load:variableNotFound');
loadedVariables = load(opts.learn.savefile, 'ncvl2');
if isempty(fieldnames(loadedVariables))
    ncvl2.i = 1;
    ncvl2.cvTestAcc = zeros(1, nUple);
    ncvl2.cvFoldIndex = splitDataCrossValidation(fileIdx);
    save(opts.learn.savefile, 'ncvl2', '-append')
else
    ncvl2 = loadedVariables.ncvl2;
end

for i = ncvl2.i:nUple
    
    % set parameters
    opts.svm.C = paramSetCV(i,1);
    opts.ufl.scLambda = paramSetCV(i,2);
    if natural
        opts.ufl.dlLambda = opts.ufl.scLambda;
    else
        opts.ufl.dlLambda = paramSetCV(i,3);
    end
    
    if opts.util.verbose
        fprintf('Nested CV #%d with SVM-C = %f, SC-lambda = %f, DL-lambda = %f...\n', i, opts.svm.C, opts.ufl.scLambda, opts.ufl.dlLambda)
    end
    
    accTestCV = zeros(1, opts.learn.cvFold);
    for fold = 1:opts.learn.cvFold
        if opts.util.verbose; fprintf('Nested Fold %d / %d...\n', fold, opts.learn.cvFold); end
        [ accTrain, accTest ] = recognizeTrainTestUFLAndSVM( ...
            preprocGraspRectImgs(ncvl2.cvFoldIndex(fold).trainIdx), ...
            preprocGraspRectMasks(ncvl2.cvFoldIndex(fold).trainIdx), ...
            graspRectClasses(ncvl2.cvFoldIndex(fold).trainIdx), ...
            preprocGraspRectImgs(ncvl2.cvFoldIndex(fold).testIdx), ...
            preprocGraspRectMasks(ncvl2.cvFoldIndex(fold).testIdx), ...
            graspRectClasses(ncvl2.cvFoldIndex(fold).testIdx) );
        
        accTestCV(fold) = accTest;
        if opts.util.verbose; fprintf('Nested Fold %d / %d done. Accuracy: Train %f %%, Test %f %%\n', fold, opts.learn.cvFold, accTrain, accTest); end
    end
    
    ncvl2.cvTestAcc(i) = mean(accTestCV);
    ncvl2.i = i+1;
    
    if opts.util.verbose; fprintf('Nested CV #%d done. Mean test accuracy of %f %%. \n', i, ncvl2.cvTestAcc(i)); end
    
    save(opts.learn.savefile, 'ncvl2', '-append')
end

% find the best hyper-parameter set
[~, ind] = max(ncvl2.cvTestAcc);

opts.svm.C = paramSetCV(ind,1);
opts.ufl.scLambda = paramSetCV(ind,2);
if natural
    opts.ufl.dlLambda = opts.ufl.scLambda;
else
    opts.ufl.dlLambda = paramSetCV(ind,3);
end

if opts.util.verbose
    fprintf('Nested CV done.\n')
    fprintf('Best hyper-parameter found: SVM-C = %f, SC-lambda = %f, DL-lambda = %f.\n', opts.svm.C, opts.ufl.scLambda, opts.ufl.dlLambda);
end

% reinitialize cv params
rmvar(opts.learn.savefile, 'ncvl2')
end

