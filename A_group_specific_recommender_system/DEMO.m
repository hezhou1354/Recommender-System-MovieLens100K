% (C) Copyright 2017, Xuan Bi (xuan.bi[at]yale[dot]edu) all rights reserved
% The code is provided only for research purposes
% Please contact the author should you encounter any problems
% Best of Luck!

clear
%Please change the working directory to the current folder
base_data = importdata('u1_base.txt',':');  %Simulated data, generated following Simulation 1 of Bi et al. (2016) with missing rate being 95%
test_data = importdata('u1_test.txt',':'); 
n1=max(base_data(:,1));    %number of users
n2=max(base_data(:,2));    %number of items
%N=size(base_data,1);       %sample size
Ntr=size(base_data,1);             %training size
train = base_data;
test = test_data;   %two items in the testing set are not available from the training set

%The core algorithm starts here.
parpool
tic;

K=6;    %K is the number of latent factors; usually ranges from 2-50, highly depending on the data
LAMBDA=10;   %LAMBDA is a vector of tuning parameters for ridge regression, multiple values are supported as illustrated
m1=12;m2=10;    %number of user/item groups, prespecified; have to be >=2, usually around 10;
rng(888);
V1=normrnd(0,0.3,n1,K); %initial values of latent factors for users
V2=normrnd(0,0.3,n2,K); %initial values of latent factors for items
V3=normrnd(0,0.3,m1,K); %initial values for user group effects
V4=normrnd(0,0.3,m2,K); %initial values for item group effects
max_iter=100;   %maximum number of iterations
init={V1,V2,V3,V4,max_iter};

[RMSE_test]=gsm(train,test,LAMBDA,init); %report only the root mean square error on the testing set; cell U in the sub-function gsm.m is the latent factors and group effects

RMSE_test;   %For verification: the result is 1.5641, 1.6806, 1.8487 for the default setting (lambda=2,12,22)

elapsed=toc;
fprintf('Computational time is %0.4f seconds.\n', elapsed);
p=gcp;
delete(p);
