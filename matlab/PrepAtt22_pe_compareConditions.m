clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj                                     = suj_list{sb};
        cond_main                               = 'nDT';
        cond_sub                                = {'Hi','Lo'};
        
        for ncue = 1:length(cond_sub)
            
            fname_in                            = ['../data/pitch_data/' suj '.' cond_sub{ncue} cond_main '.bpOrder2Filt0.5t20Hz.pe.mat'];
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in);
            
            cfg                                 = [];
            cfg.baseline                        = [-0.1 0];
            data_pe                             = ft_timelockbaseline(cfg,data_pe);
            
            allsuj_data{ngrp}{sb,ncue}          = data_pe;
            
            clear data_pe
            
        end
    end
end

clearvars -except *_data ;

for ngroup = 1:length(allsuj_data)
    
    nsuj                    = size(allsuj_data{ngroup},1);
    [design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_data{1}{1},'virt','t');
    
    cfg                     = [];
    cfg.latency             = [-0.1 0.6];
    cfg.statistic           = 'ft_statfun_depsamplesT';
    cfg.method              = 'montecarlo';
    cfg.correctm            = 'cluster';
    cfg.clusteralpha        = 0.05;
    cfg.clusterstatistic    = 'maxsum';
    
    cfg.minnbchan           = 0;
    
    cfg.tail                = 0;
    cfg.clustertail         = 0;
    cfg.alpha               = 0.025;
    cfg.numrandomization    = 1000;
    cfg.neighbours          = neighbours;
    cfg.design              = design;
    cfg.uvar                = 1;
    cfg.ivar                = 2;
    
    ix_test                 = [1 2];
    
    for ntest = 1:size(ix_test,1)
        stat{ngroup,ntest}  = ft_timelockstatistics(cfg, allsuj_data{ngroup}{:,ix_test(ntest,1)}, allsuj_data{ngroup}{:,ix_test(ntest,2)});
    end
    
end

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        [min_p(ngroup,ntest),p_val{ngroup,ntest}]           = h_pValSort(stat{ngroup,ntest}) ;
    end
end

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        
        stat{ngroup,ntest}.mask     = stat{ngroup,ntest}.prob < 0.05;
        
        stat2plot                   = [];
        stat2plot.avg               = stat{ngroup,ntest}.mask .* stat{ngroup,ntest}.stat;
        stat2plot.label             = stat{ngroup,ntest}.label;
        stat2plot.dimord            = stat{ngroup,ntest}.dimord;
        stat2plot.time              = stat{ngroup,ntest}.time;

        subplot(1,2,1)
        
        cfg                         = [];
        cfg.layout                  = 'CTF275.lay';
        cfg.zlim                    = [-3 3];
        cfg.marker                  = 'off';
        cfg.comment                 = 'no';
        ft_topoplotER(cfg,stat2plot);
        
        gavg_data1                  = ft_timelockgrandaverage([],allsuj_data{1}{:,1});
        gavg_data2                  = ft_timelockgrandaverage([],allsuj_data{1}{:,2});

        subplot(1,2,2)
        hold on;
        
        cfg                         = [];
        cfg.p_threshold             = 0.05;
        cfg.z_limit                 = [-50 50];
        cfg.time_limit              = [-0.1 0.6]
        cfg.lineWidth               = 2;
        cfg.channel                 = {'MRF23', 'MRF24', 'MRF25', 'MRF33', 'MRF34', 'MRF35', 'MRF44', 'MRF45', 'MRF54'};
        h_plotSingleERFstat_selectChannel(cfg,stat{ngroup,ntest},gavg_data1,gavg_data2)
        
        legend({'Hi','Lo'});
        
    end
end


        
% for nchan = 1:length(stat2plot.label)
%     chk_pow                 = unique(squeeze(stat2plot.avg(nchan,:)));
%     if length(chk_pow) > 1
%         figure;
%         plot(stat2plot.time,stat2plot.avg(nchan,:));
%         title(stat2plot.label{nchan});
%         xlim([stat2plot.time(1) stat2plot.time(end)]);
%         ylim([-5 5]);
%     end
%     
% end