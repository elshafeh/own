clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = {'1DIS','1fDIS'};
        cond_sub            = {'V','N','L','R'};
        
        for ncue = 1:length(cond_sub)
            
            for dis_type = 1:2
                
                fname_in                            = ['../data/' suj '/field/' suj '.' cond_sub{ncue} cond_main{dis_type} '.bpOrder2Filt0.5t20Hz.pe.mat'];
                
                fprintf('Loading %s\n',fname_in);
                
                load(fname_in);
                
                
                %                 cfg                                 = [];
                %                 cfg.baseline                        = [-0.1 0];
                %                 data_pe                             = ft_timelockbaseline(cfg,data_pe);
                
                tmp{dis_type}                       = data_pe;
                
                clear data_pe data_gfp
                
               
            end
            
            cfg                                 = [];
            cfg.parameter                       = 'avg';
            cfg.operation                       = 'x1-x2';
            allsuj_data{ngrp}{sb,ncue}          = ft_math(cfg,tmp{1},tmp{2}); clear tmp ;
            
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
cfg.latency             = [0.350 0.650]; 

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

ix_test                 = [1 2; 4 2; 3 2; 3 4]; % V vs N, R vs N, L vs N, L vs R 

list_test_done          = {};

for ngroup = 1
    for ntest = 1:size(ix_test,1)
        stat{ngroup,ntest}        = ft_timelockstatistics(cfg, allsuj_data{ngroup}{:,ix_test(ntest,1)}, allsuj_data{ngroup}{:,ix_test(ntest,2)});
        
        list_test_done{ntest}     = [cond_sub{ix_test(ntest,1)} '.versus.' cond_sub{ix_test(ntest,2)}];
        
    end
end

clearvars -except *_data cond_sub stat list_test_done ix_test;

% tu vas voir tes resultats

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
        
        cfg.channel = {'MLC11', 'MLC12', 'MLC13', 'MLC14', 'MLC15', 'MLC16', 'MLC17', 'MLC21', 'MLC22', 'MLC23', 'MLC24', 'MLC25', 'MLC31', 'MLC32', 'MLC41', 'MLC42', 'MLC51', 'MLC52', 'MLC53', 'MLC54', 'MLC55', 'MLC61', 'MLC62', 'MLC63', 'MLF35', 'MLF45', 'MLF46', 'MLF54', 'MLF55', 'MLF56', 'MLF62', 'MLF63', 'MLF64', 'MLF65', 'MLF66', 'MLF67', 'MLO11', 'MLO12', 'MLO13', 'MLO14', 'MLO21', 'MLO22', 'MLO23', 'MLO24', 'MLO31', 'MLO32', 'MLO33', 'MLO34', 'MLO43', 'MLO44', 'MLP11', 'MLP12', 'MLP21', 'MLP22', 'MLP23', 'MLP31', 'MLP32', 'MLP33', 'MLP34', 'MLP35', 'MLP41', 'MLP42', 'MLP43', 'MLP44', 'MLP45', 'MLP51', 'MLP52', 'MLP53', 'MLP54', 'MLP55', 'MLP56', 'MLP57', 'MLT12', 'MLT13', 'MLT14', 'MLT15', 'MLT16', 'MLT25', 'MLT26', 'MLT27', 'MLT37', 'MLT46', 'MLT47', 'MLT56', 'MRC11', 'MRC24', 'MRC25', 'MRC31', 'MRC32', 'MRC42', 'MRC51', 'MRC53', 'MRC54', 'MRC55', 'MRC61', 'MRC62', 'MRC63', 'MRO21', 'MRP11', 'MRP12', 'MRP21', 'MRP22', 'MRP23', 'MRP31', 'MRP32', 'MRP33', 'MRP34', 'MRP35', 'MRP41', 'MRP42', 'MRP43', 'MRP44', 'MRP51', 'MRP54', 'MRP55', 'MZC01', 'MZC02', 'MZC03', 'MZC04', 'MZO01', 'MZO02', 'MZP01'};
        
        cfg.xlim    = [0.350 0.65];
        
        cfg.ylim    = [-10 70];
        
        %             cfg.channel = chan_group{chn};
        
        ft_singleplotER(cfg,gavg_data{ngroup,ix_test(ntest,1)},gavg_data{ngroup,ix_test(ntest,2)});
        
        title('Grand Average')
        legend({cond_sub{ix_test(ntest,1)},cond_sub{ix_test(ntest,2)}})
        
    end
end

% clearvars -except stat gavg_data list_test_done ix_test
% save '../data_fieltrip/stat_cam/cluster_based_permutations_young_cue_meg_channels.mat'
% save 'cluster_based_permutations_young_dis1_meg_channels.mat'