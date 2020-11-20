clear ; clc ;

suj_list = [1:4 8:17] ;

trl_cnt = [];

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))] ;
    
    posIN = load(['../pos/' suj '.pat2.fin.pos']);
    
    posIN = posIN(posIN(:,3) == 0,:) ;
    posIN = posIN(floor(posIN(:,2)/1000) ==1,2);
    
    posIN      = posIN - 1000 ;
    posIN(:,2) = floor(posIN(:,1)/100);
    posIN(:,3) = floor((posIN(:,1) - posIN(:,2)*100)/10);
    posIN = posIN(posIN(:,3) == 0,:);
    
    posIN(:,4) = floor(mod(posIN(:,1),10));
    
    ntrl(sb,1) = length(posIN(posIN(:,2) == 0));
    ntrl(sb,2) = length(posIN(posIN(:,2) == 1));
    ntrl(sb,3) = length(posIN(posIN(:,2) == 2));
    
end

clearvars -except ntrl