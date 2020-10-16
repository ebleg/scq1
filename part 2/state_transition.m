function [x_new] = state_transition(x, u, par)
    % x = [alpha_arr_k+m ... [alpha_arr_k+1 q_udo1 q_udo2 q_udo3];
    % u = [alpha_enter, C_ud, g_udo, C_udo1, C_udo2, C_udo3]
    
    N = numel(x);
    m = N - 3;
    x_new = nan(size(x));
    
    % Compute required parameters
    q = total_cars(x, par);
    tau = floor((u(2) - q*par.l_veh)/par.N_lane/par.v_free/par.c);
    gamma = mod(u(2) - q*par.l_veh, par.N_lane*par.v_free*par.c);
    
    % Shift all the arrival alpha's to the next time step
    for i = 2:m
        x_new(i) = x(i-1);
    end
    
    % Add newly arrived cars at the appropriate time delay
    x_new(m-tau+1) = x_new(m-tau+1) + (1 + (par.c - gamma)/par.c)*u(1);
    x_new(m-tau) = x_new(m-tau) + gamma/par.c*u(1);
    
    % Add cars that arrive to the queues
    x_new(end-2) = x(end-2) + x(end-3)*par.beta(1)*par.c;
    x_new(end-1) = x(end-1) + x(end-3)*par.beta(2)*par.c;
    x_new(end) = x(end) + x(end-3)*par.beta(3)*par.c;
    
    % Remove cars from the queues
    for i = 1:3
       leaving = min(par.mu(i)*u(3)/par.c, ...
                     x_new(end-3+i)/par.c, ...
                     u(end-3+i)/par.c);
       x_new(end-3+i) = x_new(end-3+i) - leaving;
    end
end

