clear ; clc ;

load ../data/yctot/index/NewSourceAudVisMotor.mat ;

indxToT = h_createIndexfieldtrip();

for n = 1:length(indx_arsenal)   
    indx_arsenal(n,3) = indxToT(indxToT(:,1) == indx_arsenal(n,1),2);
end