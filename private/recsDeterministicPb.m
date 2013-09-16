function [F,J,grid] = recsDeterministicPb(X,fp,gp,hp,s0,xss,p,e,params,nx,grid)
% RECSDETERMINISTICPB Evaluates the equations and Jacobian of the deterministic problem.
%
% RECSDETERMINISTICPB is called by recsSolveDeterministicPb. It is not meant to be
% called directly by the user.
%
% See also RECSSOLVEDETERMINISTICPB.

% Copyright (C) 2011-2013 Christophe Gouel
% Licensed under the Expat license, see LICENSE.txt

%% Initialization
d = size(s0,2);
m = size(xss,2);

n = size(X,1);
M = m+sum(nx);
T = n/(M+p+d);

e = e(ones(T,1),:);

X = reshape(X,M+p+d,T)';

x     = X(:,1:m);
xnext = [x(2:end,:); xss];
w     = X(:,(m+1):(m+nx(1)));
v     = X(:,(m+nx(1)+1):M);
z     = X(:,(M+1):(M+p));
snext = X(:,(M+p+1):(M+p+d));
s     = [s0; snext(1:end-1,:)];

%% Computation of equations and Jacobian
if nargout>=2  
  %% With Jacobian
  [f,fs,fx,fz]              = fp(s,x,w,v,z,params,ones(4,1));
  [h,hs,hx,~,hsnext,hxnext] = hp(s,x,e,snext,xnext,params,[1 1 1 0 1 1]);
  [g,gs,gx]                 = gp(s,x,e,params,[1 1 1 0]);

  identityz = eye(p);
  identityz = permute(identityz(:,:,ones(1,T)),[3 1 2]);
  identitys = eye(d);
  identitys = permute(identitys(:,:,ones(1,T)),[3 1 2]);
  Jmd = cat(3,...
            cat(2,fx,-hx,-gx),...
            cat(2,fz,identityz,zeros(T,d,p)),...
            cat(2,zeros(T,M,d),-hsnext,identitys));
  Jsub = cat(3,...
             zeros(T-1,M+p+d,M+p),...
             cat(2,fs(2:end,:,:),-hs(2:end,:,:),-gs(2:end,:,:)));
  Jsup = cat(3,...
             cat(2,zeros(T-1,M,M),-hxnext(1:end-1,:,:),zeros(T-1,d,M)),...
             zeros(T-1,M+p+d,p+d));

  [J,grid] = blktridiag(permute(Jmd ,[2 3 1]),...
                        permute(Jsub,[2 3 1]),...
                        permute(Jsup,[2 3 1]),...
                        [],grid);

else
  %% Without Jacobian
  h = hp(s,x,e,snext,xnext,params,[1 0 0 0 0 0]);
  f = fp(s,x,w,v,z,params,[1 0 0 0]);
  g = gp(s,x,e,params,[1 0 0 0]);

end
F = [f z-h snext-g]';
F = reshape(F,n,1);