%% Determine custom parameters
clear; clc; close all;

id_fer = '4362152';
id_emiel = '4446100';

E3 = str2double(id_emiel(end)) + str2double(id_fer(end));
E2 = str2double(id_emiel(end-1)) + str2double(id_fer(end-1));
E1 = str2double(id_emiel(end-2)) + str2double(id_fer(end-2));

data = readtable('measurements.csv');
delta_t = 3600;

q_dot_solar = table2array(data(:, 'q_dot_solar'))*1000;
q_dot_occ = table2array(data(:, 'q_dot_occ'))*1000;
q_dot_ac = table2array(data(:, 'q_dot_ac'))*1000;
q_dot_vent = table2array(data(:, 'q_dot_vent'))*1000;
T_amb = table2array(data(:, 'T_amb')) + 273.15;
T_b = table2array(data(:, 'T_b')) + 273.15;
cost = table2array(data(:, 'Phi'))*1000;

phi = [q_dot_solar, ...
       q_dot_occ + q_dot_ac - q_dot_vent, ...
       T_amb - T_b]*delta_t;

y = diff(T_b);
phi(1, :) = []; % Remove to ensure compatibility with diff array

H = 2*(phi'*phi);
c = -2*phi'*y;

qpoptions = optimoptions('quadprog', 'Display', 'none', 'Algorithm', 'interior-point-convex');

A = [1 0 0; -1 0 0]; b = [0.99 0.99]';
[a, error, flag, ~] = quadprog(H, c, A, b, [], [], [], [], [], qpoptions);

error = error + y'*y;

%% Second question
% Parameters
q_ac_max = 100000; 
T_b1 = 22.43;
N = 2160;
T_min = 15 + 273.15;  
T_max = 28 + 273.15;
Tref = 22 + 273.15;
alpha = 0.1 + E2/10;

H = [eye(N) zeros(N, N); zeros(N, 2*N)]*alpha;
c = [repmat(-2*alpha, N, 1); cost*delta_t];
Aeq = [eye(N) zeros(N, N)] ...
    - [[zeros(1, N); [eye(N-1)*(1 - delta_t*a(3)),  zeros(N-1, 1)]] eye(N)*a(2)*delta_t];
beq = (a(1)*q_dot_solar + a(2)*(q_dot_occ - q_dot_vent) + a(3)*T_amb)*delta_t;
ub = [repmat(T_max, N, 1); repmat(q_ac_max, N, 1)];
lb = [repmat(T_min, N, 1); zeros(N, 1)];

[x, fval, flag, ~] = quadprog(H, c, [], [], Aeq, beq, lb, ub, [], qpoptions);


