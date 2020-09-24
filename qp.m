%% Determine custom parameters
clear; clc; close all;

id_fer = '4362152';
id_emiel = '4446100';

E3 = str2double(id_emiel(end)) + str2double(id_fer(end));
E2 = str2double(id_emiel(end-1)) + str2double(id_fer(end-1));
E1 = str2double(id_emiel(end-2)) + str2double(id_fer(end-2));

data = readtable('measurements.csv');
delta_t = 3600; 

phi = [table2array(data(:, 'q_dot_solar')), ...
       table2array(data(:, 'q_dot_occ')) + table2array(data(:, 'q_dot_ac')) - table2array(data(:, 'q_dot_vent')), ...
       table2array(data(:, 'T_amb')) - table2array(data(:, 'T_b'))]*delta_t;

y = diff(table2array(data(:, 'T_b')));
phi(1, :) = []; % Remove to ensure compatibility with diff array

H = 2*(phi'*phi);
c = -2*phi'*y;

qpoptions = optimoptions('quadprog', 'Display', 'none', 'Algorithm', 'interior-point-convex');

A = [1 0 0; -1 0 0]; b = [0.99 0.99]';
[x, error, flag, ~] = quadprog(H, c, A, b, [], [], [], [], [], qpoptions);

error = error + y'*y;
