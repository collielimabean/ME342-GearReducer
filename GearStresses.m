classdef GearStresses
    %GEARSTRESSES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        input_shaft Stress
        countershaft Stress
        output_shaft Stress
        
        % model will get more complicated due to fillets
        d_input_shaft double
        d_countershaft double
        d_output_shaft double
    end
    
    methods
        function obj = GearStresses(forces, ip, g)
            % create symbols
            % equations
            % solve it
            
        end
    end
end

