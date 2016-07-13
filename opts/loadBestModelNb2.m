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
% Hyper-parameters of the best model nb 2
%
% Author: Ludovic Trottier

opts.ufl.dlMethod = 'gsvq';
opts.ufl.dlNEpochs = 100;
opts.ufl.nPatches = 100000;
opts.ufl.scMethod = 'soft-threshold';
opts.ufl.scLambda = 0.5;
opts.ufl.scUseMask = false;
opts.ufl.splitPolarities = true;

opts.svm.C = 1;

opts.crossval.dlLambda = [];
opts.crossval.scLambda = [0.5, 1, 1.5, 2];
opts.crossval.svmC = [1, 10];