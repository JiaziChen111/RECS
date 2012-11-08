%% Solve the stochastic rational expectations problem

%% The function |recsSolveREE|
% Once <ug_model_struct.html the model>, <ug_interpolation.html the
% interpolation> structure and <first_guess.html a first guess of the solution>
% have been defined, it is possible to attempt to find the rational expectations
% equilibrium of the model. This is achieved by the function |recsSolveREE|.
%
% This is done by the following call
%
%  [interp,x] = recsSolveREE(interp,model,s,x,options);
%
% This function call returns the interpolation structure |interp| with new or
% updated fields. Following a succesfull run of |recsSolveREE|, the fields |cx|
% and |cz| are created or updated in |interp|. They represent the interpolation
% coefficients of response and expectations variables, respectively. These
% coefficients are sufficient to <simulate.html simulate the model>. The second
% output is the matrix |x| of response variables on the grid.
% 
% The |options| structure define <ug_methods.html the methods used to find the
% rational expectations equilibrium>.
%
%% An example
%
% *First guess from the corresponding deterministic problem*
%
% If the first guess has been generated by the function |recsFirstGuess|,
% |interp| already include fields of coefficients |cx| and |cz| corresponding to
% this first guess, so it is not necessary to supply the value of response
% variables on the grid. For the stochastic growth model, finding the first
% guess and solving the model would involve the following call:
%
interp = recsFirstGuess(interp,model,s);
interp = recsSolveREE(interp,model,s);

%%
% *User-provided first guess*
%
% For a first guess provided by the user, there is no need to have the fields
% |cx| or |cz| in |interp|. The user has just to provide a n-by-m matrix |x|
% that contains the values of the m response variables for the n points on the
% grid of state variable.
%
% For our example, let's first remove the solution from the |interp| structure
% from the previous solve:
interp = rmfield(interp,{'cx','cz'});

%% 
% Then we take a very simple first guess: consumption is equal to one-fifth of
% capital stock:
x      = s(:,1)/5;
interp = recsSolveREE(interp,model,s,x);

%%
% With this simple model, even a naive first guess is sufficient for the solver
% to find the solution, but one can note that it decreases significantly the
% precision of the first iteration, and so increases the number of iterations.

%% See also
% <matlab:doc('recsSolveREE') |recsSolveREE|>.
