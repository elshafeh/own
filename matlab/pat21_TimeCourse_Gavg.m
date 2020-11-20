clear ; clc ; close all ; dleiftrip_addpath;

suj_list = [1:4 8:17];

clc;

for a = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(a))] ;
    
    load(['../data/' suj '/headfield/' suj '.VolGrid.1cm.mat']);
    
    cmpr = {'vn.max'};
    
    idx = 1;
    
    cnd_freq = '';
    cnd_time = {'.m800m200','.p500p1100'};
    
    lck = 'CnD';
    
    ext_cnd{1} = [upper(cmpr{idx}(1)) lck];
    ext_cnd{2} = [upper(cmpr{idx}(2)) lck];
    
    for b = 1:length(ext_cnd)
        
        for c = 1:3
            
            for d = 1:2
                
                ext_comp = cmpr{idx};
                
                fname = dir(['../data/' suj '/source/*pt' num2str(c) '*'  ext_cnd{b} '*' cnd_freq '*' cnd_time{d} '*' ext_comp '*']);
                fname = fname.name;
                fprintf('\nLoading %50s\n',fname);
                load(['../data/' suj '/source/' fname]);
                source_carr{d} = source ; clear source ;
                
            end
            
            cfg                             = [];
            cfg.parameter                   = 'avg.pow';
            cfg.operation                   = '((x1-x2)./x2)*100';
            source_diff{c}                  = ft_math(cfg,source_carr{2},source_carr{1});
            
            clear source_carr
            
        end
        
        source_avg{a,b}         = ft_sourcegrandaverage([],source_diff{:});
        source_avg{a,b}.pos     = grid.MNI_pos;
        source_avg{a,b}.freq    = 10;
        
        clear source_diff
        
    end
    
end

clearvars -except source_avg


