gantry = STAGES(2);
gantry.Connect;

% joy = JOYSTICK (gantry);
% joy = joy.Connect;

% gantry.MotorEnableAll

fid=FIDUCIALS(1);

% cam= CAMERA(5);
% cam = cam.Connect;
% cam.DispCam
% 
% focus = FOCUS(gantry, cam,1);

dispenser = DISPENSER;

fiducial_1 = [133.3216, -359.4739];
fiducial_2 = [277.0741, 223.8666];

petal = PETALCS(0, fiducial_1, fiducial_2);

gluing = PetalDispensing(dispenser,gantry,petal);

gantry.MoveToFast(0,0)
gantry.MoveTo(gantry.Z2,-85,5,1)
error = gluing.StartDispensing();
if error ~= 0
    fprintf ('\n DISPENSER ERROR \n');
    return
end
gantry.MoveToLinear(60, 0, gluing.dispSpeed, 1);
gluing.GPositionWaiting();