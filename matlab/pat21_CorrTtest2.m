clear ; clc ; dleiftrip_addpath;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj     = ['yc' num2str(suj_list(sb))];
    fname   = ['../data/tfr/' suj '.CnD.MaxAudVizMotor.SmallCov.VirtTimeCourse.Keeptrial.wav.1t20Hz.m3000p3000..mat'];
    
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    freq    = rmfield(freq,'hidden_trialinfo');
    
    cfg                         = [];
    cfg.baseline                = [-0.6 -0.2];
    cfg.baselinetype            = 'relchange';
    freq                        = ft_freqbaseline(cfg,freq);
    
    nw_chn                      = [1 1;2 2;3 5;4 6];
    nw_lst                      = {'occL','occR','audL','audR'};
    nw_frq                      = [12 15; 12 15; 10 10; 10 10];
    
    load ../data/yctot/rt/rt_cond_classified.mat
    
    for l = 1:size(nw_chn,1)
        
        cfg             = [];
        cfg.frequency   = [nw_frq(l,1) nw_frq(l,2)];
        cfg.channel     = nw_chn(l,:);
        cfg.latency     = [0.9 1.2];
        cfg.avgoverfreq = 'yes';
        cfg.avgoverchan = 'yes';
        cfg.avgovertime = 'yes';
        
        nwfrq{l}        = ft_selectdata(cfg,freq);
        
        data            = squeeze(nwfrq{l}.powspctrm);
        
        [rho,p]         = corr(data,rt_all{sb} , 'type', 'Spearman');
        rhoF            = .5.*log((1+rho)./(1-rho));
        
        allsuj(sb,1,l)   = rhoF  ;
        allsuj(sb,2,l)   = 0 ;
        
    end
    
    
end

for chn = 1:size(allsuj,3)
    
    x = squeeze(allsuj(:,1,chn));
    y = squeeze(allsuj(:,2,chn));
    
    [h(chn),p_val(chn)] = ttest(x,y);
    
    rhoV(chn) = mean(allsuj(:,1,chn));
    
end

mask    = p_val < 0.05 ;
nwpval  = p_val .* mask;