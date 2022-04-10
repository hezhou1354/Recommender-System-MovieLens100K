% (C) Copyright 2017, Xuan Bi (xuan.bi[at]yale[dot]edu) all rights reserved
% The code is provided only for research purposes
% Please contact the author should you encounter any problems
% Best of Luck!
function [RMSE_test]= gsm(train,test,LAMBDA,init,user_group,item_group)
%backfitting within alternating least squares

n1=size(init{1},1);    %number of users
n2=size(init{2},1);    %number of items
m1=size(init{3},1);    %number of user groups
m2=size(init{4},1);    %number of item groups
K=size(init{1},2);     %number of latent factors
Ntr=size(train,1);     %training size

if nargin < 5
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%GROUPING
%If group information is known, for example users' age, gender or location,
%and items' categories or genres,
%then please input group labels as user_group and item_group in the
%function arguments, following the format below.
%Otherwise, the following code will assign group labels automatically.

%This part assigns group labels based on the missing data pattern,
%which is discussed in Bi et al. (2016).

fprintf('Grouping ');
nr_user=accumarray(int64(train(:, 1)),ones(Ntr,1)); %number of ratings from each user
nr_item=accumarray(int64(train(:, 2)),ones(Ntr,1)); %number of ratings from each item
nr_user=[nr_user;zeros(n1-size(nr_user,1),1)];
nr_item=[nr_item;zeros(n2-size(nr_item,1),1)];
qt_user=quantile(nr_user,[0:m1]/m1);    %use quantiles as a criterion for grouping
qt_item=quantile(nr_item,[0:m2]/m2);

user_group=zeros(n1,1);
item_group=zeros(n2,1);
fprintf('users ');
for i=1:m1
user_group=user_group+i*(nr_user>=qt_user(i) & nr_user<qt_user(i+1));
end
user_group=user_group+m1*(nr_user==qt_user(m1+1));
fprintf('and items...');
for j=1:m2
item_group=item_group+j*(nr_item>=qt_item(j) & nr_item<qt_item(j+1));
end
item_group=item_group+m2*(nr_item==qt_item(m2+1));
fprintf('DONE\n');
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %


fprintf('Pre-calculating the index...');
P1 = int64(train(:, 1));
P2 = int64(train(:, 2));
fprintf('P1');P1_bag = accumarray(P1(:), 1:length(P1), [n1, 1], @(x){x});
fprintf('P2');P2_bag = accumarray(P2(:), 1:length(P2), [n2, 1], @(x){x});
G1 = int64(user_group(train(:, 1)));
G2 = int64(item_group(train(:, 2)));
fprintf('G1');G1_bag = accumarray(G1(:), 1:length(G1), [m1, 1], @(x){x});
fprintf('G2');G2_bag = accumarray(G2(:), 1:length(G2), [m2, 1], @(x){x});
fprintf('. complete.\n');

y1_bag=cell(1,n1);x1_bag=cell(1,n1);
y2_bag=cell(1,n2);x2_bag=cell(1,n2);
y3_bag=cell(1,m1);x3_bag=cell(1,m1);
y4_bag=cell(1,m2);x4_bag=cell(1,m2);

N2=size(LAMBDA,2);
RMSE_test=zeros(1,N2);
    
for l=1:N2
      
lambda=LAMBDA(l);

U=init;
V=U;

iter=1;
diff.all=1;
while diff.all>1e-3
    fprintf('-Iter%d.\n', iter);
V1=U{1}; %users
V2=U{2}; %items
V3=U{3}; %user groups
V4=U{4}; %item groups
diff.user=1;
diff.item=1;

fprintf('Updating items...');
X.user=V1(train(:,1),:)+V3(G1,:);

while diff.item>1e-5
    y=train(:,3)-sum(X.user.*V4(G2,:),2);
for i=1:n2
    y2_bag{i}=y(P2_bag{i});
    x2_bag{i}=X.user(P2_bag{i},:);
end
parfor i=1:n2
    V2(i,:)=myridge(K,y2_bag{i},x2_bag{i},lambda);
end

    y=train(:,3)-sum(X.user.*V2(train(:,2),:),2);
for i=1:m2
    y4_bag{i}=y(G2_bag{i});
    x4_bag{i}=X.user(G2_bag{i},:);
end
parfor i=1:m2
    V4(i,:)=myridge(K,y4_bag{i},x4_bag{i},lambda);
end

diff.item=sum(sum((V2-V{2}).^2))/n2/K+sum(sum((V4-V{4}).^2))/m2/K;
%fprintf('%d.\n', diff.item); %This reports the status in the inner loop
V{2}=V2;V{4}=V4;
end
    fprintf('DONE\n');
    fprintf('Updating users...');
    X.item=V2(train(:,2),:)+V4(G2,:);
while diff.user>1e-5
    y=train(:,3)-sum(X.item.*V3(G1,:),2);
for i=1:n1
    y1_bag{i}=y(P1_bag{i});
    x1_bag{i}=X.item(P1_bag{i},:);
end
parfor i=1:n1
    V1(i,:)=myridge(K,y1_bag{i},x1_bag{i},lambda);
end

    y=train(:,3)-sum(X.item.*V1(train(:,1),:),2);
for i=1:m1
    y3_bag{i}=y(G1_bag{i});
    x3_bag{i}=X.item(G1_bag{i},:);
end
parfor i=1:m1
    V3(i,:)=myridge(K,y3_bag{i},x3_bag{i},lambda);
end

diff.user=sum(sum((V1-V{1}).^2))/n1/K+sum(sum((V3-V{3}).^2))/m1/K;
%fprintf('%d.\n', diff.user); %This reports the status in the inner loop
V{1}=V1;V{3}=V3;
end
    fprintf('DONE\n');
diff.all=sum(sum((U{1}+U{3}(user_group,:)-V{1}-V{3}(user_group,:)).^2))/n1/K+...
    sum(sum((U{2}+U{4}(item_group,:)-V{2}-V{4}(item_group,:)).^2))/n2/K;
fprintf('Improvement is %d.\n', diff.all);
U=V;
iter=iter+1;
if(iter>init{5})
fprintf('Not converged; maximum number of iterations achieved!\n');
break
end
end

rmse_te=sqrt(mean((test(:,3)-sum((U{1}(test(:,1),:)+U{3}(user_group(test(:,1)),:)).*...
    (U{2}(test(:,2),:)+U{4}(item_group(test(:,2)),:)),2)).^2));
fprintf('RMSE is %0.4f on the testing set when K=%d and lambda=%d.\n',rmse_te,K,LAMBDA(l));

RMSE_test(l)=rmse_te;
end

    end
