clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_list,~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}    = suj_list(2:22);

[~,allsuj,~]        = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
% suj_group{1}        = allsuj(2:15,1);
% suj_group{2}        = allsuj(2:15,2);
suj_group{2}        = [allsuj(2:15,1);allsuj(2:15,2)];

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        list_ix_cue    = {''};
        
        for cnd = 1:length(list_ix_cue)
            
            suj                 = suj_list{sb};
            
            fname_in            = ['../data/' suj '/field/' suj '.' list_ix_cue{cnd} 'CnD.waveletPOW.40t150Hz.m1000p2000.10Mstep.AvgTrials.MinEvoked.mat'];
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            freq                                = ft_freqdescriptives([],freq);
            freq                                = rmfield(freq,'cfg');
            
            [tmp{1},tmp{2}]                     = h_prepareBaseline(freq,[-0.3 -0.1],[40 120],[-0.1 2],'no');
            
            allsuj_activation{ngroup}{sb,cnd}   = tmp{1};
            allsuj_baselineRep{ngroup}{sb,cnd}  = tmp{2};
            
            clear tmp freq
            
        end
        
        clear big_freq
        
    end
end

clearvars -except allsuj_*;

for ngroup = 1:length(allsuj_activation)
    
    nsuj                        = size(allsuj_activation{ngroup},1);
    [design,neighbours]         = h_create_design_neighbours(nsuj,allsuj_activation{1}{1},'meg','t'); clc;
    
    for ncue = 1:size(allsuj_activation{ngroup},2)
        
        cfg                     = [];
        cfg.clusterstatistic    = 'maxsum';
        
        %         cfg.latency             = [0.6 1];
        
        %         cfg.frequency           = [60 100];
        %         cfg.avgoverfreq         = 'yes';
        %         cfg.avgovertime         = 'yes';

        cfg.method              = 'montecarlo';
        cfg.statistic           = 'depsamplesT';
        cfg.correctm            = 'cluster';
        
        cfg.neighbours          = neighbours;
        
        cfg.clusteralpha        = 0.05; % !!
        
        cfg.alpha               = 0.025;
        
        cfg.minnbchan           = 2; % !!

        cfg.tail                = 1; % !!
        cfg.clustertail         = 1; % !!
        
        cfg.numrandomization    = 1000;
        cfg.design              = design;
        cfg.uvar                = 1;
        cfg.ivar                = 2;
        
        stat{ngroup,ncue}       = ft_freqstatistics(cfg, allsuj_activation{ngroup}{:,ncue},allsuj_baselineRep{ngroup}{:,ncue});
        stat{ngroup,ncue}       = rmfield(stat{ngroup,ncue},'cfg');
        
    end
end

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        [min_p(ngroup,ncue), p_val{ngroup,ncue}]  = h_pValSort(stat{ngroup,ncue}) ;
    end
end

clearvars -except allsuj_* stat min_p p_val;

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        
        plimit                  = 0.05;
        
        stat2plot               = h_plotStat(stat{ngroup,ncue},0.000000000000000000000000000001,plimit);
        
        subplot(2,1,ngroup)
        
        cfg         = [];
        cfg.layout  = 'CTF275.lay';
        %         cfg.xlim    = -0.2:0.2:1.2;
        cfg.zlim    = [-1 1];
        cfg.marker  = 'off';
        %         cfg.comment = 'no';
        ft_topoplotER(cfg,stat2plot);
        
    end
end

% stat2plot               = h_plotStat(stat{ngroup,ncue},0.000000000000000000000000000001,plimit);
%
% subplot(2,2,[1 3])
%
% cfg         = [];
% cfg.layout  = 'CTF275.lay';
% cfg.xlim    = [0.6 1];
% cfg.ylim    = [20 30];
% cfg.zlim    = [-1 1];
% cfg.marker  = 'off';
% cfg.comment = 'no';
% ft_topoplotTFR(cfg,stat2plot);
%
% cfg                 = [];
% cfg.channel         = {'MLC17', 'MLC25', 'MLC32', 'MLC42', 'MLC54', 'MLF67', 'MLP12', 'MLP22', 'MLP23', 'MLP33', 'MLP34', 'MLP35', 'MLP44', 'MLP45', 'MLP56', 'MLP57', 'MLT15'};
% cfg.avgoverchan     = 'yes';
% stat2plot           = ft_selectdata(cfg,stat2plot);
%
% subplot(2,2,2)
% plot(stat2plot.freq,squeeze(nanmean(stat2plot.powspctrm,3)))
% ylim([-6 0]);
% xlim([stat2plot.freq(1) stat2plot.freq(end)])
% vline(20,'--k','20Hz')
% vline(30,'--k','30Hz')
%
% cfg                 = [];
% cfg.frequency       = [20 30];
% cfg.avgoverfreq     = 'yes';
% stat2plot           = ft_selectdata(cfg,stat2plot);
%
% subplot(2,2,4)
% plot(stat2plot.time,squeeze(stat2plot.powspctrm))
% ylim([-6 0]);
% xlim([-0.2 1.2])
% vline(0.3,'--k','200ms')
% vline(0.6,'--k','600ms')
%
%
%
% title([tit_ext1 '.' tit_ext2 '.' list_ix_cue{ncue} 'CnD'])
%
%
% cfg.ylim    = [flist(f,1) flist(f,2)];
% stat2plot.powspctrm(stat2plot.powspctrm>0) = 0;
% twin                    = 0.2;
% tlist                   = stat{ngroup,ncue}.time(1):twin:stat{ngroup,ncue}.time(end);
% zlimit                  = 4;
% flist                   = [7 11; 11 15];
%
%
%
% i  = 0 ;
%
% cfg         = [];
% cfg.channel = {'MLC14', 'MLC15', 'MLC16', 'MLC17', 'MLC21', 'MLC22', 'MLC23', 'MLC24', 'MLC25', 'MLC31', 'MLC32', 'MLC41', 'MLC42', ...
%     'MLC52', 'MLC53', 'MLC54', 'MLC55', 'MLC62', 'MLF46', 'MLF55', 'MLF56', 'MLF64', 'MLF65', 'MLF66', 'MLF67', 'MLP12', 'MLP22', ...
%     'MLP23', 'MLP33', 'MLP34', 'MLP35', 'MLP44', 'MLP45', 'MLP56', 'MLP57', 'MLT13', 'MLT14', 'MLT15'};
% stat2plot   = ft_selectdata(cfg,stat2plot);
%
%
% avg.time    = stat2plot.freq;
% avg.avg     = squeeze(mean(mean(stat2plot.powspctrm,1),3))';
%
% plot(avg.time,avg.avg);
% ylim([-5 0]);
% xlim([avg.time(1) avg.time(end)])
%
% for f = 1:length(flist)
%     tit_ext1    = ''; %[num2str(round(mean([flist(f,1) flist(f,2)]))) 'Hz'];
%     tit_ext2    = [num2str(round(mean([tlist(t) tlist(t)+twin])*1000)) 'ms'];
% end
% for t = 1:length(tlist)-1
%     i = i + 1;
% end
% subplot(length(flist),length(tlist)-1,i)
%
% clearvars -except allsuj_* stat min_p p_val;
%
% clearvars -except stat;
% save('../data_fieldtrip/stat/AgainstBaseline.12OldYoung.7t15Hzm200p1200.AllPlanar.mat','stat','-v7.3');
%
% for ngroup = 1:size(stat,1)
%
%     i = 0 ;
%
%     for ncue = 1:size(stat,2)
%         for ntime = 1:size(stat,3)
%
%             i = i + 1;
%             subplot(size(stat,2),size(stat,3),i)
%
%             twin                    = 0.2;
%             tlist                   = stat{ngroup,ncue,ntime}.time(1):twin:stat{ngroup,ncue,ntime}.time(end);
%             zlimit                  = 3;
%             plimit                  = 0.11;
%
%             for clustno = 1:length(stat{ngroup,ncue,ntime}.posclusters)
%
%                 if stat{ngroup,ncue,ntime}.posclusters(clustno).prob < plimit
%
%                     figure;
%
%                     stat2plot               = h_plotStat(stat{ngroup,ncue,ntime},0.000000000000000000000000000001,plimit);
%                     stat2plot.powspctrm(stat{ngroup,ncue,ntime}.posclusterslabelmat~=clustno)=0;
%
%                     for t = 1:length(tlist)-1
%                         subplot(3,4,t)
%                         cfg         = [];
%                         cfg.layout  = 'CTF275.lay';
%                         cfg.xlim    = [tlist(t) tlist(t)+twin];
%                         cfg.zlim    = [-zlimit zlimit];
%                         cfg.marker  = 'off';
%                         ft_topoplotER(cfg,stat2plot);
%                     end
%
%                     clear stat2plot
%
%                 end
%             end
%
%             for clustno = 1:length(stat{ngroup,ncue,ntime}.negclusters)
%
%                 if stat{ngroup,ncue,ntime}.negclusters(clustno).prob < plimit
%                     figure;
%                     stat2plot               = h_plotStat(stat{ngroup,ncue,ntime},0.000000000000000000000000000001,plimit);
%                     stat2plot.powspctrm(stat{ngroup,ncue,ntime}.negclusterslabelmat~=clustno)=0;
%                     for t = 1:length(tlist)-1
%                         subplot(3,4,t)
%                         cfg         = [];
%                         cfg.layout  = 'CTF275.lay';
%                         cfg.xlim    = [tlist(t) tlist(t)+twin];
%                         cfg.zlim    = [-zlimit zlimit];
%                         cfg.marker  = 'off';
%                         ft_topoplotER(cfg,stat2plot);
%                     end
%                     clear stat2plot
%                 end
%             end
%         end
%     end
% end