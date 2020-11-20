% Adhering to Weisz + Bael Method

clear ; clc ; dleiftrip_addpath ;

suj_list =[1:4 8:17];

for s = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(s))] ;
    
    load(['../data/headfield/' suj '.VolGrid.5mm.mat']);
    
    lst_dis = {'','f'};
    
    for p = 1:3
        
        ext_essai = 'disfdis.lcmv';
        fname_out           = [suj '.pt' num2str(p) '.' ext_essai '.CommonFilter'];
        fprintf('\n\nLoading %50s \n\n',fname_out);
        load(['../data/filter/' fname_out '.mat'])
        
        load(['../data/headfield/' suj '.pt' num2str(p) '.adjusted.leadfield.5mm.mat']);
        
        for cc = 1:length(lst_dis)
            
            fprintf('\nLoading %30s\n',['../data/elan/' suj '.pt' num2str(p) '.' lst_dis{cc} 'DIS.mat']);
            load(['../data/elan/' suj '.pt' num2str(p) '.' lst_dis{cc} 'DIS.mat']);
            
            cfg                  = [];
            cfg.bpfilter         = 'yes';
            cfg.bpfreq           = [0.5 20];
            data	             = ft_preprocessing(cfg,data_elan);
            
            t_list               = -0.18;
            tim_win              = 0.08;
            t_cond_list          = {'bsl'};
            
            for t = 1:length(t_list)
                
                cfg                  = [];
                cfg.latency          = [t_list(t) t_list(t)+tim_win(t)];
                new_data              = ft_selectdata(cfg,data);
                
                cfg                     = [];
                cfg.covariance          = 'yes';
                cfg.covariancewindow    = 'all';
                avg                     = ft_timelockanalysis(cfg,new_data);
                
                cfg                     =   [];
                cfg.method              =   'lcmv';
                cfg.grid                =   leadfield;
                cfg.grid.filter         =   spatialfilter;
                cfg.headmodel           =   vol;
                cfg.lcmv.fixedori       =   'yes';
                cfg.lcmv.projectnoise   =   'yes';
                cfg.lcmv.keepmom        =   'yes';
                cfg.lcmv.projectmom     =   'yes';
                cfg.lcmv.lambda         =   '15%';
                source                  =   ft_sourceanalysis(cfg, avg);
                source                  =   source.avg.pow;
                
                fname_out = [suj '.pt' num2str(p) '.' lst_dis{cc} 'DIS.' t_cond_list{t} '.lcmvSource'];
                fprintf('\n\nSaving %50s \n\n',fname_out);
                save(['../data/source/' fname_out '.mat'],'source','-v7.3')
                
                clear new_avg source ;
                
            end
        end
    end
end
