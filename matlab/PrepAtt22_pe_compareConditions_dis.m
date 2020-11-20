clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = {'DIS','fDIS'};
        cond_sub            = {'V','N'};
        
        for ncue = 1:length(cond_sub)
            
            for dis_type = 1:2
                
                fname_in                            = ['../data/new_pe_lcmv_data/' suj '.' cond_sub{ncue} cond_main{dis_type} '.MNIplusAudBroadman.lp20Hz.m200p700msCov.bpOrder2Filt0.5Hz.pe.mat'];
                                
                fprintf('Loading %s\n',fname_in);
                
                load(fname_in);
                
                tmp{dis_type}                       = data_pe;
                
                clear data_pe data_gfp
                
            end
            
            allsuj_data{ngrp}{sb,ncue}          = tmp{1};
            allsuj_data{ngrp}{sb,ncue}.avg      = tmp{1}.avg - tmp{2}.avg; clear tmp;
            
            cfg                                 = [];
            cfg.baseline                        = [-0.1 0];
            allsuj_data{ngrp}{sb,ncue}          = ft_timelockbaseline(cfg,allsuj_data{ngrp}{sb,ncue});
            
            
        end
    end
    
end

clearvars -except *_data cond_sub

clearvars -except *_data ;

for ngroup = 1:length(allsuj_data)
    
    nsuj                    = size(allsuj_data{ngroup},1);
    [design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_data{1}{1},'virt','t');
    
    cfg                     = [];
    cfg.latency             = [-0.1 0.5];
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
        stat{ngroup,ntest}        = ft_timelockstatistics(cfg, allsuj_data{ngroup}{:,ix_test(ntest,1)}, allsuj_data{ngroup}{:,ix_test(ntest,2)});
    end
    
end

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        [min_p(ngroup,ntest),p_val{ngroup,ntest}]           = h_pValSort(stat{ngroup,ntest}) ;
    end
end

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        
        stat{ngroup,ntest}.mask     = stat{ngroup,ntest}.prob < 0.2;
        
        stat2plot                   = [];
        stat2plot.avg               = stat{ngroup,ntest}.mask .* stat{ngroup,ntest}.stat;
        stat2plot.label             = stat{ngroup,ntest}.label;
        stat2plot.dimord            = stat{ngroup,ntest}.dimord;
        stat2plot.time              = stat{ngroup,ntest}.time;
        
        for nchan = 1:length(stat2plot.label)
            
            chk_pow                 = unique(squeeze(stat2plot.avg(nchan,:)));
            
            if length(chk_pow) > 1
                
                figure;
                plot(stat2plot.time,stat2plot.avg(nchan,:));
                title(stat2plot.label{nchan});
                xlim([stat2plot.time(1) stat2plot.time(end)]);
                ylim([-5 5]);
                
            end
            
        end
    end
end

% nbsuj                   = 21;
% [design,neighbours]     =  h_create_design_neighbours(nbsuj,allsuj_data{1}{1},'meg','t');
%
% cfg                     = [];
% cfg.latency             = [-0.1 0.6];
% % cfg.avgovertime         = 'yes';
% cfg.statistic           = 'ft_statfun_depsamplesT';
% cfg.method              = 'montecarlo';
% cfg.correctm            = 'cluster';
% cfg.clusteralpha        = 0.05;
% cfg.clusterstatistic    = 'maxsum';
% cfg.minnbchan           = 4;
% cfg.tail                = 0;
% cfg.clustertail         = 0;
% cfg.alpha               = 0.025;
% cfg.numrandomization    = 1000;
% cfg.neighbours          = neighbours;
% cfg.design              = design;
% cfg.uvar                = 1;
% cfg.ivar                = 2;
%
% ix_test                 = [1 2];
%
% for ngroup = 1
%     for ntest = 1:size(ix_test,1)
%         stat{ngroup,ntest}        = ft_timelockstatistics(cfg, allsuj_data{ngroup}{:,ix_test(ntest,1)}, allsuj_data{ngroup}{:,ix_test(ntest,2)});
%     end
% end
%
% for ngroup = 1
%     for ntest = 1:size(stat,2)
%         [min_p(ngroup,ntest),p_val{ngroup,ntest}]           = h_pValSort(stat{ngroup,ntest}) ;
%     end
% end
%
% for ngroup = 1
%     for ntest = 1:size(stat,2)
%
%         stat{ngroup,ntest}.mask             = stat{ngroup,ntest}.prob < 0.2;
%         stat2plot{ngroup,ntest}             = [];
%         stat2plot{ngroup,ntest}.avg         = stat{ngroup,ntest}.mask .* stat{ngroup,ntest}.stat;
%         stat2plot{ngroup,ntest}.label       = stat{ngroup,ntest}.label;
%         stat2plot{ngroup,ntest}.dimord      = stat{ngroup,ntest}.dimord;
%         stat2plot{ngroup,ntest}.time        = stat{ngroup,ntest}.time;
%
%     end
% end
%
% i = 0 ;
%
% for ngroup = 1
%
%     for ncue = 1:2
%
%         figure;
%
%         cfg         = [];
%         cfg.xlim    = [0.2 0.3]; %0:0.1:0.3;
%         cfg.layout  = 'CTF275.lay';
%         cfg.zlim    = [-60 60];
%         ft_topoplotER(cfg,gavg_data{ncue});
%
%     end
%
%     %         for ntest = 1:size(stat,2)
%     %
%     %     figure;
%     %
%     %     twin                    = 0.2;
%     %     tlist                   = stat{ngroup,ntest}.time(1):twin:stat{ngroup,ntest}.time(end);
%     %
%     %     for t = 1:length(tlist)-1
%     %
%     %         i = i + 1;
%     %
%     %         subplot(2,2,i)
%     %
%     %         cfg         = [];
%     %         cfg.xlim    = [tlist(t) tlist(t)+twin];
%     %         cfg.layout = 'CTF275.lay';
%     %         cfg.zlim = [-3 3];
%     %         ft_topoplotER(cfg,stat2plot{ngroup,ntest});
%     %
%     %     end
%     %         end
%
% end