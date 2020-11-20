clear; clc ; dleiftrip_addpath ;

for a = 1:4
    
    for b = 1:3
        
        cnd = 'CnD';
        
        suj_list    = [1:4 8:17];
        suj         = ['yc' num2str(suj_list(a))];
        
        load(['../data/' suj '/headfield/' suj '.pt' num2str(b) '.adjusted.leadfield.5mm.mat']); clc ;
        
        load(['../data/' suj '/headfield/' suj '.VolGrid.5mm.mat']); clc ;
        
        fprintf('\nLoading %20s\n',['../data/' suj '/elan/' suj '.pt' num2str(b) '.' cnd]);
        load(['../data/' suj '/elan/' suj '.pt' num2str(b) '.' cnd '.mat']);
        
        for cnd_time = 1:2
            
            st_point = [-0.6 0.7];
            tim_win = 0.4;
            
            lm1 = st_point(cnd_time)-0.015;
            lm2 = st_point(cnd_time)+tim_win+0.015;
            
            cfg             = [];
            cfg.toilim      = [lm1 lm2];
            poi{cnd_time}   = ft_redefinetrial(cfg, data_elan);
            
        end
            
        poi_appnd = ft_appenddata([],poi{:});
        
        cfg             = [];
        cfg.method      = 'mtmfft';
        cfg.output      = 'fourier';
        cfg.keeptrials  = 'yes';
        cfg.tapsmofrq   = 2;
        cfg.foi         = 9;
        freq_appnd      = ft_freqanalysis(cfg, poi_appnd);
        
        for t = 1:2
            freq{t} = ft_freqanalysis(cfg, poi{t});
        end
        
        cfg                   = [];
        cfg.frequency         = freq_appnd.freq;
        cfg.method            = 'pcc';
        cfg.grid              = leadfield;
        cfg.headmodel         = vol;
        cfg.keeptrials        = 'yes';
        cfg.pcc.lambda        = '15%';
        cfg.pcc.projectnoise  = 'yes';
        cfg.pcc.keepfilter    = 'yes';
        cfg.pcc.fixedori      = 'yes';
        source_appnd          = ft_sourceanalysis(cfg, freq_appnd);
        
        for t = 1:2
            
            cfg                   = [];
            cfg.frequency         = freq{t}.freq;
            cfg.method            = 'pcc';
            cfg.grid              = leadfield;
            cfg.grid.filter       = source_appnd.avg.filter;
            cfg.headmodel         = vol;
            cfg.keeptrials        = 'yes';
            cfg.pcc.lambda        = '15%';
            cfg.pcc.projectnoise  = 'yes';
            source{t}             = ft_sourceanalysis(cfg, freq{t});
            
        end
        
    end
    
end