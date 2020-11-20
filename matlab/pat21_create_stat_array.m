clear ; clc ;

cond = {'RL.nDT.sensor.mat','RN.nDT.sensor.mat','LN.nDT.sensor.mat'};

bigbag ={};

for c = 1:3
    
    load(['../data/yctot/stat/' cond{c}])
    
    for cs = 1:5
        
        bigbag{cs,c} = stat{1,cs};
    end
    clear stat ;
    
end