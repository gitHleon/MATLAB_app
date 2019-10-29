classdef OWIS_STAGES
    %OWIS_STAGES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
%         bool properties
         PS90_connected = false;
         X_stage_init = false;
         Y_stage_init = false;
         Z_stage_init = false;
         X_stage_on = false;
         Y_stage_on = false;
         Z_stage_on = false;
%         long properties
         move_state_X=0;
         move_state_Y=0;
         move_state_Z=0;
%         int properties
        mov_state_X=0;
        mov_state_Y=0;
        mov_state_Z=0;
        
        OWISObj             % Eliminar???
        IsConnected         % Eliminar???
        
%         Connection properties
        nComPort=int32(3); 
        nAxis=int32(1);
        dPosF=30000.0;
        dDistance=10.0;
    end
    
    properties (Constant)
        Index = 1;    %// PS-90 INDEX    %search for reference switch and release switch
        Axisid_X = 1.;
        Axisid_Y = 2.;
        Axisid_Z = 3.;
%       const char* result_window = "Result window";        
    end
    
    properties (Access = private)
        
    end
    
    methods
        function obj = OWIS_STAGES(inputArg1,inputArg2)
            %OWIS_STAGES Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
        
        
        
%       function this = Connect(this, timer, SIGNAL(timeout()), SLOT(updatePositions_X()))
%        end
        
%         function this = initialize (this, AXIS)
%             X_stage_init = true;
%             X_stage_on = true;
%             
% 
%             
%         end


                %% Connect  %%
function OWISobj = ps90tool( in1, in2, in3, in4 )
    
%ps90tool This is a demo application for the PS 90 controller.
%   OWISobj = ps90tool( COM_port, axis_no, velocity, distance ) moves the attached axis...
%   function parameters 
%   parameter 1 - COM port
%   parameter 2 - axis number
%   parameter 3 - positioning velocity in Hz
%   parameter 4 - distance for positioning in mm, distance=0 - reference run

%     nComPort=int32(3); 
%     nAxis=int32(1);
%     dPosF=30000.0;
%     dDistance=10.0;
    
    if nargin ~= 4;     % We're receiving incorrect number of parameters
        fprintf (2, 'ps90tool(COM_port, axis_no, velocity, distance)\n');
        fprintf (2, 'e.g. ps90tool(3,1,30000,10)\n');
    end
    
    % set parameters *************
    if ischar(in1) == 0
        nComPort=int32(in1);
    else
        nComPort=int32(str2double(in1));
    end
    if ischar(in2) == 0
        nAxis=int32(in2);
    else
        nAxis=int32(str2double(in2));
    end
    if ischar(in3) == 0
        dPosF=int32(in3);
    else
        dPosF=str2double(in3);
    end
    if ischar(in4) == 0
        dDistance=in4;
    else
        dDistance=str2double(in4);
    end
    % ****************************

    loadlibrary('ps90','ps90.h')
    % open virtual serial interface
    calllib('ps90','PS90_Connect', 1, 0, nComPort, 9600, 0, 0, 8, 0);
%   [x1,...,xN] = calllib(libname,funcname,arg1,...,argN)

    % define constants for calculation Inc -> mm
    % calllib('ps90','PS90_SetStageAttributes', 1, nAxis, 1.0, 200, 1.0)
    
    % initialize axis
calllib('ps90','PS90_MotorInit', 1, nAxis);

% set target mode (0 - relative)
calllib('ps90','PS90_SetTargetMode', 1, nAxis, 0);

% set velocity 
calllib('ps90','PS90_SetPosF', 1, nAxis, dPosF);

% check position
PositionA = calllib('ps90','PS90_GetPositionEx', 1, nAxis);
fprintf(1, 'Position=%.3f\n', PositionA);

% start positioning
if(dDistance==0.0) % go home (to start position)
	calllib('ps90','PS90_GoRef', 1, nAxis, 4);
else % move to target position (+ positive direction, - negative direction)
	calllib('ps90','PS90_MoveEx', 1, nAxis, dDistance, 1);
end

% check move state of the axis
fprintf(1, 'Axis is moving...\n');
while calllib('ps90','PS90_GetMoveState', 1, nAxis) > 0 
end
fprintf(1, 'Axis is in position.\n');

% check position
PositionB = calllib('ps90','PS90_GetPositionEx', 1, nAxis);
fprintf(1, 'Position=%.3f\n', PositionB);
OWISobj = PositionB;

% close interface
calllib('ps90','PS90_Disconnect',1);

unloadlibrary ps90
    
end
    

                %% Initialize  Pablo%%
        
            function this = INIT(this)
                error = PS90_SetMotorType(Index,Axisid_X,motor_type[0];
%                 if ERROR ~= 0
%                     disp ('Error in PS90_SetMotorType X Axis');
%                 end
            end
            
%                     //X Axis : 1//

        loadlibrary('ps90','ps90.h')
%       calllib('ps90',PS90_SetMotorType, Index, Axisid_x, motor_type[0])

%        if PS90_SetMotorType(Index,Axisid_X,motor_type[0]) ~= 0
%        error = calllib('ps90',PS90_SetMotorType, Index, Axisid_x, motor_type[0]);
        if (calllib('ps90', 'PS90_SetMotorType', Index, Axisid_x, motor_type[0]) ~= 0
            disp ("Error in PS90_SetMotorType X Axis");
        end
        if (calllib('ps90', 'PS90_SetLimitSwitch', Index,Axisid_X,limit_switch[0]) ~= 0 )
            disp('Error in PS90_SetLimitSwitch X Axis');
        end
        if (calllib('ps90', 'PS90_SetLimitSwitchMode', Index,Axisid_X,limit_switch_mode[0]) ~= 0 )
            disp('Error in PS90_SetLimitSwitchMode X Axis');
        end
        if (calllib('ps90', 'PS90_SetRefSwitch', Index,Axisid_X,ref_switch[0]) ~= 0 )
            disp('Error in PS90_SetRefSwitch X Axis');
        end
        if (calllib('ps90', 'PS90_SetRefSwitchMode', Index,Axisid_X,ref_switch_mode[0]) ~= 0 )
            disp('Error in SetRefSwitchMode X Axis');
        end
        if (calllib('ps90', 'PS90_SetSampleTime', Index,Axisid_X,sample_time[0]) ~= 0 )
            disp('Error in SetSampleTime X Axis');
        end
        if (calllib('ps90', 'PS90_SetKP', Index,Axisid_X,KP[0]) ~= 0 ) 
            disp('Error in PS90_SetKP X Axis');
        end
        if (calllib('ps90', 'PS90_SetKI', Index,Axisid_X,KI[0]) ~= 0 ) 
            disp('Error in PS90_SetKI X Axis');
        end
        if (calllib('ps90', 'PS90_SetKD', Index,Axisid_X,KD[0]) ~= 0 )
            disp('Error in PS90_SetKD X Axis');
        end
        if (calllib('ps90', 'PS90_SetDTime', Index,Axisid_X,DTime[0]) ~= 0 )
            disp('Error in PS90_SetDTime X Axis');
        end
        if (calllib('ps90', 'PS90_SetILimit', Index,Axisid_X,ILimit[0]) ~= 0 )
            disp('Error in PS90_SetILimit X Axis');
        end
        if (calllib('ps90', 'PS90_SetTargetWindow', Index,Axisid_X,target_window[0]) ~= 0 )
            disp('Error in PS90_SetTargetWindow X Axis');
        end
        if (calllib('ps90', 'PS90_SetInPosMode', Index,Axisid_X,pos_mode[0]) ~= 0 )
            disp('Error in PS90_SetInPosMode X Axis');
        end
        if (calllib('ps90', 'PS90_SetCurrentLevel', Index,Axisid_X,current_level[0]) ~= 0 )
            disp('Error in SetCurrentLevel X Axis');
        end
        if (calllib('ps90', 'PS90_SetStageAttributes', Index,Axisid_X,pitch[0],increments_per_rev[0],gear_reduction_ratio[0]) ~= 0 )
            disp('Error in PS90_SetStageAttributes X Axis');
        end
        if (calllib('ps90', 'PS90_SetCalcResol', Index,Axisid_X,res_motor[0]) ~= 0 )
            disp('Error in PS90_SetCalcResol X Axis');
        end
        if (calllib('ps90', 'PS90_SetMsysResol', Index,Axisid_X,lin_res[0]) ~= 0 )
            disp('Error in PS90_SetMsysResol X Axis');
        end
        if (calllib('ps90', 'PS90_SetTargetMode', Index,Axisid_X,ini_target_mode[0]) ~= 0 )
            disp('Error in PS90_SetTargetMode X Axis');
        end
        if (calllib('ps90', 'PS90_SetAccelEx', Index,Axisid_X,acc[0]) ~= 0 )
            disp('Error in PS90_SetAccelEx X Axis');
        end
        if (calllib('ps90', 'PS90_SetDecelEx', Index,Axisid_X,dacc[0]) ~= 0 )
            disp('Error in PS90_SetDecelEx X Axis');
        end
        if (calllib('ps90', 'PS90_SetJerk', Index,Axisid_X,jacc[0]) ~= 0 )
            disp('Error in PS90_SetJerk X Axis');
        end
        if (calllib('ps90', 'PS90_SetRefDecelEx', Index,Axisid_X,ref_dacc[0]) ~= 0 )
            disp('Error in PS90_SetRefDecelEx X Axis');
        end
        if (calllib('ps90', 'PS90_SetVel', Index,Axisid_X,vel[0]) ~= 0 )
            disp('Error in PS90_SetVel X Axis');
        end
        if (calllib('ps90', 'PS90_SetPosFEx', Index,Axisid_X,pos_vel[0]) ~= 0 )
            disp('Error in PS90_SetPosFEx X Axis');
        end
        if (calllib('ps90', 'PS90_SetSlowRefFEx', Index,Axisid_X,ref_vel_slow[0]) ~= 0 )
            disp('Error in PS90_SetSlowRefFEx X Axis');
        end
        if (calllib('ps90', 'PS90_SetFastRefFEx', Index,Axisid_X,ref_vel_fast[0]) ~= 0 )
            disp('Error in PS90_SetFastRefFEx X Axis');
        end
        if (calllib('ps90', 'PS90_SetFreeVel', Index,Axisid_X,free_vel[0]) ~= 0 ))
            disp('Error in PS90_SetFreeVel X Axis');
        end
        if (calllib('ps90', 'PS90_SetRefSwitch', Index,Axisid_X,ref_switch_x) ~= 0 ))
            disp('Error in PS90_SetRefSwitch X Axis');
        end


        value = PS90_GetPositionEx(Index,Axisid_X);
        if (calllib('ps90', 'PS90_GetReadError(Index) ~= 0 )
            disp('Error in PS90_GetPositionEx X Axis');
        end
        disp('X_possition: ' value);
        
%         //Y Axis : 2//
 
        if (calllib('ps90', 'PS90_SetMotorType(Index,Axisid_Y,motor_type[1]) ~= 0 )
            disp('Error in PS90_SetMotorType Y Axis');
        end
        if (calllib('ps90', 'PS90_SetLimitSwitch(Index,Axisid_Y,limit_switch[1]) ~= 0 )
            disp('Error in PS90_SetLimitSwitch Y Axis');
        end
        if (calllib('ps90', 'PS90_SetLimitSwitchMode(Index,Axisid_Y,limit_switch_mode[1]) ~= 0 )
            disp('Error in PS90_SetLimitSwitchMode Y Axis');
        end
        if (calllib('ps90', 'PS90_SetRefSwitch(Index,Axisid_Y,ref_switch[1]) ~= 0 )
            disp('Error in PS90_SetRefSwitch Y Axis');
        end
        if (calllib('ps90', 'PS90_SetRefSwitchMode(Index,Axisid_Y,ref_switch_mode[1]) ~= 0 )
            disp('Error in SetRefSwitchMode Y Axis');
        end
        if (calllib('ps90', 'PS90_SetSampleTime(Index,Axisid_Y,sample_time[1]) ~= 0 )
            disp('Error in SetSampleTime Y Axis');
        end
        if (calllib('ps90', 'PS90_SetKP(Index,Axisid_Y,KP[1]) ~= 0 )
            disp('Error in PS90_SetKP Y Axis');
        end
        if (calllib('ps90', 'PS90_SetKI(Index,Axisid_Y,KI[1]) ~= 0 )
            disp('Error in PS90_SetKI Y Axis');
        end
        if (calllib('ps90', 'PS90_SetKD(Index,Axisid_Y,KD[1]) ~= 0 )
            disp('Error in PS90_SetKD Y Axis');
        end
        if (calllib('ps90', 'PS90_SetDTime(Index,Axisid_Y,DTime[1]) ~= 0 )
            disp('Error in PS90_SetDTime Y Axis');
        end
        if (calllib('ps90', 'PS90_SetILimit(Index,Axisid_Y,ILimit[1]) ~= 0 )
            disp('Error in PS90_SetILimit Y Axis');
        end
        if (calllib('ps90', 'PS90_SetTargetWindow(Index,Axisid_Y,target_window[1]) ~= 0 )
            disp('Error in PS90_SetTargetWindow Y Axis');
        end
        if (calllib('ps90', 'PS90_SetInPosMode(Index,Axisid_Y,pos_mode[1]) ~= 0 )
            disp('Error in PS90_SetInPosMode Y Axis');
        end
        if (calllib('ps90', 'PS90_SetCurrentLevel(Index,Axisid_Y,current_level[1]) ~= 0 )
            disp('Error in SetCurrentLevel Y Axis');
        end
        if (calllib('ps90', 'PS90_SetStageAttributes(Index,Axisid_Y,pitch[1],increments_per_rev[1],gear_reduction_ratio[1]) ~= 0 )
            disp('Error in PS90_SetStageAttributes Y Axis');
        end
        if (calllib('ps90', 'PS90_SetCalcResol(Index,Axisid_Y,res_motor[1]) ~= 0 )
            disp('Error in PS90_SetCalcResol Y Axis');
        end
        if (calllib('ps90', 'PS90_SetMsysResol(Index,Axisid_Y,lin_res[1]) ~= 0 )
            disp('Error in PS90_SetMsysResol Y Axis');
        end
        if (calllib('ps90', 'PS90_SetTargetMode(Index,Axisid_Y,ini_target_mode[1]) ~= 0 )
            disp('Error in PS90_SetTargetMode Y Axis');
        end
        if (calllib('ps90', 'PS90_SetAccelEx(Index,Axisid_Y,acc[1]) ~= 0 )
            disp('Error in PS90_SetAccelEx Y Axis');
        end
        if (calllib('ps90', 'PS90_SetDecelEx(Index,Axisid_Y,dacc[1]) ~= 0 )
            disp('Error in PS90_SetDecelEx Y Axis');
        end
        if (calllib('ps90', 'PS90_SetJerk(Index,Axisid_Y,jacc[1]) ~= 0 )
            disp('Error in PS90_SetJerk Y Axis');
        end
        if (calllib('ps90', 'PS90_SetRefDecelEx(Index,Axisid_Y,ref_dacc[1]) ~= 0 )
            disp('Error in PS90_SetRefDecelEx Y Axis');
        end
        if (calllib('ps90', 'PS90_SetVel(Index,Axisid_Y,vel[1]) ~= 0 )
            disp('Error in PS90_SetVel Y Axis');
        end
        if (calllib('ps90', 'PS90_SetPosFEx(Index,Axisid_Y,pos_vel[1]) ~= 0 )
            disp('Error in PS90_SetPosFEx Y Axis');
        end
        if (calllib('ps90', 'PS90_SetSlowRefFEx(Index,Axisid_Y,ref_vel_slow[1]) ~= 0 )
            disp('Error in PS90_SetSlowRefFEx Y Axis');
        end
        if (calllib('ps90', 'PS90_SetFastRefFEx(Index,Axisid_Y,ref_vel_fast[1]) ~= 0 )
            disp('Error in PS90_SetFastRefFEx Y Axis');
        end
        if (calllib('ps90', 'PS90_SetFreeVel(Index,Axisid_Y,free_vel[1]) ~= 0 )
            disp('Error in PS90_SetFreeVel Y Axis');
        end
        if (calllib('ps90', 'PS90_SetRefSwitch(Index,Axisid_Y,ref_switch_y) ~= 0 )
            disp('Error in PS90_SetRefSwitch Y Axis');
        end

        value = PS90_GetPositionEx(Index,Axisid_Y);
        if (calllib('ps90', 'PS90_GetReadError(Index) ~= 0 )
            disp('Error in PS90_GetPositionEx Y Axis');
        end
         disp('Y_possition: ' value);      

%         //Z Axis : 3//

        if (calllib('ps90', 'PS90_SetMotorType(Index,Axisid_Z,motor_type[2]) ~= 0 ) 
            disp('Error in PS90_SetMotorType Z Axis');
        end
        if (calllib('ps90', 'PS90_SetLimitSwitch(Index,Axisid_Z,limit_switch[2]) ~= 0 )
            disp('Error in PS90_SetLimitSwitch Z Axis');
        end
        if (calllib('ps90', 'PS90_SetLimitSwitchMode(Index,Axisid_Z,limit_switch_mode[2]) ~= 0 )
            disp('Error in PS90_SetLimitSwitchMode Z Axis');
        end
        if (calllib('ps90', 'PS90_SetRefSwitch(Index,Axisid_Z,ref_switch[2]) ~= 0 )
            disp('Error in PS90_SetRefSwitch Z Axis');
        end
        if (calllib('ps90', 'PS90_SetRefSwitchMode(Index,Axisid_Z,ref_switch_mode[2]) ~= 0 )
            disp('Error in SetRefSwitchMode Z Axis');
        end
        if (calllib('ps90', 'PS90_SetSampleTime(Index,Axisid_Z,sample_time[2]) ~= 0 )
            disp('Error in SetSampleTime Z Axis');
        end
        if (calllib('ps90', 'PS90_SetKP(Index,Axisid_Z,KP[2]) ~= 0 )
            disp('Error in PS90_SetKP Z Axis');
        end
        if (calllib('ps90', 'PS90_SetKI(Index,Axisid_Z,KI[2]) ~= 0 )
            disp('Error in PS90_SetKI Z Axis');
        end
        if (calllib('ps90', 'PS90_SetKD(Index,Axisid_Z,KD[2]) ~= 0 )
            disp('Error in PS90_SetKD Z Axis');
        end
        if (calllib('ps90', 'PS90_SetDTime(Index,Axisid_Z,DTime[2]) ~= 0 ) 
            disp('Error in PS90_SetDTime Z Axis');
        end
        if (calllib('ps90', 'PS90_SetILimit(Index,Axisid_Z,ILimit[2]) ~= 0 )
            disp('Error in PS90_SetILimit Z Axis');
        end
        if (calllib('ps90', 'PS90_SetTargetWindow(Index,Axisid_Z,target_window[2]) ~= 0 )
            disp('Error in PS90_SetTargetWindow Z Axis');
        end
        if (calllib('ps90', 'PS90_SetInPosMode(Index,Axisid_Z,pos_mode[2]) ~= 0 )
            disp('Error in PS90_SetInPosMode Z Axis');
        end
        if (calllib('ps90', 'PS90_SetCurrentLevel(Index,Axisid_Z,current_level[2]) ~= 0 )
            disp('Error in SetCurrentLevel Z Axis');
        end
        if (calllib('ps90', 'PS90_SetStageAttributes(Index,Axisid_Z,pitch[2],increments_per_rev[2],gear_reduction_ratio[2]) ~= 0 )
            disp('Error in PS90_SetStageAttributes Z Axis');
        end
        if (calllib('ps90', 'PS90_SetCalcResol(Index,Axisid_Z,res_motor[2]) ~= 0 )
            disp('Error in PS90_SetCalcResol Z Axis');
        end
        if (calllib('ps90', 'PS90_SetMsysResol(Index,Axisid_Z,lin_res[2]) ~= 0 )
            disp('Error in PS90_SetMsysResol Z Axis');
        end
        if (calllib('ps90', 'PS90_SetTargetMode(Index,Axisid_Z,ini_target_mode[2]) ~= 0 )
            disp('Error in PS90_SetTargetMode Z Axis');
        end
        if (calllib('ps90', 'PS90_SetAccelEx(Index,Axisid_Z,acc[2]) ~= 0 )
            disp('Error in PS90_SetAccelEx Z Axis');
        end
        if (calllib('ps90', 'PS90_SetDecelEx(Index,Axisid_Z,dacc[2]) ~= 0 )
            disp('Error in PS90_SetDecelEx Z Axis');
        end
        if (calllib('ps90', 'PS90_SetJerk(Index,Axisid_Z,jacc[2]) ~= 0 )
            disp('Error in PS90_SetJerk Z Axis');
        end
        if (calllib('ps90', 'PS90_SetRefDecelEx(Index,Axisid_Z,ref_dacc[2]) ~= 0 )
            disp('Error in PS90_SetRefDecelEx Z Axis');
        end
        if (calllib('ps90', 'PS90_SetVel(Index,Axisid_Z,vel[2]) ~= 0 )
            disp('Error in PS90_SetVel Z Axis');
        end
        if (calllib('ps90', 'PS90_SetPosFEx(Index,Axisid_Z,pos_vel[2]) ~= 0 )
            disp('Error in PS90_SetPosFEx Z Axis');
        end
        if (calllib('ps90', 'PS90_SetSlowRefFEx(Index,Axisid_Z,ref_vel_slow[2]) ~= 0 )
            disp('Error in PS90_SetSlowRefFEx Z Axis');
        end
        if (calllib('ps90', 'PS90_SetFastRefFEx(Index,Axisid_Z,ref_vel_fast[2]) ~= 0 )
            disp('Error in PS90_SetFastRefFEx Z Axis');
        end
        if (calllib('ps90', 'PS90_SetFreeVel(Index,Axisid_Z,free_vel[2]) ~= 0 )
            disp('Error in PS90_SetFreeVel Z Axis');
        end
        if (calllib('ps90', 'PS90_SetRefSwitch(Index,Axisid_Z,ref_switch_z) ~= 0 )
            disp('Error in PS90_SetRefSwitch Z Axis');
        end

        value = PS90_GetPositionEx(Index,Axisid_Z);
        if (calllib('ps90', 'PS90_GetReadError(Index) ~= 0 )
            disp('Error in PS90_GetPositionEx Z Axis');
        else disp('Z_possition: ' value);
        end
        
        
                   %% Trash  %%
     
        
%             switch this.GantryType
%                 case 0
%                 this.GantryObj=A3200Connect;
%                 this.IsConnected=1;
%                 disp('Stages conections done');
%                 case 1
%                 Port = 701;
%                 Address=("10.0.0.100");
%                 this.GantryObj=ACS.SPiiPlusNET.Api;
%                 OpenCommEthernetTCP(this.GantryObj,Address,Port);
%                 this.IsConnected=1;
%                 disp('Stages conections done');
%             end
        end
        
        %% Disconnect  %%
        
        function  this = Disconnect(this)
        % function  this = Disconnect(this)
        % Arguments: object STAGES %
        % Returns: none %
        
        Disconnect(this.OWISobj)
        Connect(this.OWISobj)
        
            switch this.GantryType
                case 0
                A3200Disconnect(this.OWISObj);
                this.IsConnected=0;
                disp('Stages disconnected');
                case 1
                CloseComm(this.GantryObj); 
                this.IsConnected=0;
                disp('Stages disconnected');
            end
        end
        
        
        
        
        
    end
end

