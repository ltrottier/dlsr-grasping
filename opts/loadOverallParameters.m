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
% Program options.
%
% Author: Ludovic Trottier

global opts
opts = struct();

% Unsupervised feature learning parameters
opts.ufl.rfSize = 6; % receptive field (or patch dimension)
% NOT IMPLEMENTED opts.ufl.convStep = 1; % convolutional step (stride) on the image
opts.ufl.poolingQuadrant = 2; % divide the image into 2*2 quadrants
opts.ufl.poolingType = 'sum'; % either 'sum' or 'max': type of pooling
opts.ufl.nAtoms = 300; % number of dictionary atoms
opts.ufl.dlMethod = 'kmeans'; % either 'kmeans', 'nkmeans', 'rp', 'rand', 'gsvq', 'odl-omp' or 'odl-lasso': method for learning the dictionary
opts.ufl.dlLambda = 2; % sparsity parameter of the sparse coding method used during dictionary learning
opts.ufl.dlNEpochs = 1000; % number of epoch for dictionary learning
opts.ufl.dlBatchSize = 1000; % batch size for learning the dictionary
opts.ufl.showDictionary = false; % show the dictionary after training
opts.ufl.scMethod = 'kmeans-tri'; % either 'kmeans-tri', 'soft-threshold', 'lasso' or 'omp': method for sparse coding
opts.ufl.scLambda = 2; % sparsity parameter of the sparse coding method used for feature encoding
opts.ufl.scUseMask = true; % use mask when performing sparse coding
opts.ufl.splitPolarities = true; % wheter the positive and negative weigths are splitted or not
opts.ufl.nPatches = 100000; % number of patches to extract from the images for learning the dictionary
opts.ufl.numThreads = -1; % number of threads for dictionary learning and sparse coding
opts.ufl.addWashingtonRGBDPatches = false; % add patches taken from washington rgbd dataset
opts.ufl.nWashingtonRGBDPatches = 100000; % number of washington rgbd dataset patches to take
opts.ufl.washingtonRGBDImages = [pwd filesep 'data' filesep 'washington-rgbd' filesep 'washingtonRGBDImages.mat']; % matfile of the original images
opts.ufl.washingtonDataPath = [pwd filesep 'data' filesep 'washington-rgbd' filesep 'rawDataSet']; % folder of the original images
opts.ufl.zcaWhiten = true; % zca whiten the patches or not
opts.ufl.maskedNotMaskedRatio = 0.2; % A patch is accepted if it has less than 20% masked values.
opts.ufl.standardizationMinStd = 0.00001; % value added to the variance to avoid 0 variance problem

% Grasping parameters
opts.grasp.imgSize = 24; % dimension of the rectangle image after rotation and rescaling
opts.grasp.stdWhiten = true; % should the features be standardized (whithen with mean subtraction and std division)
opts.grasp.stdWhitenSavefile = [pwd filesep 'save' filesep 'stdWhitenMeansAndStds']; % savefile for the whitening standard deviations and means
opts.grasp.rotationScale = 1; % Scaling the new points after rotation the rectangle image
opts.grasp.depthStdCutoff = 4; % Cutoff for outliers in depth image
opts.grasp.maskThresh = 0.75; % Since mask are resized, need to re-convert them to binary by thresholding
opts.grasp.caseWiseWhiteningMinStd = 0.0001; % add this value to the variance when whitening case wise
opts.grasp.objectDetectionPadSize = 20; % size of the padding when detecting the position of the object

% SVM classifier
opts.svm.C = 1; % Regularization hyper-parameter for SVM
opts.svm.maxIter = 1000; % Maximum number of iterations of minFunc (lbfgs) for learning the SVM
opts.svm.maxFunEvals = 1000; % Maximum number of function evaluations of minFunc (lbfgs) for learning the SVM

% Learning scenario
opts.learn.dataPath = [pwd filesep 'data' filesep 'rawDataSet']; % assuming correl grasping dataset
opts.learn.bgImagesPath = [pwd filesep 'data' filesep 'backgroundImages']; % assuming correl grasping dataset
opts.learn.bgNumberMatFile = [pwd filesep 'data' filesep 'bgNums']; % associated background to each image
opts.learn.objectLabelsMatFile = [pwd filesep 'data' filesep 'objectLabels.mat']; % object labels of each image
opts.learn.detectionPath = [pwd filesep 'data' filesep 'detection']; % folder containing precalculated detection candidate
opts.learn.maxFile = 1050; % load images from 1 to 1050 (skip non existant images)
opts.learn.cvFold = 5; % number of cross validation fold
opts.learn.splitType = 'image'; % either 'image' or 'object', type of split for cross-validation
opts.learn.graspImagesMatfile = [pwd filesep 'data' filesep 'graspImagesDataset']; % matfile of Correl grasp images (is empty, won't save)
opts.learn.dataFromPcd = false; % load data from pcd or from matfile
opts.learn.savefile = [pwd filesep 'save' filesep' 'tmp.mat'];

% Cross-validation
opts.crossval.dlLambda = [0.1, 0.5, 1, 5];
opts.crossval.scLambda = [0.1, 0.5, 1, 5];
opts.crossval.svmC = [10, 100, 1000];

% Detection
opts.detection.minJaccard = 0.25; % minimum value of the jaccard index to be a valid grasp

% Utility
opts.util.verbose = true; % print what is happening