function [stat,results_summary] = h_sens_anova(cfg,allsuj_data)

% Output (1) : Group Effect (group1 - group2)
% Output (2) : Condition Effect (Cond1 - Cond2)
% Ouptut (3) : Cond1-Cond2 between groups (group1 - group2)
% Ouptut (4) : Cond1-Cond2 for group1
% Ouptut (5) : Cond1-Cond2 for group2

% Compute Group Effect

for ngroup = 1:length(allsuj_data)
    for sb = 1:size(allsuj_data{ngroup},1)
        
        new_data{ngroup,sb} = ft_timelockgrandaverage([],allsuj_data{ngroup}{sb,:}); 
        
    end
end

clc;

cfg.statistic = 'indepsamplesT';
nbsuj         = size(allsuj_data{1},1);
cfg.design    = [ones(nbsuj) ones(nbsuj)*2];
cfg.ivar      = 1;
stat{1}       = ft_timelockstatistics(cfg, new_data{1,:}, new_data{2,:});

cfg           = rmfield(cfg,'ivar'); cfg           = rmfield(cfg,'design'); cfg           = rmfield(cfg,'statistic');

% Compute Condition Effect

new_data      = {};

for ncue = 1:size(allsuj_data{ngroup},2)
    
    i             = 0;
    
    for ngroup = 1:length(allsuj_data)
        for sb = 1:size(allsuj_data{ngroup},1)
            
            i                = i +1; 
            
            new_data{i,ncue} = allsuj_data{ngroup}{sb,ncue};
            
        end
    end
end

cfg.statistic = 'ft_statfun_depsamplesT';
nbsuj         = size(new_data,1);
[design,~]    = h_create_design_neighbours(nbsuj,allsuj_data{1}{1},'gfp','t');
cfg.uvar      = 1;
cfg.ivar      = 2;
cfg.design    = design;
stat{2}       = ft_timelockstatistics(cfg, new_data{:,1}, new_data{:,2});

cfg           = rmfield(cfg,'uvar'); cfg           = rmfield(cfg,'ivar'); cfg           = rmfield(cfg,'design'); cfg           = rmfield(cfg,'statistic');

% Compute Interaction 

new_data      = {};

for ngroup = 1:length(allsuj_data)
    for sb = 1:size(allsuj_data{ngroup},1)
        
        new_data{ngroup,sb}         = allsuj_data{ngroup}{sb,1};
        new_data{ngroup,sb}.avg     = allsuj_data{ngroup}{sb,1}.avg - allsuj_data{ngroup}{sb,2}.avg;
        
    end
end

cfg.statistic = 'indepsamplesT';
nbsuj         = size(allsuj_data{1},1);
cfg.design    = [ones(nbsuj) ones(nbsuj)*2];
cfg.ivar      = 1;
stat{3}       = ft_timelockstatistics(cfg, new_data{1,:}, new_data{2,:});

cfg           = rmfield(cfg,'ivar'); cfg           = rmfield(cfg,'design'); cfg           = rmfield(cfg,'statistic');

% Compute Condition Effect for each group

for ngroup = 1:length(allsuj_data)
    
    nbsuj         = length(allsuj_data{ngroup});
    [design,~]    =  h_create_design_neighbours(nbsuj,allsuj_data{1}{1},'gfp','t');
    
    cfg.statistic = 'ft_statfun_depsamplesT';
    cfg.design    = design;
    cfg.uvar      = 1;
    cfg.ivar      = 2;
    
    stat{end+1}   = ft_timelockstatistics(cfg, allsuj_data{ngroup}{:,1}, allsuj_data{ngroup}{:,2});
    
end

list_test         = {'GroupEffect','CondEffect','Interaction','CondGroup1','CondGroup2'};
results_summary   = {};


for ntest = 1:length(stat)
    
    [min_p,p_val]                 = h_pValSort(stat{ntest}) ;
    
    results_summary{ntest,1}      = list_test{ntest};
    results_summary{ntest,2}      = min_p;
    results_summary{ntest,3}      = p_val;
    
    clear min_p p_val
    
end

