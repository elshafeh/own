clear ;

addpath(genpath('kakearney-boundedline'));

global ft_default
ft_default.spmversion = 'spm12';

list_mod        = {'vis','aud'};
load ../data/sub006_aud_sfn_dwnsample.BigB1.mat

time_axs        = data.time{1}; clear data;
i               = 0;

all_data        = [];

for nm = 1:2
    
    load(['../data/' list_mod{nm} 'allscores.mat']);
    
    for nf = 1:2
        
        i       = i + 1;
        
        for nb = 1:size(all_scores,2)
            
            if nf == 1
                mtrx_data                   = squeeze(all_scores(:,nb,1,:));
            else
                mtrx_data                   = squeeze(mean(squeeze(all_scores(:,nb,2:3,:)),2));
            end
            
            
            
            for ns = 1:size(mtrx_data,1)
                
                all_data{nm}{nf,nb,ns}              = [];
                all_data{nm}{nf,nb,ns}.time         = time_axs;
                all_data{nm}{nf,nb,ns}.dimord       = 'chan_time';
                all_data{nm}{nf,nb,ns}.label        = {'auc'};
                
                avg                                 = mtrx_data(ns,:);
                avg(avg < 0.5)                      = 0.5;
                
                all_data{nm}{nf,nb,ns}.avg          = avg;
                
            end
            
        end
    end
end

clearvars -except all_data;

for nm = 1:2
    for nf = 1:2
        
        cfg                     = [];
        
        cfg.latency             = [-0.2 1];
        
        cfg.statistic           = 'ft_statfun_depsamplesT';
        cfg.method              = 'montecarlo';
        cfg.correctm            = 'fdr'; %'bonferroni'; % 'cluster';
        cfg.clusteralpha        = 0.05;
        cfg.clusterstatistic    = 'maxsum';
        cfg.minnbchan           = 0;
        cfg.tail                = 0;
        cfg.clustertail         = 0;
        cfg.alpha               = 0.025;
        cfg.numrandomization    = 1000;
        cfg.uvar                = 1;
        cfg.ivar                = 2;
        
        nbsuj                   = size(all_data{nm},3);
        [design,~]              = h_create_design_neighbours(nbsuj,all_data{nm}{nf,1,1},'gfp','t');
        
        cfg.design              = design;
        stat{nm,nf}             = ft_timelockstatistics(cfg, all_data{nm}{nf,1,:}, all_data{nm}{nf,2,:});
        
        [min_p(nm,nf),p_val{nm,nf}]           = h_pValSort(stat{nm,nf}) ;
        
        
    end
end

clearvars -except stat all_data min_p p_val;

i                               = 0;

for nm = 1:2
    for nf = 1:2
        
        i = i + 1;
        subplot(2,2,i)
        
        cfg                     = [];
        cfg.p_threshold         = 0.05/4;
        cfg.lineWidth           = 3;
        cfg.time_limit          = [stat{1,1}.time(1) stat{1,1}.time(end)];
        
        if nf == 1
            cfg.z_limit         = [0.5 1];
        else
            cfg.z_limit         = [0.5 0.7];
        end
        
        cfg.fontSize        = 18;
        
        h_plotSingleERFstat(cfg,stat{nm,nf}, ... 
            ft_timelockgrandaverage([],all_data{nm}{nf,1,:}), ...
            ft_timelockgrandaverage([],all_data{nm}{nf,2,:}))
        
        set(gca,'fontsize', 18)
        
    end
end