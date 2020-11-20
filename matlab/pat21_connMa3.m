clear ; clc ;

for a = 1:4
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(a))];
    
    cnd = 'CnD';
    ext_essai = 'connMars' ;
    
    fname_out = [suj '.' cnd '.virt.' ext_essai '.tcourse'];
    fprintf('\nLoading %50s \n\n',fname_out);
    load(['../data/' suj '/pe/' fname_out '.mat']);
    
    load ../data/yctot/index/conMaIndx.mat ;
    
    rlist  = unique(indx_tot(:,2)); 
    rlabel = {'occL','occR','fefL','fefR','ipsL','ipsR','hesL','hesR','stgL','stgR'};
    
    for chn = 1:length(rlist)
        
        ix = find(indx_tot(:,2) == rlist(chn));
        
        cfg                 = [];
        cfg.channel         = ix ;
        cfg.avgoverchan     = 'yes';
        data{chn}           = ft_selectdata(cfg,virtsens);
        data{chn}.label     = rlabel(chn);
        
    end
    
    virtsens = ft_appenddata([],data{:});
    
    cfg                 = [];
    cfg.toilim          = [0.4 1];
    poi                 = ft_redefinetrial(cfg, virtsens);
    
    cfg                 = [];
    cfg.output          = 'fourier';
    cfg.method          = 'mtmfft';
    cfg.foilim          = [5 15];
    cfg.tapsmofrq       = 2;
    cfg.keeptrials      = 'yes';
    freq                = ft_freqanalysis(cfg, poi);
    
    cfg         = [];
    cfg.method  = 'coh';
    coherence   = ft_connectivityanalysis(cfg, freq);
    
    cfg         = [];
    cfg.xlim    = [5 15];
    cfg.zlim    = [0 1];
    figure
    ft_connectivityplot(cfg, coherence);
    
end