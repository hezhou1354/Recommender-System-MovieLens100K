Thanks for downloading our code!

This folder contains files for the group-specific method (GSM) proposed in:
Bi, Qu, Wang and Shen (2016+) A group-specific recommender system, JASA.

It includes:

DEMO.m — A demo example to illustrate the proposed method. Notice that, parameters K and lambda (and if necessary, m1 and m2) are data-specific and subject to change. The default setting may not be optimal for other datasets.

gsm.m — A function file performing the proposed algorithm, that is, backfitting within alternating least squares. The algorithm can achieve automatic grouping via missing patterns, if prior information about groups is not available.

myridge.m — A sub-function file conducting Ridge regression without normalizing the covariates.

sim_data.txt — A group of simulated data generated following Section 5.1 (Simulation 1) of Bi et al. (2016) paper.


(C) Copyright 2017, Xuan Bi (xuan.bi[at]yale[dot]edu) all rights reserved
The code is provided only for research purposes
Please contact the author should you encounter any problems
Best of Luck!







