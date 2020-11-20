% poi = 0.065 to 0.165
% Adhering to Weisz + Bael Method

clear ; clc ;

suj_list =[1:4 8:17];

for s = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(s))] ;
    
    load(['../data/headfield/' suj '.VolGrid.5mm.mat']);
    
    for p = 1:3
        
        load(['../data/headfield/' suj '.pt' num2str(p) '.adjusted.leadfield.5mm.mat']);
        
        cnd = 'nDT';
        
        fprintf('\nLoading %30s\n',['../data/elan/' suj '.pt' num2str(p) '.' cnd '.mat']);
        load(['../data/elan/' suj '.pt' num2str(p) '.' cnd '.mat']);
        
        cfg                  = [];
        cfg.bpfilter         = 'yes';
        cfg.bpfreq           = [0.5 20];
        data	             = ft_preprocessing(cfg,data_elan);
        
        ext_essai            = 'nDT.N1';
        fname_out           = [suj '.pt' num2str(p) '.' ext_essai '.CommonFilter'];
        fprintf('\n\nLoading %50s \n\n',fname_out);
        load(['../data/filter/' fname_out '.mat'])
        
        for cnd_cue = 1:4
            
            cfg = [];
            if cnd_cue < 4
                cfg.trials = h_chooseTrial(data,cnd_cue-1,0,1:4);
            else
                cfg.trials = h_chooseTrial(data,[1 2],0,1:4);
            end
            
            data_slct  = ft_selectdata(cfg,data);
            
            t_list               = [-0.2 0.065];
            tim_win              = 0.1;
            
            for t = 1:length(t_list)
                
                cfg                  = [];
                cfg.latency          = [t_list(t) t_list(t)+tim_win];
                new_data              = ft_selectdata(cfg,data_slct);
                
                cfg                  = [];
                cfg.covariance       = 'yes';
                cfg.covariancewindow = 'all';
                avg                  = ft_timelockanalysis(cfg,new_data);
                
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
                
                source                  = source.avg.pow;
                
                ltc = {'bsl','actv'};
                lc  = 'NLRV' ;
                
                ext_essai = 'nDT.N1';
                fname_out = [suj '.pt' num2str(p) '.' lc(cnd_cue) ext_essai '.' ltc{t} '.lcmvSource'];
                fprintf('\n\nSaving %50s \n\n',fname_out);
                save(['../data/source/' fname_out '.mat'],'source','-v7.3')
                
                clear new_avg source ;
                
            end
            
        end
    end
end