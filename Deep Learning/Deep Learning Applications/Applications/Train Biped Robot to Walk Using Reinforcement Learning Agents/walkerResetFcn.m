% Helper function to reset walking robot simulation with different initial conditions
%
% Copyright 2019 The MathWorks, Inc.

function in = walkerResetFcn(in,upper_leg_length,lower_leg_length,init_height)
    
    % Randomization Parameters
    % Note: Y-direction parameters are only used for the 3D walker model
    max_displacement_x = 0.05;
    max_speed_x = 0.05;
    max_displacement_y = 0.025;
    max_speed_y = 0.025;
    
    % Chance of randomizing initial conditions
    if rand < 0.5
        if rand < 0.5
            in = in.setVariable('vx0',2*max_speed_x *(rand-0.5));
            in = in.setVariable('vy0',2*max_speed_y *(rand-0.5));
        else
            in = in.setVariable('vx0',0);
            in = in.setVariable('vy0',0);
        end
        
        leftinit =  [(rand(2,1)-[0.5;0]).*[2*max_displacement_x; max_displacement_y]; -init_height];              
        rightinit = [-leftinit(1:2) ; -init_height]; % Ensure feet are symmetrically positioned for stability                
        
    % Chance of starting from zero initial conditions
    else
        in = in.setVariable('vx0',0); 
        in = in.setVariable('vy0',0);
        leftinit = [0;0;-init_height];
        rightinit = [0;0;-init_height];
    end
    
    init_angs_L = zeros(1,2);
    theta = legInvKin(upper_leg_length,lower_leg_length,-leftinit(1),leftinit(3));
    % Address multiple outputs
    if size(theta,1) == 2
       if theta(1,2) < 0
          init_angs_L(1) = theta(2,1);
          init_angs_L(2) = theta(2,2);
       else
          init_angs_L(1) = theta(1,1);
          init_angs_L(2) = theta(1,2);
       end
    end       
    in = in.setVariable('leftinit',leftinit);
    in = in.setVariable('init_angs_L',init_angs_L);

    init_angs_R = zeros(1,2);
    theta = legInvKin(upper_leg_length,lower_leg_length,-rightinit(1),rightinit(3));
    % Address multiple outputs
    if size(theta,1) == 2
       if theta(1,2) < 0
          init_angs_R(1) = theta(2,1);
          init_angs_R(2) = theta(2,2);
       else
          init_angs_R(1) = theta(1,1);
          init_angs_R(2) = theta(1,2);
       end
    end       
    in = in.setVariable('rightinit',rightinit);
    in = in.setVariable('init_angs_R',init_angs_R); 
    
end