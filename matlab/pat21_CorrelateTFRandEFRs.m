clear ; clc ; dleiftrip_addpath ;

load ../data/yctot/gavg/LRNnDT.pe.mat
load ../data/yctot/rt/rt_CnD_adapt.mat

for sb = 1:14
    
    suj_list            = [1:4 8:17];
    suj                 = ['yc' num2str(suj_list(sb))];
    
    avg                 = ft_timelockgrandaverage([],allsuj{sb,:});
    
    cfg                 = [];
    cfg.baseline        = [-0.2 -0.1];
    avg                 = ft_timelockbaseline(cfg,avg);

    list_latency        = [0.05 0.185; 0.185 0.28; 0.28 0.5];
    
    load ../data/yctot/gavg/nDT2RChanList.mat
    
    t = 3;
    lmt1 = find(round(avg.time,5) == round(list_latency(t,1),5));
    lmt2 = find(round(avg.time,5) == round(list_latency(t,2),5));
    
    for gp_chn = 1:3
        ix                      = h_indx_tf_labels(list_chan{t,gp_chn});
        erf2permute(sb,gp_chn)   = mean(mean(avg.avg(ix,lmt1:lmt2)));
    end
    
    fname = ['../data/tfr/' suj '.nDT.AudViz.VirtTimeCourse.all.wav.1t90Hz.m2000p2000.mat'];
    
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    nw_chn  = [4 6];  nw_lst  = {'audR'};
    
    for l = 1:size(nw_chn,1)
        cfg             = [];
        cfg.channel     = nw_chn(l,:);
        cfg.avgoverchan = 'yes';
        nwfrq{l}        = ft_selectdata(cfg,freq);
        nwfrq{l}.label  = nw_lst(l);
    end
    
    cfg             = [];
    cfg.parameter   = 'powspctrm';cfg.appenddim   = 'chan';
    freq            = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
    
    cfg                         = [];
    cfg.baseline                = [-1.4 -1.3];
    cfg.baselinetype            = 'relchange';
    freq                        = ft_freqbaseline(cfg,freq);
    
    t_win   = 0.01;
    tlist   = 0:t_win:0.39;
    ftap    = 2;
    flist   = 40:ftap:88;
    
    nwspctrm = [];
    
    for chn = 1:length(freq.label)
        for t = 1:length(tlist)
            for f = 1:length(flist)
                
                lmt1 = find(round(freq.time,2) == round(tlist(t),2));
                lmt2 = find(round(freq.time,2) == round(tlist(t)+t_win,2));
                
                lmf1 = find(round(freq.freq) == round(flist(f)));
                lmf2 = find(round(freq.freq) == round(flist(f)+ftap));
                
                data                = squeeze(mean(freq.powspctrm(chn,lmf1:lmf2,lmt1:lmt2),3));
                nwspctrm(chn,f,t)   = squeeze(mean(data,2));
                
            end
        end
    end
    
    freq.powspctrm = nwspctrm;
    freq.time      = tlist;
    freq.freq      = flist;
    
    allsuj_GA{sb,1} = freq ; clear freq ;
end

clearvars -except erf2permute *2permute allsuj_GA ;

[design,neighbours] = h_create_design_neighbours(length(allsuj_GA),'eeg','t');
clear neighbours ;

for n = 1:length(allsuj_GA{1,1}.label)
    neighbours(n).label = allsuj_GA{1,1}.label{n};
    neighbours(n).neighblabel = {};
end

cfg                     = [];
cfg.method              = 'montecarlo';cfg.statistic           = 'ft_statfun_correlationT'; 
cfg.clusterstatistics   = 'maxsum';cfg.type                = 'Spearman'; 
cfg.correctm            = 'cluster';cfg.clusteralpha        = 0.05;    
cfg.minnbchan           = 0;cfg.tail                = 0;cfg.clustertail         = 0;
cfg.alpha               = 0.025;cfg.numrandomization    = 1000;
cfg.neighbours          = neighbours;
cfg.ivar                = 1;

for gp = 1:3
    cfg.design (1,1:14)     = erf2permute(:,gp);
    stat{gp}                 = ft_freqstatistics(cfg, allsuj_GA{:});
    [min_p(gp),p_val{gp}]     = h_pValSort(stat{gp});
end

for gp = 2
    figure;
    corr2plot{gp}        = h_plotStat(stat{gp},min_p(gp)+0.0001);
    
    for c = 1
        cfg             = [];
        cfg.channel     = c;
        cfg.zlim        = [-4 4];
        ft_singleplotTFR(cfg,corr2plot{gp})
    end
    
end

gavg = ft_freqgrandaverage([],allsuj_GA{:});

f0      =   stat{2}.freq(1);
f1      =   stat{2}.freq(end);
t0      =   stat{2}.time(1);
t1      =   stat{2}.time(end);

tf_masked(gavg,stat{2},f0, f1,t0,t1,'audR',0.5,0.052,[-0.07 0.07]);
set(gca,'fontsize',18)
set(gca,'FontWeight','bold')
title('');