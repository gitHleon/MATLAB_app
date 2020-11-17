pos1(1) = gantry.GetPosition(gantry.Z1);
pos2(1) = gantry.GetPosition(gantry.Z2);

i = 2;
Z1 = 0;
Z2 = 0;
histeresis = 0.1; %100 um histeresys

tic
while(Z1 > -10)
    Z1 = gantry.GetPosition(gantry.Z1);
    Z2 = gantry.GetPosition(gantry.Z2);
    if (Z1 < pos1(i-1)- histeresis)
        pos1(i) = Z1
        pos2(i) = Z2
        i = i + 1;
    end
     pause(0.1);   
end

tiempo = toc

save('tiempo_caida2.mat','pos1','pos2','tiempo')
% clear("pos1","pos2","i","tiempo")