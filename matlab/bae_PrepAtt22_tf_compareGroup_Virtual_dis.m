clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        lst_dis = {'DIS','fDIS'};
        
        for cnd_dis = 1:2
            
            suj                 = suj_list{sb};
            fname_in            = ['../data/' suj '/field/' suj '.' lst_dis{cnd_dis} '.AgeCommonROI.40t120Hz.m200p600msCov.waveletPOW.40t119Hz.m1000p1000.KeepTrials.MinEvoked.mat'];
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            freq           = ft_freqdescriptives([],freq);
            freq           = h_transform_freq(freq,{[1 2],[3 4]},{'audL','audR'});
            
            tmp{cnd_dis}   = freq; clear freq
            
        end
        
        cfg                             = [];
        cfg.parameter                   = 'powspctrm';
        cfg.operation                   = 'x1-x2';
        freq                            = ft_math(cfg,tmp{1},tmp{2});
        
        clear tmp;
        
        list_ix_cue    = {''};
        
        for ncue = 1:length(list_ix_cue)
            for nchan = 1:length(freq.label)
                
                allsuj_data{ngroup}{sb,ncue,nchan}            = freq;
                allsuj_data{ngroup}{sb,ncue,nchan}.powspctrm  = freq.powspctrm(nchan,:,:);
                allsuj_data{ngroup}{sb,ncue,nchan}.label      = freq.label(nchan);
                
            end
        end
        
        clear freq ;
        
    end
end

clearvars -except allsuj_data

nsubj                   = 14;

cfg                     = [];
cfg.statistic           = 'indepsamplesT';
cfg.method              = 'montecarlo';    
cfg.correctm            = 'fdr';        
cfg.clusteralpha        = 0.05;
cfg.clusterstatistic    = 'maxsum';
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.alpha               = 0.025;
cfg.numrandomization    = 1000;
cfg.design              = [ones(nsubj) ones(nsubj)*2];
cfg.ivar                = 1;
cfg.latency             = [-0.1 0.5];
cfg.frequency           = [60 100];
cfg.avgoverfreq         = 'yes';

for ncue = 1:size(allsuj_data{1},2)
    for nchan = 1:size(allsuj_data{1},3)
        
        stat{ncue,nchan}      = ft_freqstatistics(cfg, allsuj_data{2}{:,ncue,nchan},allsuj_data{1}{:,ncue,nchan});
        
    end
end

for ncue = 1:size(stat,1)
    for nchan = 1:size(stat,2)
        [min_p(ncue,nchan),p_val{ncue,nchan}] = h_pValSort(stat{ncue,nchan});
    end
end

i = 0 ;

for ncue = 1:size(stat,1)
    for nchan = 1:size(stat,2)
        
        
        i = i + 1;
        
        subplot(2,1,i)
        
        cfg             = [];
        cfg.ylim        = [-3 3]; %y axes limits
        cfg.linewidth   = 2;
        cfg.p_threshold = 0.11; %to handle the mask
        h_plotStatAvgOverDimension(cfg,stat{ncue,nchan})
        
        %         cfg                 = [];
        %         cfg.parameter       = 'stat';
        %         cfg.maskparameter   = 'mask';
        %         cfg.maskstyle       = 'outline';
        %         cfg.zlim            = [-5 5];
        %         ft_singleplotTFR(cfg,stat{ncue,nchan});
        %         stat{ncue,nchan}.mask  = stat{ncue,nchan}.prob < 0.11;

        list_ix            = {'','L','NR','NL'};
        list_grp           = {'Old','Yung','AllYun'};
        
        title([list_ix{ncue} 'CnD.' stat{ncue,nchan}.label])
        
        colormap('jet')
        
    end
end
