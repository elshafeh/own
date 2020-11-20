clear ; clc ; dleiftrip_addpath ; close all ;

for j = 3
    
    for sb = 1:14
        
        suj_list                        = [1:4 8:17];
        suj                             = ['yc' num2str(suj_list(sb))];
        
        load(['../data/all_data/' suj '.CnD.Rama3Cov.AllPlusAll.OnlyPLV.mat'])
        
        allsuj_GA{sb,j}.powspctrm       = [];
        allsuj_GA{sb,j}.time            = suj_coh{j}.time;
        allsuj_GA{sb,j}.freq            = suj_coh{j}.freq;
        allsuj_GA{sb,j}.dimord          = 'chan_freq_time';
        allsuj_GA{sb,j}.label           = {};
        
        aud_list    = [1 2];
        chan_list   = [1 2 7 9 15 21 31];
        
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
                        allsuj_GA{sb,j}.powspctrm(i,:,:)                = squeeze(suj_coh{j}.powspctrm(aud_list(x),chan_list(y),:,:));
                        allsuj_GA{sb,j}.label{end+1}                    = [suj_coh{j}.label{aud_list(x)} ' ' num2str(aud_list(x)) ' ' suj_coh{j}.label{chan_list(y)} ' ' num2str(chan_list(y))];
                        
                    end
                end
            end
        end
        
        [allsuj_activation{sb,j},allsuj_baselineRep{sb,j}]      = h_prepareBaseline(allsuj_GA{sb,j},[-0.6 -0.2],[7 15],[0.45 1.6],'no');
        
        clear coh_suj;
        
    end
end

clearvars -except allsuj_* ; clc ;

[design,neighbours]     = h_create_design_neighbours(length(allsuj_activation),allsuj_activation{1,3},'virt','t');

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'depsamplesT';
cfg.correctm            = 'cluster';
% cfg.avgoverfreq         = 'yes';
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

j = 3 ;

stat{j}                 = ft_freqstatistics(cfg, allsuj_activation{:,j}, allsuj_baselineRep{:,j});
[min_p(j),p_val{j}]     = h_pValSort(stat{j});

stat2plot{j}            = h_plotStat(stat{j},0.000000000000000000000000001,0.1);

i = 0 ; close all ;

for chn = 1:length(stat{j}.label)
    
    if max(max(abs(stat2plot{j}.powspctrm(chn,:,:)))) ~=0
        
        figure;
        
        %         plot(stat2plot{j}.time,squeeze(stat2plot{j}.powspctrm(chn,:,:)));
        %         ylim([-5 5]);
        %         title(stat2plot{j}.label{chn});
        %         xlim([stat2plot{j}.time(1) stat2plot{j}.time(end)])
        
        cfg             =[];
        cfg.channel     = chn;
        cfg.zlim        = [-5 5];
        ft_singleplotTFR(cfg,stat2plot{j});clc;
        
    end
end