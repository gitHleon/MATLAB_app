classdef LOADING < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        setup
        gantry
        fid
        cam
        imag
        point
        
        mLine13
        qLine13
        mLine24
        qLine24
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
            milimeters = pixels/camcalibration;
        end
        
        function position = TakeFiducial(this,n)
            this.imag{n} = this.cam.One();
            figure(n), imshow(this.imag{n})
            [X,Y] = getpts;
            x = pixel2mm(X);
            y = pixel2mm(Y);
            this.point = this.gantry.GetPositionAll;
            this.point(this.gantry.vectorX) = x;
            this.point(this.gantry.vectorY) = y;
        end
        
        function intersection = LinesCalculation(this)
            % function LinesCalculation(this)
            % Arg: none
            % Return: none
            % Calculate line equations between F-F: 1-2 and 3-4
            
%             this.mLine13 = (this.f2(1) - this.f1(1))/(this.f2(2) - this.f1(2));
%             this.qLine13 = (this.f2(2)*this.f1(1)) - (this.f1(2)*this.f2(1)) / (this.f2(2)-this.f1(2));
%             
%             this.mLine24 = (this.f4(1) - this.f3(1))/(this.f4(2)-this.f3(2));
%             this.qLine24 = ((this.f4(2)*this.f3(1)) - (this.f3(2)*this.f4(1))) / (this.f4(2)-this.f3(2));
            
            this.mLine13 = (this.point{3}(1) - this.point{1}(1))/(this.point{3}(2) - this.point{1}(2));
            this.qLine13 = (this.point{3}(2)*this.point{1}(1)) - (this.point{1}(2)*this.point{3}(1)) / (this.point{3}(2)-this.point{1}(2));
            
            this.mLine24 = (this.point{4}(1) - this.point{2}(1))/(this.point{4}(2)-this.point{2}(2));
            this.qLine24 = ((this.point{4}(2)*this.point{2}(1)) - (this.point{2}(2)*this.point{4}(1))) / (this.point{4}(2)-this.point{2}(2));
            
            intersection = 
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
        
        function plot_lines (this)
            
        end
        
        function plotting (this, n)
            figure(n), imshow (this.imag{n})
            hold on
            axis on
            figure(n), plot(this.point{n}(1), this.point{n}(2), 'go', 'MarkerSize', 200)%, 'LineWidth', 2);
            figure(n), plot(this.point{n}(1), this.point{n}(2), 'g+', 'MarkerSize', 20)%, 'LineWidth', 2);
            figure(n), plot(this.point{n}(1), this.point{n}(2), 'go', 'MarkerSize', 20)%, 'LineWidth', 2);
            figure(n), plot(this.point{n}(1), this.point{n}(2), 'go', 'MarkerSize', 50)%, 'LineWidth', 2);
            figure(n), plot(this.point{n}(1), this.point{n}(2), 'go', 'MarkerSize', 150)%, 'LineWidth', 2);
            figure(n), plot(this.point{n}(1), this.point{n}(2), 'go', 'MarkerSize', 100)%, 'LineWidth', 2);
        end
        
%         function [X,Y] = pixel2micra([PX,PY])
%             % Converting pixel to micra
%             X = PX/camCalibration;
%             Y = PY/camCalibration;
%         end
        
    end
end

