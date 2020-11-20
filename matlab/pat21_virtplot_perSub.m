clear ; clc ;
for a = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(a))];
    
    ext1        =   'AudViz.VirtTimeCourse.all.wav' ;
    ext2        =   '1t90Hz.m2000p2000.mat';
    lst         =   'L';
    lstdis      =   {'DIS','fDIS'};
    lstevoked   =   {'.','.Evoked.'};
    
    for cnd_cue = 1
        for cnd_dis = 1:2
            for cnd_e = 1:2
                
                fname_in    = ['../data/tfr/' suj '.'  lst(cnd_cue) lstdis{cnd_dis} '.' ext1 lstevoked{cnd_e} ext2];
                fprintf('\nLoading %50s \n',fname_in);
                load(fname_in)
                
                if isfield(freq,'hidden_trialinfo')
                    freq        = rmfield(freq,'hidden_trialinfo');
                end
                
                nw_chn      = [4 6];
                nw_lst      = {'audR'};
                
                for l = 1
                    cfg             = [];
                    cfg.channel     = nw_chn(l,:);
                    cfg.avgoverchan = 'yes';
                    nwfrq{l}        = ft_selectdata(cfg,freq);
                    nwfrq{l}.label  = nw_lst(l);
                end
                
                cfg                     = [];
                cfg.parameter           = 'powspctrm';
                cfg.appenddim           = 'chan';
                tf_evoked{cnd_e}        = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
            end
            
            cfg                                     = [];
            cfg.parameter                           = 'powspctrm';
            cfg.operation                           = 'x1-x2';
            tf_dis{cnd_dis}                         = ft_math(cfg,tf_evoked{1},tf_evoked{2}); clear tf_evoked ;
            
        end
        
        cfg                                         = [];
        cfg.parameter                               = 'powspctrm';
        cfg.operation                               = 'x1-x2';
        allsuj                                      = ft_math(cfg,tf_dis{1},tf_dis{2}); clear tf_dis ;
         
        cfg                                         = [];
        cfg.frequency                               = [7 15];
        cfg.avgoverfreq                             = 'yes';
        cfg.latency                                 = [-0.2 0.8];
        allsuj                                      = ft_selectdata(cfg,allsuj);
        
        bgmatrx(a,:)                              = squeeze(allsuj.powspctrm);
        
        
    end
end

clearvars -except bgmatrx allsuj;

lgnd_list = {} ;
suj_list = [1:4 8:17];
for sb = 1:14
    lgnd_list{sb} = ['yc' num2str(sb)];
end


plot(allsuj.time,bgmatrx) ; xlim([-0.2 0.8]);legend(lgnd_list);
