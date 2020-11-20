clear ; clc ; 

load ../data/yctot/rt/rt_dis_ordered.mat;
for sb = 1:14
    both_dis{1,sb} = rt_order{sb}; 
end
clear rt_ordered sb
load ../data/yctot/rt/rt_fdis_ordered.mat;
for sb = 1:14
    both_dis{2,sb} = rt_order{sb}; 
end
clear rt_ordered sb

for sb = 1:14
    if length(both_dis{1,sb}) ~= length(both_dis{2,sb})
        error('Fuck!');
    else 
        fprintf('yay!\n')
    end
end
clc;

clear ; clc ; 

for sb = 1:14
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    ext         =   'AudViz.VirtTimeCourse.mat';
    lst         =   {'DIS','fDIS'};
    
    for d = 1:2
        fname_in    = ['../data/pe/' suj '.'  lst{d} '.' ext];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        tmp{d} = virtsens.trialinfo ; clear virtsens ;
    end
    
    test = [tmp{1}-2000 tmp{2}-6000];
    ix   = find(test~=0);
    if ~isempty(ix)
        fprintf('fuck\n');
    end
end