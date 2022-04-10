% (C) Copyright 2017, Xuan Bi (xuan.bi[at]yale[dot]edu) all rights reserved
% The code is provided only for research purposes
% Please contact the author should you encounter any problems
% Best of Luck!
function betahat = myridge(K,y,x,lambda)
if isempty(y);
    betahat=zeros(K,1);
else
    betahat=(x.'*x+lambda*eye(K))\(x.'*y);
end
end

   