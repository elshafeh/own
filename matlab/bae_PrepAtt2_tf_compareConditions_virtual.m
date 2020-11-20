clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

% [~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% suj_group{1}        = suj_group{1}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        cond_main               = 'CnD';
        
        ext_name1               = '1t20Hz';
        ext_name2               = 'broadMotorAreas.1t40Hz.m800p2000msCov.waveletPOW.1t40Hz.m2000p2000.KeepTrialsMinEvoked10MStep80Slct';
        
        fname_in                = ['../data/' suj '/field/' suj '.' cond_main '.' ext_name2 '.mat'];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        if isfield(freq,'check_trialinfo')
            freq = rmfield(freq,'check_trialinfo');
        end
        
        freq               = h_transform_freq(freq,{[1 3],[2 4]},{'motor L','motor R'});
        
        list_ix_cue        = {[1 2],2,1,0};
        list_ix_tar        = {1:4,1:4,1:4,1:4};
        list_ix_dis        = {0,0,0,0,0};
        list_ix            = {'V','R','L','N'};
                
        for cnd = 1:length(list_ix_cue)
            
            cfg                         = [];            
            cfg.trials                  = h_chooseTrial(freq,list_ix_cue{cnd},list_ix_dis{cnd},list_ix_tar{cnd}); %trial_array{cnd};%
            new_freq                    = ft_selectdata(cfg,freq);
            new_freq                    = ft_freqdescriptives([],new_freq);
            
            cfg                         = [];
            cfg.baseline                = [-0.5 -0.2];
            cfg.baselinetype            = 'relchange';
            new_freq                    = ft_freqbaseline(cfg,new_freq);
            
            allsuj_data{ngroup}{sb,cnd} = new_freq;
            
        end
        
        clc;
        
        %         list_to_subtract                = [1 3; 2 4; 1 5; 2 5];
        %         index_cue                       = 5;
        %
        %         for nadd = 1:length(list_to_subtract)
        %
        %             allsuj_data{ngroup}{sb,index_cue+nadd} = allsuj_data{ngroup}{sb,list_to_subtract(nadd,1)};
        %
        %             pow                                    = allsuj_data{ngroup}{sb,list_to_subtract(nadd,1)}.powspctrm - allsuj_data{ngroup}{sb,list_to_subtract(nadd,2)}.powspctrm ;
        %
        %             list_ix{index_cue+nadd}                = [list_ix{list_to_subtract(nadd,1)} 'm' list_ix{list_to_subtract(nadd,2)}];
        %
        %         end
        
    end
end

clearvars -except allsuj_data list_ix

for ngroup = 1:length(allsuj_data)
    
    nsuj                    = size(allsuj_data{ngroup},1);
    [design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_data{ngroup}{1},'virt','t'); clc;
    
    cfg                     = [];
    
    cfg.latency             = [0.2 2];
    
    cfg.frequency           = [7 15];
    cfg.avgoverfreq         = 'yes';
    
    cfg.neighbours          = neighbours;
    cfg.minnbchan           = 0;
    
    cfg.clusterstatistic    = 'maxsum';
    cfg.method              = 'montecarlo';
    cfg.statistic           = 'depsamplesT';
    
    cfg.correctm            = 'cluster';
    
    cfg.clusteralpha        = 0.05;
    cfg.alpha               = 0.025;
    
    cfg.tail                = 0;
    cfg.clustertail         = 0;
    cfg.numrandomization    = 1000;
    cfg.design              = design;
    cfg.uvar                = 1;
    cfg.ivar                = 2;
    
    list_compare            = [1 4; 2 4; 3 4];
    
    for ntest = 1:size(list_compare,1)
        
        stat{ngroup,ntest}  = ft_freqstatistics(cfg,allsuj_data{ngroup}{:,list_compare(ntest,1)}, allsuj_data{ngroup}{:,list_compare(ntest,2)});
        list_test{ntest}    = [list_ix{list_compare(ntest,1)} 'v' list_ix{list_compare(ntest,2)}];
        
    end
end

clearvars -except allsuj_data stat list_ix list_test

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        [min_p(ngroup,ntest), p_val{ngroup,ntest}]      = h_pValSort(stat{ngroup,ntest}) ;
    end
end

clearvars -except allsuj_data stat min_p p_val list_ix list_test

i= 0 ;

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        for nchan = 1:length(stat{ngroup,ntest}.label)
            
            s2plot.mask                    = stat{ngroup,ntest}.mask(nchan,:,:);
            s2plot.stat                    = stat{ngroup,ntest}.stat(nchan,:,:);
            s2plot.prob                    = stat{ngroup,ntest}.prob(nchan,:,:);
            s2plot.freq                    = stat{ngroup,ntest}.freq;
            s2plot.time                    = stat{ngroup,ntest}.time;
            s2plot.dimord                  = stat{ngroup,ntest}.dimord;
            s2plot.label                   = stat{ngroup,ntest}.label(nchan);
            
            plimit                         = 0.3;
            
            i = i + 1;
            
            subplot(size(stat,1),size(stat,2)*2,i)
            
            s2plot.mask                     = s2plot.prob < plimit;
            
            %             plot(s2plot.time,squeeze(s2plot.mask .* s2plot.stat));
            %             xlim([s2plot.time(1) s2plot.time(end)])
            %             ylim([-3 3])
            %             cfg                             = [];
            %             cfg.parameter                   = 'stat';
            %             cfg.maskparameter               = 'mask';
            %             cfg.maskstyle                   = 'outline';
            %             cfg.colorbar                    = 'no';
            %             cfg.zlim                        = [-3 3];
            %             ft_singleplotTFR(cfg,s2plot);
            %             colormap(redblue)
            
            lstgroup = {'Old','Young'};
            
            title([lstgroup{ngroup} ' ' s2plot.label{:} ' ' list_test{ntest} ' ' num2str(min(min(s2plot.prob)))]);
            
            
        end
    end
end