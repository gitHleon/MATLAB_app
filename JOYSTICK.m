classdef JOYSTICK < handle
    %JOYSTICK Control over joystick device
    %   This class provide control over joystick device connected to Gantry
    
    properties (Access=public)
  
    end
    properties (Access=protected)
        JoystickIsReady=0;
        gantry;
        t;
        threshold=0.1;
        maxVel=15;
        minVel=0.1;
        CurrentVel=5;
        xAxis=0;
        yAxis=1;
        z1Axis=4;
        z2Axis=5;
        uAxis=6;
        
        xJoy = 2;
        yJoy = 1;
        zJoy = 3;
        zBut = 4;
        uBut = 5;
    end
    
    methods
        function this = JOYSTICK(gantry_obj)
            %JOYSTICK Construct an instance of this class
            %   receiving gantry object and creating joystick instance
        this.gantry=gantry_obj;
        this.xAxis=this.gantry.X;
        this.yAxis=this.gantry.Y;
        this.z1Axis=this.gantry.Z1;
        this.z2Axis=this.gantry.Z2;
        this.uAxis=this.gantry.U;
         if (this.gantry.IsConnected==1)
   
        else
            disp('joystick can not be used: gantry is not connected')
        end
        end
        
        function Connect(this)
            %Connect Connecting joystick
            % starting timer to manage the joystick input
        this.gantry.MotorEnableAll;     
        this.t = timer('Name','JoyTimer','ExecutionMode','fixedSpacing','StartDelay', 0,'Period',0.01);
        this.t.UserData = struct('FlagAxes',zeros(5,1),'FlagBut',zeros(16,1),'maxVelocity',this.maxVel,'minVelocity',this.minVel,'Velocity',this.CurrentVel);
        this.t.BusyMode='queue';
        
        this.t.TimerFcn = {@this.joyControl};
        this.t.ErrorFcn = {@this.stopAll};
        this.t.StopFcn = {@this.stopAll};
        start(this.t);
        disp('Joystick is ready to be used')
        this.JoystickIsReady=1;
        end
        
        function Disconnect(this)
            %Disconnect Disconnect joystick
            % Stopping timer
        stop(this.t);
        this.JoystickIsReady=0;
        this.IsConnected = 0;
        end
        
        function joyControl(this,tobj,event)
            % calling the joystick inpput %

            [pos, but] = mat_joy(0);
            
           % Controling of the axes: moving %
           
            if (abs(pos(this.xJoy))> this.threshold)
             vel=-tobj.UserData.Velocity*pos(this.xJoy);
             this.gantry.FreeRunX(vel);
             tobj.UserData.FlagAxes(this.xJoy)=1;
            end
            
            if (abs(pos(this.yJoy))> this.threshold)
             vel=-tobj.UserData.Velocity*pos(this.yJoy);
             this.gantry.FreeRunY(vel);
             tobj.UserData.FlagAxes(this.yJoy)=1;
            end
            
            if (abs(pos(3))> this.threshold) && (tobj.UserData.FlagAxes(5)==0) && (tobj.UserData.FlagAxes(4)==0)
            vel=-tobj.UserData.Velocity*pos(3);
            this.gantry.FreeRunZ1(vel);
            tobj.UserData.FlagAxes(3)=1;
            end
            
            if (abs(pos(3))> this.threshold) && (tobj.UserData.FlagAxes(5)==0) && (tobj.UserData.FlagAxes(4)==1)
            vel=-tobj.UserData.Velocity*pos(3);
            this.gantry.FreeRunZ2(vel);
            tobj.UserData.FlagAxes(3)=1;
            end
            
             if (abs(pos(3))> this.threshold) && (tobj.UserData.FlagAxes(5)==1)
            vel=-tobj.UserData.Velocity*pos(3);
            this.gantry.FreeRunU(vel);
            tobj.UserData.FlagAxes(3)=1;
            end
            
            % Controling of the axes: stopping %

            if (abs(pos(this.xJoy))<this.threshold) && (tobj.UserData.FlagAxes(this.xJoy)==1)
            this.gantry.MotionStop(this.xAxis);
            tobj.UserData.FlagAxes(this.xJoy)=0;
            end
            
            if (abs(pos(this.yJoy))<this.threshold) && (tobj.UserData.FlagAxes(this.yJoy)==1)
            this.gantry.MotionStop(this.yAxis);
            tobj.UserData.FlagAxes(this.yJoy)=0;
            end
            
            if (abs(pos(3))<this.threshold) && (tobj.UserData.FlagAxes(3)==1) && (tobj.UserData.FlagAxes(5)==0) && (tobj.UserData.FlagAxes(4)==0)
            this.gantry.MotionStop(this.z1Axis);
            tobj.UserData.FlagAxes(3)=0;
            end
            
             if (abs(pos(3))<this.threshold) && (tobj.UserData.FlagAxes(3)==1) && (tobj.UserData.FlagAxes(5)==0) && (tobj.UserData.FlagAxes(4)==1)
            this.gantry.MotionStop(this.z2Axis);
            tobj.UserData.FlagAxes(3)=0;
             end
            
             if (abs(pos(3))<this.threshold) && (tobj.UserData.FlagAxes(3)==1) && (tobj.UserData.FlagAxes(5)==1)
            this.gantry.MotionStop(this.uAxis);
            tobj.UserData.FlagAxes(3)=0;
             end
            
            % Checking the buttons %

            % Button 11: change between ZZ axis %
            
             if (but(11)==1) && (tobj.UserData.FlagBut(11)==0)
             switch tobj.UserData.FlagAxes(4)
                 case 0
                     tobj.UserData.FlagAxes(4)=1;
                 case 1
                     tobj.UserData.FlagAxes(4)=0;
             end
             tobj.UserData.FlagBut(11)=1;
             end
             
             if (but(11)==0) && (tobj.UserData.FlagBut(11)==1)
             tobj.UserData.FlagBut(11)=0;
             end
             
             % Button 12: change Z axis --> rotative platform %
             
             if (but(12)==1) && (tobj.UserData.FlagBut(12)==0)
             switch tobj.UserData.FlagAxes(5)
                 case 0
                     tobj.UserData.FlagAxes(5)=1;
                 case 1
                     tobj.UserData.FlagAxes(5)=0;
             end
             tobj.UserData.FlagBut(12)=1;
             end
             if (but(12)==0) && (tobj.UserData.FlagBut(12)==1)
             tobj.UserData.FlagBut(12)=0;
             end
             
              % Button 1: decrease velocity %
              
             if (but(1)==1) && (tobj.UserData.FlagBut(1)==0)
             tobj.UserData.Velocity=max(tobj.UserData.minVelocity,tobj.UserData.Velocity-0.05*tobj.UserData.maxVelocity);
             tobj.UserData.FlagBut(1)=1; 
             fprintf('Velocity Value: %2.4f\n',tobj.UserData.Velocity);
             end    
             if (but(1)==0) && (tobj.UserData.FlagBut(1)==1)
             tobj.UserData.FlagBut(1)=0;
             end
             
             % Button 2: Increase Velocity %
             
              if (but(2)==1) && (tobj.UserData.FlagBut(2)==0)
             tobj.UserData.Velocity=min(tobj.UserData.maxVelocity,tobj.UserData.Velocity+0.05*tobj.UserData.maxVelocity);
             tobj.UserData.FlagBut(2)=1;    
             fprintf('Velocity Value: %2.4f\n',tobj.UserData.Velocity);
             end    
             if (but(2)==0) && (tobj.UserData.FlagBut(2)==1)
             tobj.UserData.FlagBut(2)=0;
             end
        end
        
        
          function stopAll(this,tobj,event)
              % safe stop in case timer stopped %
            this.gantry.MotionStop(this.xAxis);
            this.gantry.MotionStop(this.yAxis); 
            this.gantry.MotionStop(this.z1Axis); 
            this.gantry.MotionStop(this.z2Axis); 
            this.gantry.MotionStop(this.uAxis); 
          end

end
end
