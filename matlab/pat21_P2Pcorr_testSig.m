clear ; clc ;  dleiftrip_addpath ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    cnd_list = '';
    
    fname = ['../data/tfr/' suj '.CnD.SomaGammaNoAVGCoVm800p2000msfreq1t120Hz.all.wav.pow.4t120Hz.m3000p3000.mat'];
    
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    twin                                    = 0.1;
    tlist                                   = -3:twin:3;
    pow                                     = [];
    
    for t = 1:length(tlist)
        x1  = find(round(freq.time,3) == round(tlist(t),3)); x2 = find(round(freq.time,3) == round(tlist(t)+twin,3));
        tmp = squeeze(mean(freq.powspctrm(:,:,x1:x2),3));
        pow = cat(3,pow,tmp);
        clear tmp ;
    end
    
    freq.time  = tlist; freq.powspctrm=pow; clear pow;
    %
    %     nw_chn  = [61 62 149 150;63 64 151 152];
    %     nw_lst  = {'aud Left','aud Right'};
    %
    %     for l = 1:size(nw_chn,1)
    %         cfg             = [];
    %         cfg.channel     = nw_chn(l,:);
    %         cfg.avgoverchan = 'yes';
    %         nwfrq{l}        = ft_selectdata(cfg,freq);
    %         nwfrq{l}.label  = nw_lst(l);
    %     end
    %
    %     cfg                 = [];
    %     cfg.parameter       = 'powspctrm';cfg.appenddim   = 'chan';
    %     freq                = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
   
    cfg                 = [];
    cfg.baseline        = [-0.6 -0.2];
    cfg.baselinetype    = 'relchange';
    allsuj_GA{sb,1}     = ft_freqbaseline(cfg,freq); clear freq ;
    
    
    cfg                 = [];
    cfg.latency         = [0 1.2];
    cfg.frequency       = [5 15];
    allsuj_GA{sb,1}     = ft_selectdata(cfg,allsuj_GA{sb,1});
    
    load ../data/yctot/corr/alphapow4p2pcorrelation.mat;    
    
    for x = 1:size(corr_mtrx,2)
        for y = 1:size(corr_mtrx,3)
            allsuj_behav{x,y}  = corr_mtrx(:,x,y);
        end
    end
    
    clearvars -except allsuj_* gavg_suj sb
    
end

clearvars -except allsuj_* gavg_suj

[design,neighbours]     = h_create_design_neighbours(14,allsuj_GA{1,1},'virt','t');

cfg                     = [];
cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_correlationT'; 
cfg.clusterstatistics   = 'maxsum';cfg.correctm            = 'fdr';
cfg.clusteralpha        = 0.05;cfg.minnbchan           = 0;cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.alpha               = 0.025;cfg.numrandomization    = 1000;
cfg.neighbours          = neighbours;cfg.ivar                = 1;
corr_list               = {'Spearman'};

for x = 1:length(corr_list)
    for y = 1:size(allsuj_behav,1)
        for z = 1:size(allsuj_behav,2)
            cfg.type                            = corr_list{x};
            cfg.design(1,1:14)                  = [allsuj_behav{y,z}];
            stat{x,y,z}                         = ft_freqstatistics(cfg, allsuj_GA{:,1});
            [min_p(x,y,z),p_val{x,y,z}]         = h_pValSort(stat{x,y,z});
        end
    end
end

clearvars -except stat min_p

xlist = {'Spearman'};
ylist = {'early','late'};
zlist = {'audLeft','audRight'};
plim  = 0.05;

for y = 1:length(ylist)
    for z = 1:length(zlist)
        
        for x = 1:length(xlist)
            stat2plot  = h_plotStat(stat{x,y,z},0.000000000000000000000000001,plim);
            figure;
            
            for chn = 1:length(stat2plot.label)
                subplot(2,1,chn)
                cfg             =[];
                cfg.channel     = chn;
                cfg.zlim        = [-1 1];
                ft_singleplotTFR(cfg,stat2plot);clc;
                title([stat2plot.label{chn} ' with ' ylist{y} ' ' zlist{z} ' (' xlist{x} ')'])
            end
            
        end
    end
end

clearvars -except stat min_p