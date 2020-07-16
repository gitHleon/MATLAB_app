for i=1:10
gluing.DispenseContinius('R5S1')
variable = genvarname(sprintf('timeStop%d',i))
load('R5S1_times.mat', 'timeStop')
eval([variable ' = timeStop'])
end
%Hacemos una matriz con todos los 10 vectores conseguidos
times = [timeStop1;timeStop2;timeStop3;timeStop4;timeStop5;timeStop6;timeStop7;timeStop8;timeStop9;timeStop10];
save('R5S1_times.mat', 'times')

media = mean(times);
timeStop = media;
save('R5S1.mat', 'timeStop')

%return

gantry.MoveToFast(0,400)
gantry.WaitForMotionAll();
gantry.MoveTo(gantry.Z1,-25,5)
gantry.MoveTo(gantry.Z2,-65,5)
gantry.WaitForMotionAll();
gantry.MotorDisableAll;
gantry.Disconnect;

return


for i=1:length( timeStop )
    timeStop(i) = mean(times(i));
end

return

% for i=1:10
% variable = genvarname(sprintf('timeStop%d',i))
% eval([variable '  = i*2'])
% end