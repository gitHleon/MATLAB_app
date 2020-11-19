classdef LOADING < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        setup
        gantry
        fid
        cam
        
        Fid_img
        Fid_IC
        Fid_GC
    end
    
    methods
        
%         FIDUCIALS_properties_Gantry.m
%         addpath('Fiducial_config');
        
        function obj = LOADING(setup,camera)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            this.fid = FIDUCIAL(1);
            this.gantry = gantry;
            this.cam = camera;
            
            if ~gantry.Connected
                gantry.Connect;
            end
            
            load ('.\Loading_config\TablePositions.mat','PickupPosition')
        end
        
        
        function milimeters = pixel2mm(this,pixels)
            milimeters = (pixels/camcalibration)/1000;
        end
        
        function TakeFiducial(this,n)
            % function TakeFiducial(this)
            % Arg: n       % Fiducial number we are taking
            % Return: none
            % Take the fiducial coordinates and get its position
            % on gantry coordinate system (GC)
            
            this.Fid_img{n} = this.cam.One();
            figure(n), imshow(this.Fid_img{n});
            pause;
            % Take one fiducial position
            this.F{n} = getpts;
            
            % Plot it in order to check
            this.PlotCheck (n);
            
            % Change to Gantry Coordinates
            x,y = this.Img2Gantry(this.F{n});  
            
            % Create the position vector for gantry
            this.Fid_GC = this.gantry.GetPositionAll;
            this.point(this.gantry.vectorX) = x;
            this.point(this.gantry.vectorY) = y;
        end
        
        function intersection = CalculateCenter(this, F1, F2, F3, F4)
            % function CalculateCenter(this)
            % Arg: F1, F2, F3, F4
            % Return: crosspoint
            % Trace a line between F1-F3 and F2-F4 and get the crosspoint

            x13 = [F1(1), F2(1)];
            y13 = [F1(2), F2(2)];
            
            x24 = [F2(1), F4(1)];
            y24 = [F2(2), F4(2)];
            
            p1 = polyfit(x13,y13,1);
            p2 = polyfit(x24,y24,1);
            x_intersect = fzero(@(x) polyval(p1-p2,x),3);
            y_intersect = polyval(p1,x_intersect);
            
            intersection = [x_intersect, y_intersect];
        end
        
        function Pick (this,module)
            switch module
                case 'R0'
                    PicPos = PickupPosition.R0;
                otherwise
                    disp("La cagaste")
            end
            
%             this.gantry.Move2Fast(PicPos,'wait')
            this.gantry.MoveToFast(PicPos(1), PicPos(2));
            this.gantry.WaitForMotionAll;
            this.gantry.MoveTo(this.gantry.Z1,PicPos(this.gantry.vectorZ1)+1, 5);
            pause;
            this.touch.runtouchdown('Pickup');
        end
        
        function PlotCheck (this, n)
            figure(n), imshow(this.Fid_img{n});
            hold on
            axis on
            figure(n), plot(this.F{n}(1), this.F{n}(2), 'go', 'MarkerSize', 200)%, 'LineWidth', 2);
            figure(n), plot(this.F{n}(1), this.F{n}(2), 'g+', 'MarkerSize', 20)%, 'LineWidth', 2);
            figure(n), plot(this.F{n}(1), this.F{n}(2), 'go', 'MarkerSize', 20)%, 'LineWidth', 2);
            figure(n), plot(this.F{n}(1), this.F{n}(2), 'go', 'MarkerSize', 50)%, 'LineWidth', 2);
            figure(n), plot(this.F{n}(1), this.F{n}(2), 'go', 'MarkerSize', 150)%, 'LineWidth', 2);
            figure(n), plot(this.F{n}(1), this.F{n}(2), 'go', 'MarkerSize', 100)%, 'LineWidth', 2);
        end
        
%         function [X,Y] = pixel2micra([PX,PY])
%             % Converting pixel to micra
%             X = PX/camCalibration;
%             Y = PY/camCalibration;
%         end
        
    end
end

