clear ; clc ; dleiftrip_addpath ; close all ;

for j = 3
    
    for sb = 1:14
        
        suj_list                    = [1:4 8:17];
        suj                         = ['yc' num2str(suj_list(sb))];
        cue_list                    = 'NLR';
        
        clc;fprintf('Handling %s\n',suj);
        
        for cnd = 1:3
            
            load(['../data/all_data/' suj '.' cue_list(cnd) 'CnD.Rama3Cov.AllPlusAll.OnlyPLV.mat'])
            
            allsuj_GA{sb,j,cnd}.powspctrm       = [];
            allsuj_GA{sb,j,cnd}.time            = suj_coh{j}.time;
            allsuj_GA{sb,j,cnd}.freq            = suj_coh{j}.freq;
            allsuj_GA{sb,j,cnd}.dimord          = 'chan_freq_time';
            allsuj_GA{sb,j,cnd}.label           = {};
            
            aud_list    = [1 2];
            chan_list   = [1 2 7];
            lst_done    = {};
            
            i           = 0;
            
            for x = 1:length(aud_list)
                for y = 1:length(chan_list)
                    if aud_list(x) ~= chan_list(y)
                        
                        flg = [num2str(aud_list(x)) '.' num2str(chan_list(y))];
                        
                        if isempty(find(strcmp(lst_done,flg)))
                            
                            lst_done{end+1}                                 = [num2str(aud_list(x)) '.' num2str(chan_list(y))];
                            lst_done{end+1}                                 = [num2str(chan_list(y)) '.' num2str(aud_list(x))];
                            
                            i                                               = i +1;
                            allsuj_GA{sb,j,cnd}.powspctrm(i,:,:)            = squeeze(suj_coh{j}.powspctrm(aud_list(x),chan_list(y),:,:));
                            allsuj_GA{sb,j,cnd}.label{end+1}                = [suj_coh{j}.label{aud_list(x)} ' ' num2str(aud_list(x)) ' ' suj_coh{j}.label{chan_list(y)} ' ' num2str(chan_list(y))];
                        end
                    end
                end
            end
            
            twin                                    = 0.1;
            tlist                                   = -3:twin:3;
            pow                                     = [];
            
            if twin ~=0
                for t = 1:length(tlist)
                    x1  = find(round(allsuj_GA{sb,j,cnd}.time,3) == round(tlist(t),3)); x2 = find(round(allsuj_GA{sb,j,cnd}.time,3) == round(tlist(t)+twin,3));
                    tmp = squeeze(mean(allsuj_GA{sb,j,cnd}.powspctrm(:,:,x1:x2),3));
                    pow = cat(3,pow,tmp);
                    clear tmp ;
                end
                
                allsuj_GA{sb,j,cnd}.time        =  tlist;
                allsuj_GA{sb,j,cnd}.powspctrm   =  pow; clear pow;
            end
            
            cfg                 = [];
            cfg.baseline        = [-0.6 -0.2];
            cfg.baselinetype    = 'absolute';
            allsuj_GA{sb,j,cnd} = ft_freqbaseline(cfg,allsuj_GA{sb,j,cnd});
            
            cfg                 = [];
            cfg.latency         = [0.6 1.8];
            %             cfg.avgoverfreq     = 'yes';
            cfg.frequency       = [7 15];
            allsuj_GA{sb,j,cnd} = ft_selectdata(cfg,allsuj_GA{sb,j,cnd});
            
            clear coh_suj;
            
        end
    end
end

clearvars -except allsuj_* j; clc ;

[design,neighbours]     = h_create_design_neighbours(length(allsuj_GA),allsuj_GA{1,j,1},'virt','t');

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'depsamplesT';
cfg.correctm            = 'cluster'; 
cfg.clusteralpha        = 0.05;
cfg.alpha               = 0.025;
cfg.minnbchan           = 0;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.numrandomization    = 1000;
cfg.design              = design;
cfg.neighbours          = neighbours;
cfg.uvar                = 1;
cfg.ivar                = 2;

for j = 3
    stat{j,1}           = ft_freqstatistics(cfg, allsuj_GA{:,j,3}, allsuj_GA{:,j,2});
    stat{j,2}           = ft_freqstatistics(cfg, allsuj_GA{:,j,3}, allsuj_GA{:,j,1});
    stat{j,3}           = ft_freqstatistics(cfg, allsuj_GA{:,j,2}, allsuj_GA{:,j,1});
end

for j = 3
    for cs = 1:3
        [min_p(j,cs),p_val{j,cs}]           = h_pValSort(stat{j,cs});
        stat2plot{j,cs}                     = h_plotStat(stat{j,cs},0.000000000000000000000000001,0.2);
    end
end

for chn = 1:length(stat{j}.label)
    
    figure;
    
    lst_tst = {'RL','RN','LN'};
    
    for j = 3
        for cs = 1:3
            
            %             if max(max(abs(stat2plot{j,cs}.powspctrm(chn,:,:)))) ~=0
            
            subplot(3,1,cs);
            
            cfg             =[];
            cfg.channel     = chn;
            cfg.zlim        = [-5 5];
            ft_singleplotTFR(cfg,stat2plot{j,cs});clc;
            
            %             plot(round(stat2plot{j,cs}.time),squeeze(stat2plot{j,cs}.powspctrm(chn,:,:)))
            %             xlim([round(stat2plot{j,cs}.time(1)) round(stat2plot{j,cs}.time(end))])
            %             ylim([-5 5])
            
            title([stat2plot{j,cs}.label{chn} ' ' lst_tst{cs}]);
            
            %             end
        end
    end
    
    %     saveas(gcf,['../images/plv/cluster/avg_over_time_' stat2plot{j,cs}.label{chn} '.png'])
    %     close all;
    
end