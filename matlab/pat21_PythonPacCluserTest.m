clear ; clc  ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    lst_chn = {'audL','audR'};
    lst_cnd = {'TightBSLPAC','TightACTPAC'};
    suj     = ['yc' num2str(suj_list(sb))];
    
    for cnd = 1:2
        
        fname   = ['../data/python_data/' suj '.' lst_cnd{cnd} '.mat'];
        fprintf('Loading %30s\n',fname);
        load(fname);
        
        py_pac.xpac(py_pac.pval>0.05)           = 0;
        tmp                                     = squeeze(mean(py_pac.xpac,3));
        
        grand_avg{sb,cnd}.powspctrm(1,:,:)      = squeeze(tmp(:,:,1));   
        grand_avg{sb,cnd}.powspctrm(2,:,:)      = squeeze(tmp(:,:,2));
        
        grand_avg{sb,cnd}.freq                  = double(py_pac.vec_amp);
        grand_avg{sb,cnd}.time                  = double(py_pac.vec_pha);
        grand_avg{sb,cnd}.label                 = lst_chn;
        grand_avg{sb,cnd}.dimord                = 'chan_freq_time';
        
    end
end

clearvars -except grand_avg ;

[design,neighbours]     = h_create_design_neighbours(length(grand_avg),grand_avg{1,1},'virt','t');

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'depsamplesT';
cfg.correctm            = 'bonferroni';
% cfg.channel             = 2;
cfg.frequency           = [50 100];
cfg.latency             = [5 15];
cfg.clusteralpha        = 0.05;
cfg.alpha               = 0.025;
cfg.minnbchan           = 0;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.numrandomization    = 1000;
cfg.design              = design;
cfg.neighbours          = neighbours;
cfg.uvar                = 1;
cfg.ivar                = 2;

stat                    = ft_freqstatistics(cfg, grand_avg{:,2}, grand_avg{:,1});
stat                    = rmfield(stat,'cfg');
[min_p,p_val]           = h_pValSort(stat);

stat.mask               = stat.prob < 0.05;

for chan = 1:length(stat.label)
    subplot(1,2,chan)
    cfg                                 = [];
    cfg.channel                         = chan;
    cfg.parameter                       = 'stat';
    cfg.maskparameter                   = 'mask';
    cfg.maskstyle                       = 'outline';
    cfg.zlim                            = [-3 3];
    ft_singleplotTFR(cfg,stat);
    xlabel('Phase (Hz)'); ylabel('Amplitude (Hz)');
end