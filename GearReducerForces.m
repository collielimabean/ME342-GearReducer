classdef GearReducerForces
    %GEARREDUCERFORCES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        R1 Force
        R2 Force
        R3 Force
        R4 Force
        R5 Force
        R6 Force
        Wp1 Force
        Wp2 Force
        Wg1 Force
        Wg2 Force
        input_torque double
        output_torque double
    end
    
    methods
        function obj = solve(obj, g, ip)
            % input torque
            t_in = ip.input_power / (ip.input_rpm * 2 * pi / 60);
            obj.input_torque = t_in;
            
            % gear radii
            rp_1 = g.pitch_diameter(1) / 2;
            rg_1 = g.pitch_diameter(2) / 2;
            rp_2 = g.pitch_diameter(3) / 2;
            rg_2 = g.pitch_diameter(4) / 2;
            
            % solve all force equations
            syms R1_y R1_z R2_y R2_z R3_y R3_z R4_y R4_z R5_y R5_z R6_y R6_z ...
                Wp1_y Wp1_z Wp2_y Wp2_z Wg1_y Wg1_z Wg2_y Wg2_z T_machine
            
            p1 = [
                R1_y + R2_y + Wp1_y == 0,...
                R1_z + R2_z + Wp1_z == 0,...
                R2_y * ip.l_bb1 + Wp1_y * ip.l_bb1_p1 == 0,...
                -R2_z * ip.l_bb1 - Wp1_z * ip.l_bb1_p1 == 0,...
                t_in - Wp1_z * rp_1 == 0,...
                tand(ip.phi) == Wp1_y / Wp1_z
            ];
            
            csg1_p2 = [
                Wp1_y * 0.975 == -Wg1_y,...
                Wp1_z * 0.975 == -Wg1_z,...
                R3_y + Wg1_y + Wp2_y + R4_y == 0,...
                Wg1_y * ip.l_bb2_g1 + Wp2_y * (ip.l_bb2_g1 + ip.l_g1_p2)...
                    + R4_y * (ip.l_bb2_g1 + ip.l_g1_p2 + ip.l_p2_bb3) == 0,...
                R3_z + Wg1_z + Wp2_z + R4_z == 0,...
                -Wg1_z * ip.l_bb2_g1 - Wp2_z * (ip.l_bb2_g1 + ip.l_g1_p2)...
                    - R4_z * (ip.l_bb2_g1 + ip.l_g1_p2 + ip.l_p2_bb3) == 0,...
                Wg1_z * rg_1 + Wp2_z * rp_2 == 0,...
                tand(ip.phi) == -Wp2_y / Wp2_z
            ];
        
            g2 = [
                Wp2_y * 0.975 == -Wg2_y,...
                Wp2_z*0.975 == -Wg2_z,...
                Wg2_y + R5_y + R6_y == 0,...
                R5_y * (ip.l_g2_bb4 - ip.l_bb4) + R6_y * ip.l_g2_bb4 == 0,...
                Wg2_z + R5_z + R6_z == 0,...
                R5_z * (ip.l_g2_bb4 - ip.l_bb4) + R6_z * ip.l_g2_bb4 == 0,...
                T_machine - Wg2_z * rg_2 == 0,...
            ];

            % solve the above monstrosity
            variables = [R1_y R1_z R2_y R2_z R3_y R3_z R4_y R4_z R5_y R5_z R6_y R6_z ...
                    Wp1_y Wp1_z Wp2_y Wp2_z Wg1_y Wg1_z Wg2_y Wg2_z T_machine];

            S = solve(horzcat(p1, csg1_p2, g2), variables, 'ReturnConditions', true); 
            % crash on failure
            if ~S.conditions
                msgID = 'GearReducerForces::SolveError';
                msg = 'Failed to solve for the forces!';
                e = MException(msgID, msg);
                throw(e);
            end
            
            % otherwise, save into properties
            obj.output_torque = -S.T_machine;
            obj.R1 = Force(S.R1_y, S.R1_z);
            obj.R2 = Force(S.R2_y, S.R2_z);
            obj.R3 = Force(S.R3_y, S.R3_z);
            obj.R4 = Force(S.R4_y, S.R4_z);
            obj.R5 = Force(S.R5_y, S.R5_z);
            obj.R6 = Force(S.R6_y, S.R6_z);
            obj.Wp1 = Force(S.Wp1_y, S.Wp1_z);
            obj.Wg1 = Force(S.Wg1_y, S.Wg1_z);
            obj.Wp2 = Force(S.Wp2_y, S.Wp2_z);
            obj.Wg2 = Force(S.Wg2_y, S.Wg2_z);
        end
        
        function generate_diagrams(obj)
        end
    end
    
end

