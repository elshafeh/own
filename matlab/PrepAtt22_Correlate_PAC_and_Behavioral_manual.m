clear ; clc ; 

addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));
addpath('../scripts.m/');

for sb = 1:21
    
    suj         = ['yc' num2str(sb)];
    lst_cnd     = {'RCnD','LCnD','NRCnD','NLCnD'};
    
    lst_mth     = {'PLV'};
    lst_chn     = {'audR'};
    lst_tme     = {'m1000m200','p200p1000'};
    
    
    for cnd = 1:length(lst_cnd)
        for chn = 1:length(lst_chn)
            for nmethod = 1:length(lst_mth)
                for ntime = 1:length(lst_tme)
                    
                    fname   = ['../data/' suj '/field/' suj '.' lst_cnd{cnd} '.NewRama3Cov.' lst_tme{ntime} '.' lst_chn{chn} '.' lst_mth{nmethod} 'PAC.mat'];
                    
                    fprintf('Loading %30s\n',fname);
                    load(fname);
                    
                    grand_avg{sb,cnd,chn,nmethod,ntime}.powspctrm(1,:,:)    = seymour_pac.mpac_norm;
                    grand_avg{sb,cnd,chn,nmethod,ntime}.freq                = seymour_pac.amp_freq_vec;
                    grand_avg{sb,cnd,chn,nmethod,ntime}.time                = seymour_pac.pha_freq_vec;
                    grand_avg{sb,cnd,chn,nmethod,ntime}.label               = {'MI'};
                    grand_avg{sb,cnd,chn,nmethod,ntime}.dimord              = 'chan_freq_time';
                    
                    clear seymour_pac
                    
                    
                    cfg                                                     = [];
                    cfg.latency                                             = [9 11];
                    cfg.frequency                                           = [55 75];
                    cfg.avgoverfreq                                         = 'yes';
                    cfg.avgovertime                                         = 'yes';
                    grand_avg{sb,cnd,chn,nmethod,ntime}                     = ft_selectdata(cfg,grand_avg{sb,cnd,chn,nmethod,ntime});
                    
                end
            end
        end
    end
end

clearvars -except grand_avg lst_* ; clc ; 

for sb = 1:size(grand_avg,1)
    for cnd = 1:size(grand_avg,2)
        for nchan = 1:size(grand_avg,3)
            for nmethod  =1:size(grand_avg,4)
                
                suj                             = ['yc' num2str(sb)];
                
                cfg                             = [];
                cfg.operation                   = 'x1-x2';
                cfg.parameter                   = 'powspctrm';
                new_gavg{sb,cnd,nchan,nmethod}  = ft_math(cfg,grand_avg{sb,cnd,nchan,nmethod,2},grand_avg{sb,cnd,nchan,nmethod,1});
                
                final_gavg(sb,cnd,nchan,nmethod) = new_gavg{sb,cnd,nchan,nmethod}.powspctrm;
                
                list_ix_cue        = {2,1,0,0};
                list_ix_tar        = {[2 4],[1 3],[2 4],[1 3]};
                list_ix_dis        = {0,0,0,0};
                
                [allsuj_behav{sb,cnd,nchan,nmethod,1},allsuj_behav{sb,cnd,nchan,nmethod,2},allsuj_behav{sb,cnd,nchan,nmethod,3},~] =  ...
                    h_behav_eval(suj,list_ix_cue{cnd},list_ix_dis{cnd},list_ix_tar{cnd}); clc ;
    
                
            end
        end
    end
end

grand_avg = final_gavg ; 

clearvars -except grand_avg allsuj_behav ; clc ; 

for cnd = 1:size(grand_avg,2)
    for nchan = 1:size(grand_avg,3)
        for nmethod  =1:size(grand_avg,4)
            for ntest = 1:size(allsuj_behav,5)
                
                
                behav_mat   = [allsuj_behav{:,cnd,nchan,nmethod,ntest}]';
                pac_mat     = grand_avg(:,cnd,nchan,nmethod);
                
                [h_val(cnd,nchan,nmethod,ntest),p_val(cnd,nchan,nmethod,ntest)] = corr(pac_mat,behav_mat,'type','Pearson');
                
            end
        end
    end
end

clearvars -except grand_avg allsuj_behav h_val p_val; clc ; 

h_val = squeeze(h_val);
p_val = squeeze(p_val);