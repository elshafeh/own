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
                
                suj         = ['yc' num2str(sb)];
                
                cfg             = [];
                cfg.operation = 'x1-x2';
                cfg.parameter = 'powspctrm';
                new_gavg{sb,cnd,nchan,nmethod} = ft_math(cfg,grand_avg{sb,cnd,nchan,nmethod,2},grand_avg{sb,cnd,nchan,nmethod,1});
                
                list_ix_cue        = {2,1,0,0};
                list_ix_tar        = {[2 4],[1 3],[2 4],[1 3]};
                list_ix_dis        = {0,0,0,0};
                
                
                [allsuj_behav{sb,cnd,nchan,nmethod,1},allsuj_behav{sb,cnd,nchan,nmethod,2},allsuj_behav{sb,cnd,nchan,nmethod,3},~] =  h_behav_eval(suj,list_ix_cue{cnd},list_ix_dis{cnd},list_ix_tar{cnd}); clc ;
    
                
            end
        end
    end
end

grand_avg = new_gavg ; 

clearvars -except grand_avg allsuj_behav ; clc ; 

for cnd = 1:size(grand_avg,2)
    for nchan = 1:size(grand_avg,3)
        for nmethod  =1:size(grand_avg,4)
            for ntest = 1:size(allsuj_behav,5)
                
                cfg                                 = [];
                cfg.method                          = 'montecarlo';
                cfg.statistic                       = 'ft_statfun_correlationT';
                
                cfg.correctm                        = 'fdr';
                cfg.clusterstatistics               = 'maxsum';
                
                cfg.clusteralpha                    = 0.05;
                cfg.tail                            = 0;
                cfg.clustertail                     = 0;
                cfg.alpha                           = 0.025;
                cfg.numrandomization                = 1000;
                cfg.ivar                            = 1;
                cfg.type                            = 'Pearson';
                
                nsuj                                = size(allsuj_behav,1);
                
                cfg.design(1,1:nsuj)                = [allsuj_behav{:,cnd,nchan,nmethod,ntest}];
                
                lst_behav                           = {'medianRT','meanRT','perCorrect'};
                lst_cnd     = {'RCnD','LCnD','NRCnD','NLCnD'};
                
                stat{cnd,nchan,nmethod,ntest}       = ft_freqstatistics(cfg, grand_avg{:,cnd,nchan,nmethod});
                
                stat{cnd,nchan,nmethod,ntest}       = rmfield(stat{cnd,nchan,nmethod,ntest},'cfg');
                
                stat{cnd,nchan,nmethod,ntest}.label = {[lst_cnd{cnd} '.' lst_behav{ntest}]};
                
            end
        end
    end
end

clearvars -except grand_avg allsuj_behav stat ; clc ; close all;


for cnd = 1:size(stat,1)
    for nchan = 1:size(stat,2)
        for nmethod  =1:size(stat,3)
            
            i = 0;
            figure;
            
            for ntest = 1:size(stat,4)
                
                s_to_plot       = stat{cnd,nchan,nmethod,ntest};
                s_to_plot.mask  = s_to_plot.prob < 0.11;
                
                i = i + 1;
                subplot(2,2,i)
                
                cfg                 = [];
                cfg.parameter       = 'stat';
                cfg.maskparameter   = 'mask';
                cfg.maskstyle       = 'outline';
                cfg.zlim            = [-5 5];
                ft_singleplotTFR(cfg,s_to_plot);
                colormap('jet')
                
            end
        end
    end
end

clearvars -except grand_avg allsuj_behav stat