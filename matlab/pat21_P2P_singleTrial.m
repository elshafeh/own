clear ; clc ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    ext1        = 'SomaAuditoryVisualAlpaBetaGamma.KeepTrial.wav.pow.mat';
    fname_in    = ['../data/tfr/' suj '.'  ext1];
    
    fprintf('\nLoading %50s \n',fname_in);
    load(fname_in)
    
    if isfield(freq,'hidden_trialinfo')
        freq    = rmfield(freq,'hidden_trialinfo');
    end
    
    bsl_period                              = {[-0.6 -0.2];[-0.4 -0.2];[-0.2 -0.1]};
    frq_intrst                              = {[8 12];[16 32];[52 72]};
    
    i                                       = 0;
    
    for ntest = [1 2]
        
        i                                   = i + 1;
        
        cfg                                 = [];
        cfg.baseline                        = bsl_period{ntest};
        cfg.baselinetype                    = 'relchange';
        tmp                                 = ft_freqbaseline(cfg,freq);
        
        cfg                                 = [];
        cfg.latency                         = [-0.2 2];
        cfg.frequency                       = frq_intrst{ntest};
        cfg.avgoverfreq                     = 'yes';
        tmp                                 = ft_selectdata(cfg,tmp);
        
        mtrx(i,:,:,:)                       = squeeze(tmp.powspctrm);
        
        tline                               = tmp.time;
        cline                               = tmp.label;clear tmp ;
        
    end
    
    for chan = 1:size(mtrx,3)
        for t = 1:size(mtrx,4)
            
            data1       = squeeze(mtrx(1,:,chan,t))';
            data2       = squeeze(mtrx(2,:,chan,t))';
            
            [rho,p]     = corr(data1,data2,'type','Pearson');
            
            rho_mask    = p < 0.05 ;
            
            rho         = rho .* rho_mask ; % !!
            
            rhoF        = .5.*log((1+rho)./(1-rho));
            
            avg(chan,t) = rhoF ;
            
        end
    end
    
    allsuj{sb,1}.avg = avg ;
    allsuj{sb,2}.avg = zeros(size(avg,1),size(avg,2));
    
    for cnd = 1:2
        allsuj{sb,cnd}.label    = freq.label;
        allsuj{sb,cnd}.time     = tline;
        allsuj{sb,cnd}.dimord   = 'chan_time';
    end
    
    clear avg mtrx
    
end

clearvars -except allsuj ;

[design,neighbours]     = h_create_design_neighbours(length(allsuj),allsuj{1,1},'virt','t');

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'depsamplesT';
cfg.correctm            = 'cluster';
% cfg.correctm            = 'fdr';
cfg.clusteralpha        = 0.005;
cfg.alpha               = 0.025;
cfg.minnbchan           = 0;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.numrandomization    = 1000;
cfg.design              = design;
cfg.neighbours          = neighbours;
cfg.uvar                = 1;
cfg.ivar                = 2;
stat                    = ft_timelockstatistics(cfg, allsuj{:,1}, allsuj{:,2});

stat                    = rmfield(stat,'cfg');
[min_p,p_val]           = h_pValSort(stat);
p_lim                   = 0.05;
stat2plot               = h_plotStat(stat,0.000000000000000000000000001,p_lim);

for chn = 1:length(stat2plot.label)
    
    subplot(4,3,chn)
    
    cfg             = [];
    cfg.channel     = chn;
    cfg.ylim        = [0 8];
    ft_singleplotER(cfg,stat2plot);clc;
    title(stat2plot.label{chn})
    hline(0,'-k');
    vline(0,'--k');
    vline(1.2,'--k');
    
end