clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

% [~,suj_list,~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% suj_list        = suj_list(2:22);
% [~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
% suj_group{1}    = allsuj(2:15,1);
% suj_group{2}    = allsuj(2:15,2);

% [~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% suj_group{1}        = suj_group{1}(2:22);

suj_group{1}                   = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'};

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        
        cond_main               = 'CnD';
        list_cue                = {'','N','L','R'};
        
        for ncue = 1:length(list_cue)
            
            ext_name                = 'prep21.maxTDBU.1t20Hz.m800p2000msCov.waveletPOW.1t19Hz.m3000p3000.AvgTrialsMinEvoked';
            
            dir_data                = '../../PAT_MEG21/pat.field/data/';
            
            fname_in                = [dir_data suj '.' list_cue{ncue} cond_main '.' ext_name '.mat'];
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            for nchan = 1:length(freq.label)
                where_under = strfind(freq.label{nchan},'_');
                freq.label{nchan}(where_under) = ' ';
            end
            
            
            [tmp{1},tmp{2}]                         = h_prepareBaseline(freq,[-0.6 -0.2],[5 15],[-0.2 1.2],'no');
            
            allsuj_activation{ngroup}{sb,ncue}      = tmp{1};
            allsuj_baselineRep{ngroup}{sb,ncue}     = tmp{2};
            
        end
        
    end
end

clearvars -except allsuj_* list_cue;

for ngroup = 1:length(allsuj_activation)
    
    nsuj                    = size(allsuj_activation{ngroup},1);
    [design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_activation{1}{1},'virt','t'); clc;
    
    for ncue = 1:size(allsuj_activation{ngroup},2)
        
        cfg                     = [];
        cfg.clusterstatistic    = 'maxsum';
        cfg.method              = 'montecarlo';
        cfg.statistic           = 'depsamplesT';
        
        cfg.correctm            = 'cluster';
        cfg.neighbours          = neighbours;
        
        %         cfg.latency             = [1.2 2];
        %         cfg.frequency           = [60 100];
        %         cfg.avgoverfreq         = 'yes';
        
        cfg.clusteralpha        = 0.05;
        cfg.alpha               = 0.025;
        cfg.minnbchan           = 0;
        cfg.tail                = 0;
        cfg.clustertail         = 0;
        cfg.numrandomization    = 1000;
        cfg.design              = design;
        cfg.uvar                = 1;
        cfg.ivar                = 2;
        
        stat{ngroup,ncue}      = ft_freqstatistics(cfg, allsuj_activation{ngroup}{:,ncue},allsuj_baselineRep{ngroup}{:,ncue});
        stat{ngroup,ncue}      = rmfield(stat{ngroup,ncue},'cfg');
    end
end

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        [min_p(ngroup,ncue),p_val{ngroup,ncue}]      = h_pValSort(stat{ngroup,ncue});
    end
end

figure;
i = 0;

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        for nchan = 1:length(stat{ngroup,ncue}.label)
            
            stat_to_plot       = stat{ngroup,ncue};
            stat_to_plot.mask  = stat_to_plot.prob < 0.11;
            
            i = i + 1;
            
            subplot(5,6,i)
            
            cfg                 = [];
            cfg.ylim            = [5 15];
            cfg.channel         = nchan;
            cfg.parameter       = 'stat';
            cfg.maskparameter   = 'mask';
            cfg.maskstyle       = 'outline';
            cfg.zlim            = [-5 5];
            
            ft_singleplotTFR(cfg,stat_to_plot);
            
            title([list_cue{ncue} 'CnD ' stat_to_plot.label{nchan}])
            
            colormap('jet')
            
        end
    end
end