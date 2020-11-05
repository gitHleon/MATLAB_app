
% Script prepared to begin main gantry setup functions
gantry = STAGES(2);
gantry.Connect;
gantry.MotorEnableAll;

joy = JOYSTICK (gantry);
joy = joy.Connect;

% gantry.MotorEnableAll

fid=FIDUCIALS(1);

cam= CAMERA(5);
cam = cam.Connect;
cam.DispCam

focus = FOCUS(gantry, cam,1);

dispenser = DISPENSER;

%fiducial_1 = [133.3216, -359.4739]; Obsolete
% fiducial_1 = [133.4871, -359.0796];
fiducial_1 = [133.4717, -359.2647];
fiducial_1_Z = 13.3203;
% fiducial_2 = [277.0741, 223.8666];
%fiducial_2 = [277.3340, 224.2251];
% fiducial_2 = [277.3143, 224.2575];
fiducial_2 = [277.2958, 224.2069];
fiducial_2_Z = 13.8901;

petal = PETALCS(0, fiducial_1, fiducial_2);

gluing = PetalDispensing(dispenser,gantry,petal);

% cmd = sprintf('DI--');
% error = dispenser.SetUltimus(cmd)
% pause(0.1)
cmd = sprintf('AU---');
Feedback = dispenser.GetUltimus(cmd)

return

tic
gantry.WaitForMotionAll()
tic
gluing.StartDispensing()
toc




