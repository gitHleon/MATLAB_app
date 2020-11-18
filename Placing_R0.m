
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


gantry.MoveToFast(cal_position{1}(1),cal_position{1}(2))
gantry.MoveTo(gantry.Z1,cal_position{1}(4),5)
gantry.WaitForMotionAll;
% imagen1 = cam.OneFrame;
imagen1 = cal_imagenes{1};
figure, imshow(imagen1)
hold on
axis on
figure(1), plot(corner{1}(1), corner{1}(2), 'go', 'MarkerSize', 200)%, 'LineWidth', 2);
figure(1), plot(corner{1}(1), corner{1}(2), 'g+', 'MarkerSize', 20)%, 'LineWidth', 2);
figure(1), plot(corner{1}(1), corner{1}(2), 'go', 'MarkerSize', 20)%, 'LineWidth', 2);
figure(1), plot(corner{1}(1), corner{1}(2), 'go', 'MarkerSize', 50)%, 'LineWidth', 2);
figure(1), plot(corner{1}(1), corner{1}(2), 'go', 'MarkerSize', 150)%, 'LineWidth', 2);
figure(1), plot(corner{1}(1), corner{1}(2), 'go', 'MarkerSize', 100)%, 'LineWidth', 2);

% figure(1), plot(center(1), center(2), 'go', 'MarkerSize', 200)%, 'LineWidth', 2);
% figure(1), plot(center(1), center(2), 'g+', 'MarkerSize', 20)%, 'LineWidth', 2);
% figure(1), plot(center(1), center(2), 'go', 'MarkerSize', 20)%, 'LineWidth', 2);
% figure(1), plot(center(1), center(2), 'go', 'MarkerSize', 50)%, 'LineWidth', 2);
% figure(1), plot(center(1), center(2), 'go', 'MarkerSize', 150)%, 'LineWidth', 2);
% figure(1), plot(center(1), center(2), 'go', 'MarkerSize', 100)%, 'LineWidth', 2);


gantry.MoveToFast(cal_position{5}(1),cal_position{5}(2))
gantry.MoveTo(gantry.Z1,cal_position{5}(4),5)
gantry.WaitForMotionAll;
% imagen5 = cam.OneFrame;
imagen5 = cal_imagenes{5};
figure(5), imshow(imagen5)
hold on
axis on
% [x,y] = getpts
% corner{5} = [x,y]
figure(5), plot(corner{5}(1), corner{5}(2), 'go', 'MarkerSize', 200)%, 'LineWidth', 2);
figure(5), plot(corner{5}(1), corner{5}(2), 'g+', 'MarkerSize', 20)%, 'LineWidth', 2);
figure(5), plot(corner{5}(1), corner{5}(2), 'go', 'MarkerSize', 20)%, 'LineWidth', 2);
figure(5), plot(corner{5}(1), corner{5}(2), 'go', 'MarkerSize', 50)%, 'LineWidth', 2);
figure(5), plot(corner{5}(1), corner{5}(2), 'go', 'MarkerSize', 150)%, 'LineWidth', 2);
figure(5), plot(corner{5}(1), corner{5}(2), 'go', 'MarkerSize', 100)%, 'LineWidth', 2);

n=5
figure(n), imshow (cal_imagenes{n})
            hold on
            axis on
            figure(n), plot(corner{n}(1), corner{n}(2), 'go', 'MarkerSize', 200)%, 'LineWidth', 2);
            figure(n), plot(corner{n}(1), corner{n}(2), 'g+', 'MarkerSize', 20)%, 'LineWidth', 2);
            figure(n), plot(corner{n}(1), corner{n}(2), 'go', 'MarkerSize', 20)%, 'LineWidth', 2);
            figure(n), plot(corner{n}(1), corner{n}(2), 'go', 'MarkerSize', 50)%, 'LineWidth', 2);
            figure(n), plot(corner{n}(1), corner{n}(2), 'go', 'MarkerSize', 150)%, 'LineWidth', 2);
            figure(n), plot(corner{n}(1), corner{n}(2), 'go', 'MarkerSize', 100)%, 'LineWidth', 2);


figure(1), imshow (cal_imagenes{1})
hold on
axis on
figure(1), plot(corner{n}(1), corner{n}(2), 'go', 'MarkerSize', 200)%, 'LineWidth', 2);
            figure(1), plot(corner{n}(1), corner{n}(2), 'g+', 'MarkerSize', 20)%, 'LineWidth', 2);
            figure(1), plot(corner{n}(1), corner{n}(2), 'go', 'MarkerSize', 20)%, 'LineWidth', 2);
            figure(1), plot(corner{n}(1), corner{n}(2), 'go', 'MarkerSize', 50)%, 'LineWidth', 2);
            figure(1), plot(corner{n}(1), corner{n}(2), 'go', 'MarkerSize', 150)%, 'LineWidth', 2);
            figure(1), plot(corner{n}(1), corner{n}(2), 'go', 'MarkerSize', 100)%, 'LineWidth', 2);


%% Going to compensated position

deltaPixels = corner{5} - corner{1}
deltaMicras = deltaPixels/camCalibration  % camCalibration = 1.74;
deltaMilims = deltaMicras./1000
m = tan(deltaMilims(1)/deltaMilims(2))    % Pendiente de la recta
alfa = atan(m)
cal_newPosition{5}(1:2) = cal_position{1}(1:2) + deltaMilis(1:2)
cal_newPosition{5} = (cal_position{5}(1)*sin(alfa), cal_position{5}*cos(alfa))

cal_newPosition{5} = cal_position{1}(1:2) 

gantry.MoveToFast(cal_newPosition{5}(1),cal_newPosition{5}(2))
gantry.MoveTo(gantry.Z1,cal_newPosition{5}(4),5)

%% Cruce de dos rectas
p1 = polyfit(x1,y1,1);
p2 = polyfit(x2,y2,1);
%calculate intersection
x_intersect = fzero(@(x) polyval(p1-p2,x),3);
y_intersect = polyval(p1,x_intersect);
line(x1,y1);
hold on;
line(x2,y2);
plot(x_intersect,y_intersect,'r*')
%%
