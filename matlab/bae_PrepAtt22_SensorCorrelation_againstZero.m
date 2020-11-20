clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]            = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
suj_group{1}            = allsuj(2:15,1);
suj_group{2}            = allsuj(2:15,2);
suj_group{3}            = [suj_group{2};suj_group{1}];

[~,suj_group{4},~]      = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{4}            = suj_group{4}(2:22);


for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj             = suj_list{sb};
        suj_list        = suj_group{ngroup};
        
        fname_in        = ['../data/' suj '/field/' suj '.CnD.waveletPOW.1t20Hz.m3000p3000.KeepTrials.mat'];
        
        if ~exist(fname_in)
            fname_in    = ['../data/' suj '/field/' suj '.CnD.waveletPOW.1t20Hz.m3000p3000.KeepTrials..mat'];
        end
        
        fprintf('Loading %50s\n',fname_in);
        load(fname_in);
        
        fprintf('Baseline Correction for %s\n',suj)
        
        %         load(['../data/' suj '/field/' suj '.CnD.AgeContrast80Slct.RLNRNL.mat']);
        
        freq            = rmfield(freq,'check_trialinfo');
        
        %         trial_array         = sort([trial_array{:}]);
        
        %         cfg                 = [];
        %         cfg.trials          = trial_array;
        %         freq                = ft_selectdata(cfg,freq);
        
        [~,~,~,~,strl_rt]   = h_new_behav_eval(suj,0:2,0,1:4);
        
        %         strl_rt             = strl_rt(trial_array);
        
        lmt1                = find(round(freq.time,3) == round(-0.6,3));
        lmt2                = find(round(freq.time,3) == round(-0.2,3));
        
        bsl                 = mean(freq.powspctrm(:,:,:,lmt1:lmt2),4);
        bsl                 = repmat(bsl,[1 1 1 size(freq.powspctrm,4)]);
        
        freq.powspctrm  = freq.powspctrm ./ bsl ; clear bsl ;
        
        for ix_cue          = 1
            
            new_strl_rt     = strl_rt;
            
            allsuj_data{ngroup}{sb,ix_cue,1}.powspctrm = [];
            allsuj_data{ngroup}{sb,ix_cue,1}.dimord    = 'chan_freq_time';
            
            allsuj_data{ngroup}{sb,ix_cue,1}.freq      = round(freq.freq) ; %freq_list;
            allsuj_data{ngroup}{sb,ix_cue,1}.time      = freq.time ; %time_list;
            allsuj_data{ngroup}{sb,ix_cue,1}.label     = freq.label;
            
            fprintf('Calculating Correlation for %s\n',suj)
            
            for nfreq = 1:length(freq.freq)
                for ntime = 1:length(freq.time)
                    
                    %                     lmt1    = find(round(freq.time,3) == round(time_list(ntime),3));
                    %                     lmt2    = find(round(freq.time,3) == round(time_list(ntime) + time_window,3));
                    
                    %                     lmf1    = find(round(freq.freq) == round(freq_list(nfreq)));
                    %                     lmf2    = find(round(freq.freq) == round(freq_list(nfreq)+freq_window));
                    
                    data    = squeeze(freq.powspctrm(:,:,nfreq,ntime));
                    %                     data    = mean(data,3);
                    
                    [rho,p] = corr(data,new_strl_rt , 'type', 'Spearman');
                    
                    rhoF    = .5.*log((1+rho)./(1-rho));
                    
                    allsuj_data{ngroup}{sb,ix_cue,1}.powspctrm(:,nfreq,ntime) = rhoF ; clear rho p data ;
                    
                end
            end
            
            allsuj_data{ngroup}{sb,ix_cue,2}               = allsuj_data{ngroup}{sb,ix_cue,1};
            allsuj_data{ngroup}{sb,ix_cue,2}.powspctrm(:)  = 0;
            
        end
        
        clear freq
        
    end
end

clearvars -except allsuj_data ;

test        = [];

% for ngroup = 1:length(allsuj_data)
%     for ncue = 1:size(allsuj_data{ngroup},2)
%         for nsuj = 1:size(allsuj_data{ngroup},1)
%             for ntype = 1:2
%
%                 allsuj_data{ngroup}{nsuj,ncue,ntype}.freq = round(allsuj_data{ngroup}{nsuj,ncue,ntype}.freq);
%
%             end
%         end
%     end
% end

clearvars -except allsuj_data ;

for ngroup = 1:length(allsuj_data)
    
    nsuj                        = size(allsuj_data{ngroup},1);
    [design,neighbours]         = h_create_design_neighbours(nsuj,allsuj_data{1}{1},'meg','t'); clc;
    
    cfg                         = [];
    cfg.clusterstatistic        = 'maxsum';  cfg.method              = 'montecarlo'; cfg.statistic           = 'depsamplesT'; cfg.correctm            = 'cluster';
    cfg.neighbours              = neighbours;
    cfg.clusteralpha            = 0.05;
    cfg.alpha                   = 0.025;
    cfg.minnbchan               = 4;
    
    cfg.latency                 = [0.6 1];
    cfg.frequency               = [7 20];
    
    cfg.tail                    = 0;
    cfg.clustertail             = 0; cfg.numrandomization    = 1000;
    cfg.design                  = design;
    cfg.uvar                    = 1; cfg.ivar                = 2;
    cfg.latency                 = [0.6 1];
    cfg.avgovertime             = 'yes';
    
    for ncue = 1:size(allsuj_data{ngroup},2)
        stat{ngroup,ncue}            = ft_freqstatistics(cfg, allsuj_data{ngroup}{:,ncue,1},allsuj_data{ngroup}{:,ncue,2});
    end
    
end

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        [min_p(ngroup,ncue), p_val{ngroup,ncue}]  = h_pValSort(stat{ngroup,ncue}) ;
    end
end

clearvars -except allsuj_data stat min_p p_val;

i = 0 ;

list_cue = {''};

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        
        plimit                  = 0.12;
        stat2plot               = h_plotStat(stat{ngroup,ncue},0.000000000000000000000000000001,plimit);
        
        i = i + 1;
        
        subplot(1,4,i)
        
        list_group              = {'old','young','common','allyoung'};
        
        cfg         = [];
        cfg.layout  = 'CTF275.lay';
        cfg.zlim    = [-0.5 0.5];
        cfg.marker  = 'off';
        cfg.comment = 'no';
        ft_topoplotTFR(cfg,stat2plot); title(list_group{ngroup});
        
    end
end


% for ngroup = 1%:size(stat,2)
%
%     plimit                  = 0.05;
%     stat2plot               = h_plotStat(stat{ngroup},0.000000000000000000000000000001,plimit);
%
%     subplot(3,2,1:2)
%
%     cfg         = [];
%     cfg.layout  = 'CTF275.lay';
%     cfg.zlim    = [-1 1];
%     cfg.marker  = 'off';
%     cfg.comment = 'no';
%     ft_topoplotTFR(cfg,stat2plot);
%
% end
%
% list_chan{1} = {'MLC11', 'MLF22', 'MLF23', 'MLF31', 'MLF32', 'MLF33', 'MLF41', ...
%     'MLF42', 'MLF43', 'MLF44', 'MLF51', 'MLF52', 'MLF53', 'MLF61', 'MLF62', ...
%     'MRC11', 'MRF21', 'MRF22', 'MRF23', 'MRF31', 'MRF32', 'MRF33', 'MRF41', ...
%     'MRF42', 'MRF43', 'MRF44', 'MRF51', 'MRF52', 'MRF53', 'MRF61', 'MZF02', 'MZF03'};
%
% subplot(3,2,[3 5])
% cfg                 = [];
% cfg.channel         = list_chan{1};
% cfg.zlim            = [-1 1];
% ft_singleplotTFR(cfg,stat2plot);
% title('');
%
% for nchan = 1:length(list_chan)
%
%     for ngroup = 1
%
%         plimit                  = 0.11;
%         stat2plot               = h_plotStat(stat{ngroup,ncue},0.000000000000000000000000000001,plimit);
%
%         cfg                     = [];
%         cfg.channel             = list_chan{nchan};
%         cfg.avgoverchan         = 'yes';
%         nw_data                 = ft_selectdata(cfg,stat2plot);
%
%         subplot(3,2,4)
%         hold on
%         plot(nw_data.freq,squeeze(mean(nw_data.powspctrm,3)));
%         xlim([nw_data.freq(1) nw_data.freq(end)])
%         ylim([-1 0])
%
%         subplot(3,2,6)
%         hold on
%         plot(nw_data.time,squeeze(mean(nw_data.powspctrm,2)));
%         xlim([nw_data.time(1) nw_data.time(end)])
%         ylim([-1 0])
%
%     end
% end
%
%
% cfg                     = [];
% cfg.clusterstatistic    = 'maxsum';
% cfg.method              = 'montecarlo';
% cfg.statistic           = 'indepsamplesT';
% cfg.correctm            = 'cluster';
% cfg.neighbours          = neighbours;
% cfg.clusteralpha        = 0.05;
% cfg.alpha               = 0.025;
% cfg.minnbchan           = 4;
% cfg.tail                = 0;
% cfg.clustertail         = 0;
% cfg.numrandomization    = 1000;
% nsubj                   = 14;
% cfg.design              = [ones(1,nsubj) ones(1,nsubj)*2];
% cfg.ivar                = 1;
% stat{3}                 = ft_freqstatistics(cfg, allsuj_data{1}{:,1},allsuj_data{2}{:,1});
%
% nsuj                    = 28;
% [design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_data{1}{1},'meg','t'); clc;
%
% cfg                     = [];
% cfg.clusterstatistic    = 'maxsum';  cfg.method              = 'montecarlo'; cfg.statistic           = 'depsamplesT'; cfg.correctm            = 'cluster';
% cfg.neighbours          = neighbours;
% cfg.clusteralpha        = 0.05;
% cfg.alpha               = 0.025;
% cfg.minnbchan           = 4;
% cfg.tail                = 0;
% cfg.clustertail         = 0; cfg.numrandomization    = 1000;
% cfg.design              = design;
% cfg.uvar                = 1; cfg.ivar                = 2;
%
% for cond = 1:2
%     i = 0 ;
%     for ngroup = 1:2
%         for sb = 1:14
%             i = i + 1;
%             new_data{i,cond} = allsuj_data{ngroup}{sb,cond};
%         end
%     end
% end
%
% stat{4}                 = ft_freqstatistics(cfg, new_data{:,1},new_data{:,2});