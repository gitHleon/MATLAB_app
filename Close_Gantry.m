
%Script prepared to shutdown main gantry Setup functions

joy = joy.Disconnect;

gantry.MotorDisableAll;
gantry.Disconnect;

cam = cam.Disconnect;

imaqreset

% gantry.MoveToFast(350,-54)
% gantry.MoveTo(gantry.Z1,-25,10)
% gantry.MoveTo(gantry.Z2,-65,10)
return

gantry.MoveToFast(-45,450)
gantry.WaitForMotionAll();
gantry.MoveTo(gantry.Z1,-16,5)
gantry.MoveTo(gantry.Z2,-100,5)
gantry.WaitForMotionAll();
gantry.MotorDisableAll;
gantry.Disconnect;

