classdef TOUCHDOWN < handle
    %TOUCHDOWN This class manage the contact between the Z axis and the pick up tool.
    %   I order to identify when the pick up platform of the gantry is in contact with the corresponding tool, the current of the Z stage is controled. This class
    % Provide the methods that manage the contact.
    
    properties (Access=protected)
        gantry;
        z1Axis=4;
        timerLogging;
        currentVector;
    end
    
    methods
        
 %% TOUCHDOWN   
        function this = TOUCHDOWN(gantry)
            %TOUCHDOWN Construct an instance of this class
            %   receive and copy in local property the ganry object
            this.gantry=gantry;
            if (this.gantry.IsConnected==1)
                disp('Touchdown is ready to be used')
            else
                disp('touchdown can not be used: gantry is not connected');  
            end
        end
        
 %%  getCurrentValue
 
        function currentValue = getCurrentValue(this)
            %getCurrentValue get the current value of the Z axis of the gantry
            % input: instance of the class
            % Output: RMS value of the current of the Z axis of the gantry
            currentValue = this.gantry.GetCurrentFeedback(this.z1Axis);
        end
        
%% startLogging

        function startLogging(this, plot)
            %startLogging Start logging the current value of the Z axis
            % input: instance of the class
            % plot: show a live plot with the current value (1 for on, 0 for off)
         this.currentVector=0;
         timerCounter=1;
         if (plot==1)
             figure (1)
             title('CURRENT VALUE Z AXIS');
         end
         this.timerLogging = timer('Name','JoyTimer','ExecutionMode','fixedSpacing','StartDelay', 0,'Period',0.01);
         this.timerLogging.UserData = struct('counter',timerCounter,'plotFlag',plot);
         this.timerLogging.TimerFcn = {@this.logCurrent};
         this.timerLogging.ErrorFcn = {@this.stopLogging};
         this.timerLogging.StopFcn = {@this.stopLogging};
         start(this.timerLogging);
        end
        
%%  logCurrent

        function logCurrent(this)
            %startLogging Logging the current of the Z axis
            % input: instance of the class
            
            %asking current value
            currentValue=this.getCurrentValue;
            
            % saving value in the corresponding vector
            if tobj.UserData.counter~=1
             this.currentVector=[this.currentVector currentValue];
            else
              this.currentVector=currentValue;
            end

            % ploting in live figure current value if necessary
            if tobj.UserData.plotFlag==1
                hold on
                plot(tobj.UserData.counter,currentValue);
            end

            % increment counter
            tobj.UserData.counter=tobj.UserData.counter+1;
        end       

%% stopLogging

  function currentLog = stopLogging(this)
            %stopLogging finish the logging of the Z axis current
            % input: instance of the class
            % output: vector with the current values logged
        stop(this.timerLogging);
        currentLog=this.currentVector;
  end        

  
 
    end
end
