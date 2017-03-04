%% main.m
% Purpose: Entry point for the project
clear; close all; clc;

%% Configuration
input_params = InputParameters;
input_params.l_bb1 = 30e-3; % m
input_params.l_bb1_p1 = 60e-3; % m
input_params.l_bb2_g1 = 50e-3; % m
input_params.l_g1_p2 = 50e-3; % m
input_params.l_p2_bb3 = 50e-3; % m
input_params.l_g2_bb4 = 60e-3; % m
input_params.l_bb4 = 30e-3; % m
input_params.phi = 14.5; % deg
input_params.module = 2e-3; % m              
input_params.p1_teeth = 22; % -      
input_params.overall_gear_ratio = 9; % -
input_params.internal_gear_ratio = 3; % -
input_params.input_rpm = 1200; % rpm
input_params.input_power = 1000; % Watts
input_params.design_life = 14000; % hours
input_params.efficiency = 0.95; % -

% selected parameters
safety_factor = 1.5; % -
material = 'AISI 1030';
yield_str = 344.7e6; % Pa

SHOW_FORCE_DIAGRAMS = false;

%% Part A
geometry = Geometry(input_params);

gear_forces = GearReducerForces;
gear_forces = gear_forces.solve(geometry, input_params);

if SHOW_FORCE_DIAGRAMS
    generate_diagrams(gear_forces, input_params);   
end

%% Part B

