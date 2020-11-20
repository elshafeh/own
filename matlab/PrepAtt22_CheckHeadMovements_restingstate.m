clear ; clc ;
    
suj = {'mg1' 'mg2' 'mg3' 'mg4' 'mg5' 'mg6' 'mg7' 'mg8' 'mg9' ...
    'mg10' 'mg11' 'mg12' 'mg13' 'mg14' 'mg15' 'mg16' 'mg17' 'mg18' 'mg19' ...
    'uc6' 'uc10' 'yc17' 'yc19' 'uc8' 'uc7' 'uc9' 'yc12' 'yc6' ...
    'uc1' 'uc4' 'uc5' 'yc5' 'yc20' 'yc9' 'yc21' 'yc16' 'yc18' 'yc4'};

for i = 1:length(suj)
    
    Adjust_Head_Pos_3DirbyCoil_restingstate(suj{i})
    pause
    
end
