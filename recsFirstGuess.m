function [interp,x,z] = recsFirstGuess(interp,model,s,sss,xss,T,options)
% RECSFIRSTGUESS finds a first guess using the perfect foresight solution
%
% RECSFIRSTGUESS tries to find a first-guess for the rational expectations model
% by solving the corresponding perfect foresight solution on all the grid points
% of the state variables. By default, it considers that the model goes back to
% its deterministic steady state in 50 periods.
%
% INTERP = RECSFIRSTGUESS(INTERP,MODEL,S,SSS,XSS) uses the interpolation structure
% defined in the structure INTERP to fit the perfect foresight solution of the
% model defined in the structure MODEL. The grid of state variables is provided in
% the n-by-d matrix S. A first guess for the steady state of the model is provided
% in SSS and XSS for state and response variables. RECSFIRSTGUESS returns an
% interpolation structure, INTERP, containing the first guess.
% INTERP is a structure, which has to include the following fields:
%    fspace       : a definition structure for the interpolation family (created
%                   by the function fundef)
% MODEL is a structure, which has to include the following fields:
%    [e,w]  : discrete distribution with finite support with e the values and w the
%             probabilities (it could be also the discretisation of a continuous
%             distribution through quadrature or Monte Carlo drawings)
%    func   : function name or anonymous function that defines the model's equations
%    params : model's parameters, it is preferable to pass them as a cell array
%             but other formats are acceptable
%
% INTERP = RECSFIRSTGUESS(INTERP,MODEL,S,SSS,XSS,T) uses T (integer) for time horizon.
%
% INTERP = RECSFIRSTGUESS(INTERP,MODEL,S,SSS,XSS,T,OPTIONS) solves the problem with the
% parameters defined by the structure OPTIONS. The fields of the structure are
%    eqsolver         : 'fsolve', 'lmmcp' (default), 'ncpsolve' or 'path'
%    eqsolveroptions  : options structure to be passed to eqsolver (default:
%                       empty structure)
%
% [INTERP,X] = RECSFIRSTGUESS(INTERP,MODEL,S,SSS,XSS,...) returns X, n-by-m matrix,
% containing the value of the response variables in the first period.
%
% [INTERP,X,Z] = RECSFIRSTGUESS(INTERP,MODEL,S,SSS,XSS,...) returns Z, n-by-p matrix,
% containing the value of the expectations variables in the first period.
%
% See also RECSSOLVEDETERMINISTICPB, RECSSOLVEREE, RECSSS.

% Copyright (C) 2011-2012 Christophe Gouel
% Licensed under the Expat license, see LICENSE.txt

%% Initialization
if nargin <=5 || isempty(T), T = 50; end
if nargin <=6, options = struct([]); end

if isa(model.func,'char')
  model.func = str2func(model.func);
elseif isa(model.func,'function_handle')
  model.func = model.func;
else
  error('model.func must be either a string or a function handle')
end

interp.Phi = funbasx(interp.fspace);

%% Solve for the deterministic steady state
[sss,xss,zss] = recsSS(model,sss,xss,options);

n = size(s,1);
x = zeros(n,size(xss,2));
z = zeros(n,size(zss,2));

%% Solve the perfect foresight problem on each point of the grid
parfor i=1:n
  [X,~,Z] = recsSolveDeterministicPb(model,s(i,:),T,xss,zss,sss,options);
  x(i,:) = X(1,:);
  z(i,:) = Z(1,:);
end

%% Prepare output
interp.cx = funfitxy(interp.fspace,interp.Phi,x);
interp.cz = funfitxy(interp.fspace,interp.Phi,z);

% Check if it is possible to approximate the expectations function
params = model.params;
func   = model.func;
if ~isfield(interp,'ch')
  e      = model.e;
  K      = size(e,1);
  ind    = (1:n);
  ind    = ind(ones(1,K),:);
  ss     = s(ind,:);
  xx     = x(ind,:);
  ee     = e(repmat(1:K,1,n),:);

  output = struct('F',1,'Js',0,'Jx',0);
  snext = func('g',ss,xx,[],ee,[],[],params,output);
  xnext = funeval(interp.cx,interp.fspace,snext);

  output    = struct('F',0,'Js',1,'Jx',1,'Jsn',0,'Jxn',0,'hmult',0);
  [~,hs,hx] = func('h',ss,xx,[],ee,snext,xnext,params,output);

  output = struct('F',1,'Js',0,'Jx',0,'Jsn',0,'Jxn',0,'hmult',0);
  if size(ss,1)>100;
    i = unique(randi(size(ss,1),100,1));
  else
    i = 1:size(ss,1);
  end
  he     = numjac(@(E) reshape(func('h',ss(i,:),xx(i,:),[],E,snext(i,:),xnext(i,:),...
                                    params,output),[],1),ee(i,:));
end

% Calculate the approximation of the expectations function (if possible)
if isfield(interp,'ch') || abs(norm(hs(:),Inf)+norm(hx(:),Inf)+norm(he(:),Inf))<eps
  output    = struct('F',1,'Js',0,'Jx',0,'Jsn',0,'Jxn',0,'hmult',0);
  h         = func('h',[],[],[],[],s,x,params,output);
  interp.ch = funfitxy(interp.fspace,interp.Phi,h);
end

