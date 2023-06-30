function leftTemp = transientBCHeatedBlock(~, state)
%boundaryFileHeatedBlock Temperature boundary conditions for heated block example
% Temperature boundary condition is defined on the left edge of the block
% in the heated block example.
%
% loc   - application region struct passed in for information purposes
% state - solution state struct passed in for information purposes

% Copyright 2014-2016 The MathWorks, Inc.

% The temperature returned depends on the solution time.
if(isnan(state.time))
  % Returning a NaN for any component of q, g, h, r when time=NaN
  % tells the solver that the boundary conditions are functions of time.
  % The PDE Toolbox documentation discusses this requirement in more detail.
  leftTemp = NaN;
elseif(state.time <= .5)
  % From time=0 to time=.5, the temperature ramps from zero to 100.
  leftTemp = 100*state.time/.5;
else
  % For time > .5, the temperature is fixed at 100
  leftTemp = 100;
end
end