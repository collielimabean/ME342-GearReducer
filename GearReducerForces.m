classdef GearReducerForces < matlab.mixin.SetGet
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
        % note: shears for input/output shaft omitted as they are simple
        V_cs_input % countershaft, input side
        V_cs_output % countershaft, output side
        M_input Moment
        M_cs_input Moment % countershaft, input side
        M_cs_output Moment % countershaft, output side
        M_output Moment
        T_input double
        T_cs double
        T_output double
    end
    
    methods
        function obj = solve(obj, g, ip)
            % input torque
            t_in = ip.input_power / (ip.input_rpm * 2 * pi / 60);
            obj.T_input = t_in;
            
            % gear radii
            rp_1 = g.pitch_diameter(1) / 2;
            rg_1 = g.pitch_diameter(2) / 2;
            rp_2 = g.pitch_diameter(3) / 2;
            rg_2 = g.pitch_diameter(4) / 2;
            
            % define variables & force equations
            syms R1_y R1_z R2_y R2_z R3_y R3_z R4_y R4_z R5_y R5_z R6_y R6_z ...
                Wp1_y Wp1_z Wp2_y Wp2_z Wg1_y Wg1_z Wg2_y Wg2_z T_machine
            
            p1 = [
                R1_y + R2_y + Wp1_y == 0,... % SOF in y
                R1_z + R2_z + Wp1_z == 0,... % SOF in z
                R2_y * ip.l_bb1 + Wp1_y * ip.l_bb1_p1 == 0,... % SOM in y
                -R2_z * ip.l_bb1 - Wp1_z * ip.l_bb1_p1 == 0,... % SOM in z
                t_in - Wp1_z * rp_1 == 0,... % SOM in x
                tand(ip.phi) == Wp1_y / Wp1_z % geometric constraint
            ];
            
            csg1_p2 = [
                Wp1_y * 0.975 == -Wg1_y,... % efficiency loss
                Wp1_z * 0.975 == -Wg1_z,... % efficiency loss
                R3_y + Wg1_y + Wp2_y + R4_y == 0,... % SOF in y
                Wg1_y * ip.l_bb2_g1 + Wp2_y * (ip.l_bb2_g1 + ip.l_g1_p2)...
                    + R4_y * (ip.l_bb2_g1 + ip.l_g1_p2 + ip.l_p2_bb3) == 0,... % SOM in Z about bearing 3
                R3_z + Wg1_z + Wp2_z + R4_z == 0,... % SOF in Z
                -Wg1_z * ip.l_bb2_g1 - Wp2_z * (ip.l_bb2_g1 + ip.l_g1_p2)...
                    - R4_z * (ip.l_bb2_g1 + ip.l_g1_p2 + ip.l_p2_bb3) == 0,... % SOM in Y about bearing 3
                Wg1_z * rg_1 + Wp2_z * rp_2 == 0,... % SOM in x
                tand(ip.phi) == -Wp2_y / Wp2_z % geometric constraint
            ];
        
            g2 = [
                Wp2_y * 0.975 == -Wg2_y,... % SOF in y
                Wp2_z * 0.975 == -Wg2_z,... % SOF in z
                Wg2_y + R5_y + R6_y == 0,... % SOM in y
                R5_y * (ip.l_g2_bb4 - ip.l_bb4) + R6_y * ip.l_g2_bb4 == 0,...  % SOM in z
                Wg2_z + R5_z + R6_z == 0,... % SOM in z
                R5_z * (ip.l_g2_bb4 - ip.l_bb4) + R6_z * ip.l_g2_bb4 == 0,... % SOM in x
                T_machine - Wg2_z * rg_2 == 0,... % geometric constraint
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
            
            % otherwise, save forces into properties
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
            
            % compute shear
            obj.V_cs_input = Force(obj.R3.y, obj.R3.z);
            obj.V_cs_output = Force(obj.R3.y + obj.Wg1.y, obj.R3.z + obj.Wg1.z);
            
            % compute moments
            obj.M_input = Moment(ip.l_bb1 * obj.R1.y, ip.l_bb1 * obj.R1.z);
            obj.M_output = Moment(ip.l_bb4 * obj.R6.y, ip.l_bb4 * obj.R6.z);
            obj.M_cs_input = Moment(ip.l_bb2_g1 * obj.V_cs_input.y, ip.l_bb2_g1 * obj.V_cs_input.z);
            obj.M_cs_output = Moment(obj.M_cs_input.y + (ip.l_g1_p2 * obj.V_cs_output.y),...
                obj.M_cs_input.z + (ip.l_g1_p2 * obj.V_cs_output.z));

            % compute torques
            obj.T_output = -S.T_machine;
            obj.T_cs = rg_1 * obj.Wg1.z;
        end
    end
    
end

