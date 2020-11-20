clear ; clc ; close all ; dleiftrip_addpath ;

for sub = 1:14
    
    suj_list = [1:4 8:17];
    
    suj     = ['yc' num2str(suj_list(sub))];
    fname   = ['../data/all_data/' suj '.CnD.RamaBigCovSlctAuditory.mat'];
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    list_method = {'tort','ozkurt','canolty','PLV'};
    list_time   = [-0.6 -0.2; 0.2 0.6; 0.6 1];
    list_period = {'bsl','early','late'};
    
    ntotal      = length(virtsens.label) * length(list_method) * size(list_time,1);
    i           = 0;
    
    for chan = 1:length(virtsens.label)
        
        cfg         = [];
        %         cfg.trials  = find(round((virtsens.trialinfo-1000)/100)==cnd-1);
        cfg.channel = chan;
        virt_slct   = ft_selectdata(cfg,virtsens);
        
        for nme = 1:length(list_method)
            for ntime = 1:size(list_time,1)
                
                i                               = i +1 ;
                tt                              = [suj '.period' num2str(ntime) '.' virt_slct.label{1} ' (Test ' num2str(i) '/' num2str(ntotal) ')'];
                
                pha_freq_vec                    = [7 15];
                amp_freq_vec                    = [50 100];
                
                pha_step                        = 2;
                amp_step                        = 10;
                
                [mpac,mpac_norm,mpac_surr]      = calc_MI(tt,virt_slct,list_time(ntime,:),pha_freq_vec,amp_freq_vec,'no','yes',list_method{nme},pha_step,amp_step);
                
                % They filter after
                
                mpac_index.pha_freq_vec         = pha_freq_vec(1):pha_step:pha_freq_vec(2);
                mpac_index.amp_freq_vec         = amp_freq_vec(1):amp_step:amp_freq_vec(2);
                
                save(['../data/all_data/' suj '.CnD.RamaBigCovSlctAuditory.period' upper(list_period{ntime}) '.' virt_slct.label{1} '.' list_method{nme} 'PAC.mat'],'mpac','mpac_norm','mpac_surr','mpac_index','-v7.3');
                
                clear pha_freq_vec amp_freq_vec pha_step amp_step mpac mpac_norm mpac_surr mpac_index
                
            end
        end
        
        clear virt_slct
        
    end
    
    clearvars -except sub;
    
end