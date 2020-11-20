clear ; clc ; close all ; dleiftrip_addpath;

cndtions = {'RCnD','LCnD','NCnD','VCnD','CnD'};

suj_list = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    for cnd = 1:length(cndtions)
        
        for pt = 1:3
            
            fname_in = dir(['../data/' suj '/pe/' suj '.pt' num2str(pt) '.' cndtions{cnd} '.RevFinalBaselineTimeCourse.mat']);
            fprintf('\nLoading %50s \n',fname_in.name);
            load(['../data/' suj '/pe/' fname_in.name])
            
            tmp{pt} = virtsens ; clear virtsens ;
            
        end
        
        clear b
        
        data = ft_appenddata([],tmp{:});
        
        clear tmp
        
        chan_list{1}= 1:20;
        chan_list{2}= 21:32;
        chan_list{3}= 33:35;
        chan_list{4}= 36:37;
        chan_list{5}= 38:57;
        chan_list{6}= 58:84;
        
        chn_label = {'CAL','CAR','HGL','HGR','STGL','STGR'};
        
        for chn = 1:6
            cfg                     = [];
            cfg.channel             = chan_list{chn};
            cfg.avgoverchan         = 'yes';
            chn_tmp{chn}            = ft_selectdata(cfg,data); % no subtraction ; just the induced
            chn_tmp{chn}.label      = chn_label(chn);
        end
        
        data             = ft_appenddata([],chn_tmp{:});
        
        clear chn_tmp
        
        cfg                 = [];
        cfg.method          = 'mtmconvol';
        cfg.taper           = 'dpss';
        cfg.output          = 'powandcsd';
        cfg.foi             = 1:1:20;
        cfg.toi             = -3:0.05:3;
        cfg.t_ftimwin       = 4./cfg.foi;
        cfg.tapsmofrq       = 0.3.*cfg.foi;
        allsuj{sb,cnd}      = ft_freqanalysis(cfg,data);
        
        clear data cfg
        
    end
    
end

clearvars -except allsuj

save('../data/yctot/SayWhatFinalFFT.mat');