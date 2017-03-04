classdef Geometry < matlab.mixin.SetGet
    %GEOMETRY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        pitch_diameter = zeros(1, 4)
        pitch = zeros(1, 4)
        num_teeth = zeros(1, 4)
        module double
        circular_pitch = zeros(1, 4)
        addendum = zeros(1, 4)
        dedendum = zeros(1, 4)
        clearance = zeros(1, 4)
        center_dist = zeros(1, 4)
        contact_ratio double
        min_face_width double
        max_face_width double
        thickness = zeros(1, 4)
        gear_speeds = zeros(1, 4) % rpm
    end
    
    methods
        function obj = Geometry(input_params)
            obj.module = input_params.module;
            
            % number of teeth
            obj.num_teeth(1) = input_params.p1_teeth;
            obj.num_teeth(2) = obj.num_teeth(1) * input_params.internal_gear_ratio;
            obj.num_teeth(3) = obj.num_teeth(2) / input_params.internal_gear_ratio;
            obj.num_teeth(4) = obj.num_teeth(3) * input_params.internal_gear_ratio;
            
            % gear speeds
            obj.gear_speeds(1) = input_params.input_rpm;
            obj.gear_speeds(2) = obj.gear_speeds(1) / input_params.internal_gear_ratio;
            obj.gear_speeds(3) = obj.gear_speeds(2);
            obj.gear_speeds(4) = obj.gear_speeds(3) / input_params.internal_gear_ratio;
            
            % compute properties that can be looped
            % formulas taken from original EES code
            % that's honestly more readable anyway
            for i = 1:4
                obj.pitch_diameter(i) = obj.module * obj.num_teeth(i);
                obj.pitch(i) = obj.num_teeth(i) / (39.3701 * obj.pitch_diameter(i)); % convert to 1/in
                obj.circular_pitch(i) = pi * obj.pitch_diameter(i) / obj.num_teeth(i);
                obj.addendum(i) = obj.pitch_diameter(i) / obj.num_teeth(i);
                obj.dedendum(i) = 1.25 * obj.addendum(i);
                obj.clearance(i) = (cosd(input_params.phi) * obj.pitch_diameter(i)) / 2 ...
                    - (obj.pitch_diameter(i) / 2 - obj.dedendum(i));
                obj.thickness(i) = obj.circular_pitch(i) / 2;
            end

            % center distances
            c2c_input_side = mean(obj.pitch_diameter(1:2));
            c2c_output_side = mean(obj.pitch_diameter(3:4));
            obj.center_dist = [c2c_input_side, c2c_input_side, c2c_output_side, c2c_output_side];
            
            % contact ratio
            r_ap = obj.pitch_diameter(1) / 2 + obj.addendum(i);
            r_bp = obj.pitch_diameter(1) * cosd(input_params.phi) / 2;
            r_ag = obj.pitch_diameter(2) / 2 + obj.addendum(2);
            r_bg = obj.pitch_diameter(2) * cosd(input_params.phi) / 2;
            
            obj.contact_ratio = (sqrt(r_ap^2 - r_bp^2) + sqrt(r_ag^2 - r_bg^2) - (c2c_input_side * sind(input_params.phi)))...
                / (obj.circular_pitch(1) * cosd(input_params.phi));
            
            % face widths
            obj.min_face_width = obj.module * 9;
            obj.max_face_width = obj.module * 14;
        end
    end
end

