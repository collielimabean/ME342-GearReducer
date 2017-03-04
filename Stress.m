classdef Stress
    %STRESS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        sigma_y double
        sigma_z double
        tau double
        
        principle = zeros(1, 3)
    end
    
    methods
        function obj = Stress(sigma_y, sigma_z, tau)
            obj.sigma_y = sigma_y;
            obj.sigma_z = sigma_z;
            obj.tau = tau;
            
            % todo: compute principle stresses
        end
    end
end

