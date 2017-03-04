classdef Force
    %FORCES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        y double
        z double
    end

    methods
        function obj = Force(y, z)
            obj.y = y;
            obj.z = z;
        end
    end
end
