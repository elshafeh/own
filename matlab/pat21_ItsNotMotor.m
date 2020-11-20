clear ; dleiftrip_addpath ;

ext_mat = 'BigCov' ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    lst_cnd     = {'R','L','N'};
    
    
    ext1        =   ['CnD.MaxAudVizMotor.' ext_mat '.VirtTimeCourse'];
    fname_in    =   ['../data/tfr/' suj '.'  ext1 '.all.wav.1t20Hz.m3000p3000..mat'];
    
    fprintf('\nLoading %50s \n',fname_in); load(fname_in);
    
    freq    = rmfield(freq,'hidden_trialinfo');
    
    cfg                 = []; 
    cfg.baseline        = [-0.6 -0.2];
    cfg.baselinetype    = 'relchange';
    freq                = ft_freqbaseline(cfg,freq);
    
    nw_chn  = [1 1;2 2; 3 5; 4 6; 7 7; 8 8];
    nw_lst  = {'occ.L','occ.R','aud.L','aud.R','MotL','MotR'};
    
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
    
    cfg                 = [];
    cfg.frequency       = [8 10];
    cfg.latency         = [-0.2 3];
    cfg.avgoverfreq     = 'yes';
    freq                = ft_selectdata(cfg,freq);
    
    lst_chn             = freq.label ;

    gavg(sb,:,:)        = squeeze(freq.powspctrm);
end

clearvars -except gavg lst_chn ;

ix_chn = [1 3 5; 2 4 6];

for x = 1:2
    
    subplot(1,2,x)
    plot(-0.2:0.05:3,squeeze(mean(gavg(:,ix_chn(x,:),:),1)),'LineWidth',4) ;
    legend(lst_chn(ix_chn(x,:)));
    xlim([-0.2 2.2]);
    ylim([-0.4 0.4]);
    hline(0,'-k');
    vline(0,'-k');
    vline(1.2,'-k');
    
end