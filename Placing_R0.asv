
gantry.HomeAll

load('Sento_variables.mat')

imaqreset
cam= CAMERA(5);
cam = cam.Connect;
cam.DispCam
focus = FOCUS(gantry, cam,1);

focus.AutoFocus

%Lookin for module fiducials
gantry.MoveToFast(fiducial_1(1),fiducial_1(2))
imagen = cam.OneFrame();
imshow(imagen)
[m,n,k]=size(imagen)
center=[n/2,m/2];

axis on
hold on
plot(center(1),center(2), 'r+', 'MarkerSize', 30);% 'LineWidth', 2);
[corner(1),corner(2)] = getpts
plot(corner(1), corner(2), 'g+', 'MarkerSize', 30)%, 'LineWidth', 2);

plot([corner(1) center(1)],[corner(2) center(2)], 'r', 'LineWidth', 2);

CAMERA_properties_Gantry

correction=(center - corner).*calibration/1000
gantry.MoveBy(gantry.X, correction(1), 1)

% [x,y] = getpts 





gantry.MoveToFast(PickupPosition(1),PickupPosition(2));
gantry.WaitForMotionAll
take = TOUCHDOWN(gantry)
gantry.MoveTo(gantry.U,PickupPosition(gantry.U),15)
take.runTouchdown(gantry.Z1,PickupPosition(gantry.Z1));

wait()

gantry.MoveTo(gantry.Z1,0,5)

wait()

gantry.MoveToFast(ModulePosition(1),ModulePosition(2));
gantry.WaitForMotionAll;
gantry.MoveTo(gantry.Z1,ModulePosition(gantry.Z1)+1,5)


wait()

take.runTouchdown(gantry.Z1,ModulePosition(gantry.Z1));

wait()

gantry.MoveTo(gantry.Z1,0,5)
gantry.WaitForMotionAll
gantry.MoveTo(gantry.U,PickupPosition(gantry.U),15)
gantry.WaitForMotionAll
gantry.MoveTo(gantry.Z1,ModulePosition(gantry.Z1)+1,15)

wait()

take.runTouchdown(gantry.Z1,ModulePosition(gantry.Z1));


%Terminando
gantry.MoveTo(gantry.Z1,PickupPosition(gantry.Z1)+3,5)



%%
load('Calibration.mat');
imshow(cal_imagenes{1})
[x,y]= getpts
corner{1}=[x,y]
imshow(cal_imagenes{5})
[x,y]= getpts
corner{5}=[x,y]


function [X,Y] = pixel2micra([PX,PY])
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

