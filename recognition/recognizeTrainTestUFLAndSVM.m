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
% Train a dictionary, extract sparse codes and train a SVM on the training set. 
% Then extract sparse codes with the trained dictionary and test the trained SVM 
% on the test set.
%
% Author: Ludovic Trottier

function [ accTrain, accTest ] = recognizeTrainTestUFLAndSVM(preprocGraspRectImgsTrain, preprocGraspRectMasksTrain, graspRectClassesTrain, preprocGraspRectImgsTest, preprocGraspRectMasksTest, graspRectClassesTest)

global opts

% format preprocessed training data
preprocFeaturesTrain = cell2mat(cellfun( @(x)(cell2mat(x')), preprocGraspRectImgsTrain, 'UniformOutput',false)');
preprocMasksTrain = cell2mat(cellfun( @(x)(cell2mat(x')), preprocGraspRectMasksTrain, 'UniformOutput',false)');
classesTrain = cell2mat(graspRectClassesTrain)';

% train dictionary
if opts.util.verbose; fprintf('Training phase...\n'); end
[dictionary, zcaWhitenParameters] = trainDictionary(preprocFeaturesTrain, preprocMasksTrain);

% extract training features
featuresTrain = extractUFLFeatures(dictionary, preprocFeaturesTrain, preprocMasksTrain, zcaWhitenParameters);

% perform a final standardization
featuresTrainMean = mean(featuresTrain);
featuresTrainStd = sqrt(var(featuresTrain)+opts.ufl.standardizationMinStd);
featuresTrainS = bsxfun(@rdivide, bsxfun(@minus, featuresTrain, featuresTrainMean), featuresTrainStd);

% train / test classifier
theta = svmTrain(featuresTrainS, classesTrain, opts.svm.C, opts.svm.maxIter, opts.svm.maxFunEvals);
[accTrain, labelsTrain] = svmScore(featuresTrainS, classesTrain, theta);
if opts.util.verbose; fprintf('Training phase done.\n'); end

% format preprocessed testing data
if opts.util.verbose; fprintf('Testing phase...\n'); end
preprocFeaturesTest = cell2mat(cellfun( @(x)(cell2mat(x')), preprocGraspRectImgsTest, 'UniformOutput', false)');
preprocMasksTest = cell2mat(cellfun( @(x)(cell2mat(x')), preprocGraspRectMasksTest, 'UniformOutput', false)');
classesTest = cell2mat(graspRectClassesTest)';

% extract testing features
featuresTest = extractUFLFeatures(dictionary, preprocFeaturesTest, preprocMasksTest, zcaWhitenParameters);

% perform a final standardization
featuresTestS = bsxfun(@rdivide, bsxfun(@minus, featuresTest, featuresTrainMean), featuresTrainStd);

% test classifier
[accTest, labelsTest] = svmScore(featuresTestS, classesTest, theta);

if opts.util.verbose; fprintf('Testing phase done.\n'); end
end

