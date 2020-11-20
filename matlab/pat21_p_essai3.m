clear ; clc ; 

for sb = 1:4
   
    suj = ['yc' num2str(sb)];
    
    load(['../data/' suj '/pe/' suj '.CnD.virt.connMars.tcourse.mat']);
    
    load ../data/yctot/index/conMaIndx.mat ;
    
    rlist  = unique(indx_tot(:,2));
    rlabel = {'occL','occR','fefR','fefL','ipsL','ipsR','hesL','hesR','stgL','stgR'};
    
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
    cfg.toilim          = [0.6 1.1];
    poi                 = ft_redefinetrial(cfg, virtsens);
    
    cfg                 = [];
    cfg.output          = 'fourier';
    cfg.method          = 'mtmfft';
    cfg.foilim          = [5 15];
    cfg.tapsmofrq       = 2;
    cfg.keeptrials      = 'yes';
    freq                = ft_freqanalysis(cfg, poi);
    
    cfg                 = [];
    cfg.method          = 'plv';
    plv{sb}             = ft_connectivityanalysis(cfg, freq);
    cfg.method          = 'coh';
    coh{sb}             = ft_connectivityanalysis(cfg, freq);
    cfg.complex         = 'absimag';
    coh_img{sb}         = ft_connectivityanalysis(cfg, freq);
    
    clearvars -except coh coh_img sb plv
    
end

figure ;
cfg           = [];
cfg.parameter = 'cohspctrm';
cfg.zlim      = [0 0.5];
ft_connectivityplot(cfg, coh{:});
figure;
ft_connectivityplot(cfg, coh_img{:});
figure;
cfg.parameter = 'plvspctrm';
ft_connectivityplot(cfg, plv{:});