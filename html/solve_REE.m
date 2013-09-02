%% Solve the stochastic rational expectations problem

%% The function |recsSolveREE|
% Once <ug_model_struct.html the model>, <ug_interpolation.html the
% interpolation> structure and <first_guess.html a first guess solution> have
% been defined, it is possible to attempt to find the rational expectations
% equilibrium of the model. This is achieved by the function
% <matlab:doc('recsSolveREE') |recsSolveREE|>.
%
% This is done by the following call
%
%  [interp,x] = recsSolveREE(interp,model,s,x,options);
%
% This function call returns the interpolation structure |interp| with new or
% updated fields. Following a successful run of |recsSolveREE|, the fields |cx|
% and |cz| are created or updated in |interp|. They represent the response and
% expectations variables interpolation coefficients, respectively. These
% coefficients are sufficient to <simulate.html simulate the model>. The second
% output is the matrix |x| of response variables on the grid.
%
% The |options| structure defines <solution_methods.html the methods used to
% find the rational expectations equilibrium>, as well as other aspects of the
% solution process (see <ug_options.html Options> for details on available
% options).
%
%% An example
%
% *First guess provided by RECS*
%
% If the first guess is generated by the function |recsFirstGuess|, |interp|
% already includes the fields |cx|, |cz|, and |x| corresponding, respectively,
% to the first-guess coefficients of interpolation of response variables, of
% expectations variables, and the first-guess values of response variables, so
% it is not necessary to supply the value of the response variables on the
% grid. For the stochastic growth model, finding the first guess and solving the
% model involves the following call:
%
interp = recsFirstGuess(interp,model);
interp = recsSolveREE(interp,model);

%%
% *User-provided first guess*
%
% If the first guess is provided by the user. The user needs to provide an
% n-by-m matrix |x| that contains the values of the m response variables for the
% n points on the grid of state variable.
%
% For our example, let us first remove the solution from the |interp| structure
% from the previous solve:
interp = rmfield(interp,{'cx','cz'});

%%
% Then we take a very simple first guess: consumption is equal to one-fifth of
% capital stock:
x      = s(:,1)/5;
interp = recsSolveREE(interp,model,s,x);

%%
% With this simple model, even a naive first guess allows the solver to find the
% solution, however it significantly decreases the precision of the first
% iteration, and so increases the number of iterations.

%% See also
% <matlab:doc('recsSolveREE') |recsSolveREE|>.
