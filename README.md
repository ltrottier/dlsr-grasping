# dlsr-grasping

This project is a Matlab implementation of [Trottier, L. et al. (2016)](https://arxiv.org/abs/1606.00538 "ArXiv")
**Dictionary Learning for Robotic Grasp Recognition and Detection**.

## Installation

The [Cornell dataset](http://pr.cs.cornell.edu/sceneunderstanding/data/data.php) and
the sub-sampled [Washington RGBD dataset](http://rgbd-dataset.cs.washington.edu/) used
in the experiments of [Trottier, L. et al. (2016)](https://arxiv.org/abs/1606.00538 "ArXiv")
is already available in folder *data*.

To install:

1. Install the toolboxes by running file **setup.m**
2. Add current folder and all sub-folders to path with `addpath(genpath('.'));`

## How to

### Tutorial

File `recognitionMain.m`, available in folder **recognition**, is a detailed example
on how to perform dictionary learning, sparse coding and SVM training with cross-validation.

To see all available options for additional tweaking, see file `loadOverallParameters.m`
in folder **opts**.

### Reproducing [Trottier, L. et al. (2016)](https://arxiv.org/abs/1606.00538 "ArXiv")'s Experiments

Folder **tasks/recognition** contains all recognition experiments used to produce
the results presented in [Trottier, L. et al. (2016)](https://arxiv.org/abs/1606.00538 "ArXiv").
For instance, running `taskRpOmp.m` perform 5-5 nested cross-validation using
normalized random patches as dictionary and Orthogonal Matching Pursuit as features.

By default, the script is verbose. Consider setting `opts.util.verbose = false`
to turn off verbose mode.
