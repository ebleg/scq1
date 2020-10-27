% addpath('bfgs');
% 
% close all; clear; clc;
% 
% run parameters
% run defaultPlotSettings
% 
% u0 = repmat(15, 60, 1);
% x0 = zeros(8, 1);
% lb = repmat(15, 60, 1);
% ub = repmat(45, 60, 1);
% tic
% % % Time the cost function for reference
% % t1 = toc;
% % for i = 1:50
% %     x = J(u0, x0, par);
% % end
% % t2 = toc;
% % fprintf('Average cost function evaluation time: %fs\n', (t2-t1)/1000);
% %     
% %% Default SQP solution
% sqp_sol = struct();
% sqp_sol.settings = optimoptions(@fmincon, 'Algorithm', 'sqp', ...
%                     'MaxFunctionEvaluations', 10000, 'Display', 'off');
%                 
% [sqp_sol.u, sqp_sol.fval, sqp_sol.exitflag] = ...
%     fmincon(@(u) J(u, x0, par), u0, [], [], [], [], lb, ub, [], sqp_sol.settings);
%                                        
% fprintf('SQP solution --> total cost %f\n', sqp_sol.fval);
% 
% %% Interior-point solution
% ip_sol = struct();
% ip_sol.settings = optimoptions(@fmincon, 'Algorithm', 'interior-point', ...
%                          'MaxFunctionEvaluations', 10000, 'Display', 'off');
%                      
% [ip_sol.u, ip_sol.fval, ip_sol.exitflag] = ...
%     fmincon(@(u) J(u, x0, par), u0, [], [], [], [], lb, ub, [], ip_sol.settings);
%                                        
% fprintf('Interior-point solution --> total cost %f\n', ip_sol.fval);
% 
% %% Simulated annealing
% sa_sol = struct();
% sa_sol.settings = optimoptions(@simulannealbnd, ...
%           'MaxFunctionEvaluations', 30000, 'Display', 'off');
% 
% [sa_sol.u, sa_sol.fval, sa_sol.exitflag] = ...
%     simulannealbnd(@(u) J(u, x0, par), u0, lb, ub);
% 
% fprintf('Simulated annealing solution --> total cost %f\n', sa_sol.fval);
% 
% %% Integer Genetic Algorithm 
% lb = ones(1, 60);      % Lower bound representing the first discrete values in the set
% ub = repmat(7, 60, 1); % Number of discrete values in set
% 
% ga_sol = struct();
% ga_sol.settings = optimoptions(@ga, ...
%                     'PopulationSize', 150, ...
%                     'MaxGenerations', 600, ...
%                     'EliteCount', 10, ...
%                     'FunctionTolerance', 1e-8, ...
%                     'PlotFcn', @gaplotbestf);
%                                 
% rng(0, 'twister');
% [ga_sol.u, ga_sol.fval, ga_sol.exitflag] = ga(@(u)J(u, x0, par), ...  
%    60, [], [], [], [], lb, ub,[],[], ga_sol.settings);

close all; clear; clc;

run parameters
run defaultPlotSettings

u0 = repmat(45, 60, 1);
x0 = zeros(8, 1);
lb = repmat(15, 60, 1);
ub = repmat(45, 60, 1);

% %% Time the cost function for reference
% t1 = toc;
% for i = 1:50
%     x = J(u0, x0, par);
% end
% t2 = toc;
% fprintf('Average cost function evaluation time: %fs\n', (t2-t1)/50);
% %%

%% Default SQP solution
tic
sqp_sol = struct();
sqp_sol.settings = optimoptions(@fmincon, 'Algorithm', 'sqp', ...
                    'MaxFunctionEvaluations', 10000, 'Display', 'off');
                
[sqp_sol.u, sqp_sol.fval, sqp_sol.exitflag] = ...
    fmincon(@(u) J(u, x0, par), u0, [], [], [], [], lb, ub, [], sqp_sol.settings);
                                       
fprintf('SQP solution --> total cost %f\n', sqp_sol.fval);
toc
% 
% %% Interior-point solution
% ip_sol = struct();
% ip_sol.settings = optimoptions(@fmincon, 'Algorithm', 'interior-point', ...
%                          'MaxFunctionEvaluations', 10000, 'Display', 'off');
%                      
% [ip_sol.u, ip_sol.fval, ip_sol.exitflag] = ...
%     fmincon(@(u) J(u, x0, par), u0, [], [], [], [], lb, ub, [], ip_sol.settings);
%                                        
% fprintf('Interior-point solution --> total cost %f\n', ip_sol.fval);

%% Simulated annealing
sa_sol = struct();
sa_sol.settings = optimoptions(@simulannealbnd, ...
          'MaxFunctionEvaluations', 30000, 'Display', 'off');

[sa_sol.u, sa_sol.fval, sa_sol.exitflag] = ...
    simulannealbnd(@(u) J(u, x0, par), u0, lb, ub);

fprintf('Simulated annealing solution --> total cost %f\n', sa_sol.fval);


%% Plot input
clear; clc; close all;
load('ga_sol.mat');

t = 1:60;
sqp_sol_45 = load('nlp_results\sqp_sol_45.mat');
sqp_sol_15 = load('nlp_results\sqp_sol_15.mat');
sa_sol_45 = load('nlp_results\sa_sol_45.mat');
sa_sol_15 = load('nlp_results\sa_sol_15.mat');
ip_sol_45 = load('nlp_results\ip_sol_45.mat');
ip_sol_15 = load('nlp_results\ip_sol_15.mat');

sqp_sol_45 = sqp_sol_45.sqp_sol;
sqp_sol_15 = sqp_sol_15.sqp_sol;
sa_sol_45 = sa_sol_45.sa_sol;
sa_sol_15 = sa_sol_15.sa_sol;
ip_sol_45 = ip_sol_45.ip_sol;
ip_sol_15 = ip_sol_15.ip_sol;

figure;
hold on;

tile = tiledlayout(2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile; hold on;
title('Initialized at 15s')
plot(t, sa_sol_15.u, 'DisplayName', 'Simulated annealing');
plot(t, sqp_sol_15.u, 'DisplayName', 'Sequential Quadratic Programming');
plot(t, ip_sol_15.u, 'DisplayName', 'Interior-point');

nexttile; hold on;
title('Initialized at 45s')
plot(t, sa_sol_45.u, 'DisplayName', 'Simulated annealing');
plot(t, sqp_sol_45.u, 'DisplayName', 'Sequential Quadratic Programming');
plot(t, ip_sol_45.u, 'DisplayName', 'Interior-point');
plot(t, ga_sol.u_map, 'DisplayName', 'Genetic algorithm');
lgd = legend(gca);

lgd.Orientation = 'horizontal';
lgd.Layout.Tile = 'south';

title(tile, '\textbf{Solution comparison be different algorithms}', 'interpreter', 'latex');
ylabel(tile, 'Green light time [s]', 'interpreter', 'latex');
xlabel(tile, 'Time [min]', 'interpreter', 'latex');


%% Plot results
close all; figure;
% plot_traffic_simulation(gcf, sa_sol_15.u, x0, 'Simulated annealing (15s)', par);
% plot_traffic_simulation(gcf, sqp_sol_15.u, x0, 'SQP (15s)', par);
% plot_traffic_simulation(gcf, ip_sol_15.u, x0, 'Interior-point (15s)', par);
plot_traffic_simulation(gcf, sa_sol_15.u, x0, 'Simulated annealing (15s)', par);
plot_traffic_simulation(gcf, sqp_sol_15.u, x0, 'SQP (15s)', par);
plot_traffic_simulation(gcf, ip_sol_15.u, x0, 'Interior-point (15s)', par);
plot_traffic_simulation(gcf, repmat(30, 60, 1), x0, 'No control', par);
plot_traffic_simulation(gcf, ga_sol.u_map, x0, 'Genetic Algorithm', par);

% rng(0, 'twister');
% [ga_sol.u, ga_sol.fval, ga_sol.exitflag] = ga(@(u)J_disc(u, x0, par), ...    
%     60, [], [], [], [], lb, ub, [],1:60 , ga_sol.settings);
% 
% ga_sol.u_map = mapvariables(ga_sol.u);
% 
% fprintf('Integer Genetic Algorithm solution --> total cost %f\n', ga_sol.fval):
% 

