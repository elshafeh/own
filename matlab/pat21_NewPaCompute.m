clear ; clc ; close all ; dleiftrip_addpath ;

for sub = 1:21
    
    suj         = ['yc' num2str(sub)];
    list_cue    = {'NLCnD','NRCnD','LCnD','RCnD'};
    
    for ncue = 1:length(list_cue)
        
        fname       = ['../data/new_rama_data/' suj '.' list_cue{ncue} '.NewRama.1t20Hz.m800p2000msCov.audR.mat'];
        fprintf('Loading %30s\n',fname);
        load(fname);
        
        big_pha     = virtsens ; clear virtsens;
        
        fname       = ['../data/new_rama_data/' suj '.' list_cue{ncue} '.NewRama.50t120Hz.m800p2000msCov.audR.mat'];
        fprintf('Loading %30s\n',fname);
        load(fname);
        
        big_amp     = virtsens ; clear virtsens;
        
        list_method = {'tort','ozkurt'};
        list_time   = [-1 0.2];
        list_wind   = 0.8;
            
        lst_chan    = 1;
        ntotal      = length(list_method) * size(list_time,2) * length(list_cue) * length(lst_chan);
        i           = 0;
        
        original_virtsens_pha   = big_pha; clear big_pha ;
        original_virtsens_amp   = big_amp; clear big_amp ;
        
        for chan = 1:length(lst_chan)
            
            cfg                         = [];
            cfg.channel                 = lst_chan(chan);
            chan_slct_virtsens_pha      = ft_selectdata(cfg,original_virtsens_pha);
            chan_slct_virtsens_amp      = ft_selectdata(cfg,original_virtsens_amp);
            
            for nme = 1:length(list_method)
                for ntime = 1:size(list_time,2)
                    
                    i                               = i+1;
                    
                    tt                              = [suj '.period' num2str(ntime) '.' original_virtsens_pha.label{1} ' (Test ' num2str(i) '/' num2str(ntotal) ')'];
                    
                    pha_freq_vec                    = [7 13];
                    amp_freq_vec                    = [50 110];
                    
                    pha_step                        = 1;
                    amp_step                        = 5;
                    
                    [mpac,mpac_norm,mpac_surr]      = separate_calc_MI_appendTrials(tt,chan_slct_virtsens_pha,chan_slct_virtsens_amp, ...
                       [list_time(ntime) list_time(ntime)+list_wind],pha_freq_vec,amp_freq_vec,'no','no',list_method{nme},pha_step,amp_step);
                    
                    seymour_pac.pha_freq_vec         = pha_freq_vec(1):pha_step:pha_freq_vec(2);
                    seymour_pac.amp_freq_vec         = amp_freq_vec(1):amp_step:amp_freq_vec(2);
                    seymour_pac.mpac                 = mpac;
                    seymour_pac.mpac_norm            = mpac_norm;
                    seymour_pac.mpac_surr            = mpac_surr;
                    
                    clear mpac*
                    
                    clc;
                    
                    if list_time(ntime) < 0
                        ext_time    = ['m' num2str(abs(list_time(ntime))*1000) 'm' num2str(abs(list_time(ntime)+list_wind)*1000)];
                    else
                        ext_time    = ['p' num2str(abs(list_time(ntime))*1000) 'p' num2str(abs(list_time(ntime)+list_wind)*1000)];
                    end
                    
                    fname_ext1  = ['../data/new_rama_data/' suj '.' list_cue{ncue} '.NewRama3Cov'];
                    fname_ext2  = ['.' ext_time '.' chan_slct_virtsens_pha.label{1} '.' list_method{nme} '.AppendTrialPAC.mat'];
                    
                    save([fname_ext1 fname_ext2],'seymour_pac','-v7.3');
                    
                    clear seymour_pac fname_*
                    
                end
            end
        end
    end
end