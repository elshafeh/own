clear ; clc ;

suj  ='yc1' ;

cond = 'RCnD' ;

for prt = 1:3
    
    load(['../data/' suj '/source/' suj '.pt' num2str(prt) '.' cond '.tfResolved.5t15Hz.m700p2000ms.mat']);
    
    for fq = 1:4
        tmp = squeeze(tResolvedAvg.pow(:,fq,:));
%         data_check(prt,fq) = max(max(tmp));
        data_check(prt,fq) = min(min(tmp));
    end
    
end