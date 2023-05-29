function stateDot = helperTimeBasedStateInputsKINOVA(obj, timeInterval, jointStates, t, state)
    % Copyright 2020 The MathWorks, Inc.

    targetState = interp1(timeInterval, jointStates, t);
    
    % Compute state derivative
    stateDot = derivative(obj, state, targetState);
end
