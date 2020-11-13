classdef LOADING < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Property1
    end
    
    methods
        
%         FIDUCIALS_properties_Gantry.m
%         addpath('Fiducial_config');
        
        function obj = LOADING(gantry,cam,fid,)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            fid = FIDUCIAL(1);
            
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
        
        function [X,Y] = pixel2micra([PX,PY])
            % Converting pixel to micra
            X = PX/calibration;
            Y = PY/calibration;
        end
        
        function [X,Y] = pixel2micra([MX,MY])
            X = MX*calibration;
            Y = MY*calibration;
        end
        
        function [X, Y, Z1] = TakeFiducial()
            [X,Y] = getpts
            Z1 = gantry.GetPosistion(gantry.Z1);
        end
    end
end

