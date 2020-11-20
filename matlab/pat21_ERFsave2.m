clear ; clc ;dleiftrip_addpath;

suj_list = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj         = ['yc' num2str(suj_list(sb))] ;
    fname_in    = [suj '.C'];
    
    fprintf('Loading %50s\n',fname_in);
    load(['/Volumes/PAT_MEG/Fieldtripping/data/' suj '/elan/' fname_in '.mat'])
    
    data_f                  = data_elan ; clear data_elan ;
    
    cfg                     = [];
    cfg.bpfilter            = 'yes';
    cfg.bpfreq              = [0.5 20];
    data_f                  = ft_preprocessing(cfg,data_f);
    
    for cnd_cue = 1:2
        
        if cnd_cue == 1
            itrl = h_chooseTrial(data_f,[1 2],0,1:4);
        else
            itrl = h_chooseTrial(data_f,0,0,1:4);
        end
        
        cfg                             = [];
        cfg.trials                      = itrl ;
        allsuj{sb,cnd_cue}              = ft_timelockanalysis(cfg,data_f);
        allsuj{sb,cnd_cue}              = rmfield(allsuj{sb,cnd_cue},'cfg');
        
    end
    
    clear data_f
    
end

clearvars -except allsuj ;

save('../data/yctot/gavg/VN.nDT.eeg.pe.mat','-v7.3');