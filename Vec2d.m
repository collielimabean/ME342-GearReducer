classdef Vec2d  < matlab.mixin.SetGet
    %VEC2D Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        y double
        z double
    end

    methods
        function obj = Vec2d(y, z)
            obj.y = y;
            obj.z = z;
        end
        
        function str = disp(obj)
            str = sprintf('Y: %4.2f Z: %4.2f', obj.y, obj.z);
        end
        
        function m = magnitude(obj)
            m = sqrt(obj.y^2 + obj.z^2);
        end
    end
end

