clear ; clc;

if isunix
    start_dir               = '/project/';
else
    start_dir               = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName             = suj_list{nsuj};
    ext_name                = ['I:/hesham/bil/tf/' subjectName '.cuelock.mtmconvolPOW.m1p7s.20msStep.1t100Hz.1HzStep.AvgTrials.'];
    flist                   = dir([ext_name '*.mat']);
    
    for nfile = 1:length(flist)
        fname               = [flist(nfile).folder filesep flist(nfile).name];
        fprintf('loading %s\n',fname);
        load(fname);
        tmp{nfile}          = freq_comb; clear freq_comb;
    end
    
    freq                    = ft_freqgrandaverage([],tmp{:}); clear tmp;
    [suj_act,suj_bsl]       = h_prepareBaseline(freq,[-0.6 -0.4],[1 100],[-0.2 6],'no');
    
    alldata{nsuj,1}         = suj_act; clear suj_act;
    alldata{nsuj,2}         = suj_bsl; clear suj_bsl;
    
end

keep alldata

list_freq                   = [1 50; 50 100];
list_minchan                = [4 3];

cfg                       	= [];
cfg.statistic            	= 'ft_statfun_depsamplesT';
cfg.method                  = 'montecarlo';
cfg.correctm                = 'cluster';
cfg.clusteralpha            = 0.05;
cfg.clusterstatistic        = 'maxsum';
cfg.tail                    = 0;
cfg.clustertail             = 0;
cfg.alpha                   = 0.025;
cfg.numrandomization        = 1000;
cfg.uvar                    = 1;
cfg.ivar                    = 2;
nbsuj                       = size(alldata,1);
[design,neighbours]         = h_create_design_neighbours(nbsuj,alldata{1,1},'meg','t');
cfg.design                  = design;
cfg.neighbours              = neighbours;

for ntest = 1:2
    cfg.minnbchan         	= list_minchan(ntest);
    cfg.frequency           = list_freq(ntest,:);
    stat{ntest}          	= ft_freqstatistics(cfg, alldata{:,1}, alldata{:,2});
    [min_p(ntest),p_val{ntest}] 	= h_pValSort(stat{ntest});
end


keep alldata list_* stat min_p p_val

close all;

list_chan{2}{1}             = {'MLO11','MLO12','MLO21','MLO22','MLO31','MLP31','MLP41', ...
    'MLP51','MLP52','MRO11','MRO12','MRO21','MRO22','MRP31', ...
    'MRP41','MRP51','MRP52','MRP53','MZO01','MZP01'};

list_chan{2}{2}             = {'MLT23', 'MLT24', 'MLT33', 'MLT34', 'MLT35', 'MLT43', 'MLT44', 'MLT53'};

for ntest = 2 
    
    plimit                      = 0.1;
    stplot                      = h_plotStat(stat{ntest},10e-23,plimit,'stat');
    
    nrow    = 4;
    ncol    = 1;
    
    figure;
    cfg                         = [];
    cfg.layout                  = 'CTF275.lay';
    cfg.zlim                    = 'maxabs';
    cfg.colormap                = brewermap(256,'*RdBu');
    cfg.marker                  = 'off';
    cfg.comment                 = 'no';
    subplot(nrow,ncol,1);
    ft_topoplotTFR(cfg,stplot);
    
    for nlist = 1:length(list_chan{ntest})
        cfg.zlim                = 'maxabs';
        cfg.channel             = list_chan{ntest}{nlist};
        subplot(4,1,nlist+1)
        ft_singleplotTFR(cfg,stplot);
        vline([0 1.5 3 4.5],'--k');
        xticks([0 1.5 3 4.5]);
        xticklabels({'1st cue','1st gab','2nd cue','2nd gab'});
        title('');
    end
    
    for nlist = 1:length(list_chan{ntest})
        cfg.zlim                = 'maxabs';
        cfg.channel             = list_chan{ntest}{nlist};
        subplot(nrow,ncol,nlist+1)
        ft_singleplotTFR(cfg,stplot);
        vline([0 1.5 3 4.5],'--k');
        xticks([0 1.5 3 4.5]);
        xticklabels({'1st cue','1st gab','2nd cue','2nd gab'});
        title('');
    end
    
    %     nrow = 1;
    %     ncol =2;
    %     list_color                  = 'rb';
    %
    %     for nlist = 1:length(list_chan{ntest})
    %         cfg_slct                = [];
    %         cfg_slct.channel     	= list_chan{ntest}{nlist};
    %         data                    = ft_selectdata(cfg_slct,stplot);
    %         tmp                     = data.powspctrm;
    %         tmp(tmp == 0)           = NaN;
    %         tmp                     = squeeze(nanmean(tmp,1));
    %         tmp                     = squeeze(nanmean(tmp,2));
    %         tmp(isnan(tmp))         = 0;
    %         subplot(nrow,ncol,nlist)
    %         plot(data.freq,tmp,['-' list_color(nlist)],'LineWidth',2);
    %     end
           
    list_vline              = [0 1.5 3 4.5];
    cfg.plimit           	= plimit;
    cfg.vline               = list_vline;
    cfg.sign                = [-1 1];
    h_plotstat_3d(cfg,stat{ntest});
    
end

for ntest = 1 
    
    plimit                      = 0.1;
    stplot                      = h_plotStat(stat{ntest},10e-23,plimit,'stat');
    
    nrow    = 1;
    ncol    = 1;
    
    figure;
    cfg                         = [];
    cfg.layout                  = 'CTF275.lay';
    cfg.zlim                    = 'maxabs';
    cfg.colormap                = brewermap(256,'*RdBu');
    cfg.marker                  = 'off';
    cfg.comment                 = 'no';
    subplot(nrow,ncol,1);
    ft_topoplotTFR(cfg,stplot);
    
    for nlist = 1:length(list_chan{ntest})
        cfg.zlim                = 'maxabs';
        cfg.channel             = list_chan{ntest}{nlist};
        subplot(4,1,nlist+1)
        ft_singleplotTFR(cfg,stplot);
        vline([0 1.5 3 4.5],'--k');
        xticks([0 1.5 3 4.5]);
        xticklabels({'1st cue','1st gab','2nd cue','2nd gab'});
        title('');
    end
    
    for nlist = 1:length(list_chan{ntest})
        cfg.zlim                = 'maxabs';
        cfg.channel             = list_chan{ntest}{nlist};
        subplot(nrow,ncol,nlist+1)
        ft_singleplotTFR(cfg,stplot);
        vline([0 1.5 3 4.5],'--k');
        xticks([0 1.5 3 4.5]);
        xticklabels({'1st cue','1st gab','2nd cue','2nd gab'});
        title('');
    end
    
    %     nrow = 1;
    %     ncol =2;
    %     list_color                  = 'rb';
    %
    %     for nlist = 1:length(list_chan{ntest})
    %         cfg_slct                = [];
    %         cfg_slct.channel     	= list_chan{ntest}{nlist};
    %         data                    = ft_selectdata(cfg_slct,stplot);
    %         tmp                     = data.powspctrm;
    %         tmp(tmp == 0)           = NaN;
    %         tmp                     = squeeze(nanmean(tmp,1));
    %         tmp                     = squeeze(nanmean(tmp,2));
    %         tmp(isnan(tmp))         = 0;
    %         subplot(nrow,ncol,nlist)
    %         plot(data.freq,tmp,['-' list_color(nlist)],'LineWidth',2);
    %     end
           
    list_vline              = [0 1.5 3 4.5];
    cfg.plimit           	= plimit;
    cfg.vline               = list_vline;
    cfg.sign                = [-1 1];
    h_plotstat_3d(cfg,stat{ntest});
    
end