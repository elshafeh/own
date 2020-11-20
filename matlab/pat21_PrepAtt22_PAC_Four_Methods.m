clear ; clc ; close all ; dleiftrip_addpath ;

for sub = 10:14
    
    suj_list = [1:4 8:17];
    
    suj         = ['yc' num2str(suj_list(sub))];
    list_cond   = {'NLCnD','NRCnD','LCnD','RCnD'};
    
    for cnd = 1:length(list_cond)
        
        fname   = ['../data/new_rama_data/' suj '.NewRama.50t120Hz.m800p2000msCov.audR.mat'];
        fprintf('Loading %30s\n',fname);
        load(fname);
        
        for chan = 1:length(virtsens.label)
            
            list_method = {'PLV'};
            list_time   = [-0.35 0.2:0.15:1];
            list_wind   = 0.15;
            ntotal      = length(virtsens.label) * length(list_method) * size(list_time,1) * length(list_cond);
            i           = 0;
            
            for nme = 1:length(list_method)
                for ntime = 1:size(list_time,1)
                    
                    i                               = i +1 ;
                    tt                              = [suj '.' list_cond{cnd} '.period' num2str(ntime) '.' virt_slct.label{1} ' (Test ' num2str(i) '/' num2str(ntotal) ')'];
                    
                    pha_freq_vec                    = [7 15];
                    amp_freq_vec                    = [50 100];
                    
                    pha_step                        = 2;
                    amp_step                        = 5;
                    
                    [mpac,mpac_norm,mpac_surr]      = calc_MI(tt,virt_slct,[list_time(ntime) list_time(ntime)+list_wind] ,pha_freq_vec,amp_freq_vec,'no','yes',list_method{nme},pha_step,amp_step);
                    
                    mpac_index.pha_freq_vec         = pha_freq_vec(1):pha_step:pha_freq_vec(2);
                    mpac_index.amp_freq_vec         = amp_freq_vec(1):amp_step:amp_freq_vec(2);
                    
                    save(['../data/all_data/' suj '.' list_cond{cnd} '.period' num2str(ntime) '.' virt_slct.label{1} '.' list_method{nme} 'PAC.mat'],'mpac','mpac_norm','mpac_surr','mpac_index','-v7.3');
                    
                    clear pha_freq_vec amp_freq_vec pha_step amp_step mpac mpac_norm mpac_surr mpac_index
                    
                end
            end
            
            clear virt_slct
            
        end
    end
    
    clearvars -except sub;
    
end


% [stat_canolty] = get_PAC_stats('matrix_post_canolty.mat','matrix_pre_canolty',[7 15],[34 100],subject,scripts_dir,0);
% [stat_canolty_surr] = get_PAC_stats('matrix_post_canolty_surrogates.mat','matrix_pre_canolty_surrogates',[7 13],[34 100],subject,scripts_dir,1);
% make_smoothed_comodulograms(stat_canolty, [7 13], [34 100]);
% title('Canolty 2006 - no surr');
% make_smoothed_comodulograms(stat_canolty_surr, [7 13], [34 100]);
% title('Canolty 2006 - with surr');