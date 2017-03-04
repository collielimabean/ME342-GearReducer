classdef InputParameters
    %INPUTPARAMETERS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        l_bb1                       double
        l_bb1_p1                    double
        l_bb2_g1                    double
        l_g1_p2                     double
        l_p2_bb3                    double
        l_g2_bb4                    double
        l_bb4                       double
        phi                         double = 14.5
        module                      double
        p1_teeth                    double
        overall_gear_ratio          double
        internal_gear_ratio         double
        input_rpm                   double
        input_power                 double
        design_life                 double
        efficiency                  double
    end
end

