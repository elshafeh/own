clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = 'nDT';
        cond_sub            = {'V','N','L','R','NL','NR'};
        
        for ncue = 1:length(cond_sub)
            
            fname_in            = ['../data/' suj '/field/' suj '.' cond_sub{ncue} cond_main '.bpOrder2Filt0.5t20Hz.pe.mat'];
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in);
            
            data_pe                             = rmfield(data_pe,'dof');
            
            cfg                                 = [];
            cfg.baseline                        = [-0.1 0];
            data_pe                             = ft_timelockbaseline(cfg,data_pe); % correction ligne du base
            allsuj_data{ngrp}{sb,ncue}          = data_pe;
            
            clear data_pe
            
        end
        
    end
    
    for ncue = 1:size(allsuj_data{ngrp},2)
        gavg_data{ngrp,ncue} = ft_timelockgrandaverage([],allsuj_data{ngrp}{:,ncue});
    end
    
end

clearvars -except *_data cond_sub;

nbsuj                   = 21;

[design,neighbours]     =  h_create_design_neighbours(nbsuj,allsuj_data{1}{1},'meg','t');

cfg                     = [];
cfg.latency             = [0 0.5]; 

% cfg.avgovertime         = 'yes';

cfg.statistic           = 'ft_statfun_depsamplesT';
cfg.method              = 'montecarlo';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;
cfg.clusterstatistic    = 'maxsum';

cfg.minnbchan           = 2;

cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.alpha               = 0.025;

cfg.numrandomization    = 1000;

cfg.neighbours          = neighbours;
cfg.design              = design;
cfg.uvar                = 1;
cfg.ivar                = 2;

ix_test                 = [1 2; 4 6; 3 5; 4 3]; % V vs N, R vs NR, L vs NL, R vs L 

list_test_done          = {};

for ngroup = 1
    for ntest = 1:size(ix_test,1)
        stat{ngroup,ntest}        = ft_timelockstatistics(cfg, allsuj_data{ngroup}{:,ix_test(ntest,1)}, allsuj_data{ngroup}{:,ix_test(ntest,2)});
        
        list_test_done{ntest}     = [cond_sub{ix_test(ntest,1)} '.versus.' cond_sub{ix_test(ntest,2)}];
        
    end
end

clearvars -except *_data cond_sub stat list_test_done ix_test;

% tu vaas voir tes resultats

for ngroup = 1
    for ntest = 1:size(stat,2)
        [min_p(ngroup,ntest),p_val{ngroup,ntest}]           = h_pValSort(stat{ngroup,ntest}) ;
        
        who_seg{ntest,1}     =  list_test_done{ntest};
        who_seg{ntest,2}     =  min_p(ngroup,ntest);
        who_seg{ntest,3}     =  p_val{ngroup,ntest};

    end
end

clearvars -except *_data cond_sub stat min_p p_val list_test_done ix_test;

i = 0 ;

for ngroup = 1:1
    for ntest = 1:size(stat,2)
        
        i = i + 1;
        
        subplot(3,2,i)
        
        p_limit                             = 0.05; % to change
        
        stat{ngroup,ntest}.mask             = stat{ngroup,ntest}.prob < p_limit;
        
        stat2plot{ngroup,ntest}             = [];
        
        stat2plot{ngroup,ntest}.avg         = stat{ngroup,ntest}.mask .* stat{ngroup,ntest}.stat;
        
        stat2plot{ngroup,ntest}.label       = stat{ngroup,ntest}.label;
        
        stat2plot{ngroup,ntest}.dimord      = stat{ngroup,ntest}.dimord;
        
        stat2plot{ngroup,ntest}.time        = stat{ngroup,ntest}.time;
        
        
        cfg         = [];
        cfg.layout = 'CTF275.lay';
        cfg.zlim = [-3 3];
        ft_topoplotER(cfg,stat2plot{ngroup,ntest});
        title(list_test_done{ntest});
        
    end
end


i = 0 ;
figure;

for ngroup = 1:1
    for ntest = 1:size(stat,2)
        
        i = i + 1;
        
        subplot(3,2,i)
        hold on ;
        
        cfg         = [];
        
        cfg.channel = {'MRC12', 'MRC13', 'MRC14', 'MRC15', 'MRC16', 'MRC17', 'MRC21', 'MRC22', 'MRC23', 'MRC24', 'MRC25', 'MRC31', 'MRC32', 'MRC41', 'MRC42', 'MRC52', 'MRC53', 'MRC54', 'MRC55', 'MRC62', 'MRF35', 'MRF45', 'MRF46', 'MRF53', 'MRF54', 'MRF55', 'MRF56', 'MRF61', 'MRF62', 'MRF63', 'MRF64', 'MRF65', 'MRF66', 'MRF67', 'MRP11', 'MRP12', 'MRP23', 'MRP34', 'MRP35', 'MRP45', 'MRP57', 'MRT13', 'MRT14'};
        
        cfg.xlim    = [0 0.5];
        
        cfg.ylim    = [-80 20];
        
        %             cfg.channel = chan_group{chn};
        
        ft_singleplotER(cfg,gavg_data{ngroup,ix_test(ntest,1)},gavg_data{ngroup,ix_test(ntest,2)});
        
        title('Grand Average')
        legend({cond_sub{ix_test(ntest,1)},cond_sub{ix_test(ntest,2)}})
        
    end
end

% clearvars -except stat gavg_data list_test_done ix_test
% save '../data_fieltrip/stat_cam/cluster_based_permutations_young_cue_meg_channels.mat'
% save 'cluster_based_permutations_young_target_meg_channels.mat'