clear ; clc ; 

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    ext_essai   = 'FrontalAlpha.TimeCourseAuTop';
    load(['../data/pe/' [suj '.CnD.' ext_essai] '.mat'])
    
    avg         = ft_timelockanalysis([],virtsens) ;
    
    for n = 1:length(virtsens.trial)
        virtsens.trial{n} = virtsens.trial{n}-avg.avg;
    end
    
    clear avg ;
    
    cfg             = [];
    cfg.channel     = [5 6 7 16 26];
    data_slct{1}    = ft_selectdata(cfg,virtsens); clear virtsens;
    
    ext_essai   = 'MaxAudVizMotor.BigCov.VirtTimeCourse';
    load(['../data/pe/' [suj '.CnD.' ext_essai] '.mat'])
    
    nw_chn  = [1 1;2 2; 3 5; 4 6];
    nw_lst  = {'occL','occR','audL','audR'};
    
    for l = 1:size(nw_chn,1)
        cfg             = [];
        cfg.channel     = nw_chn(l,:);
        cfg.avgoverchan = 'yes';
        nwfrq{l}        = ft_selectdata(cfg,virtsens);
        nwfrq{l}.label  = nw_lst(l);
    end
    
    virtsens    = ft_appenddata([],nwfrq{:}); clear nwfrq ;
    
    avg         = ft_timelockanalysis([],virtsens) ;
    
    for n = 1:length(virtsens.trial)
        virtsens.trial{n} = virtsens.trial{n}-avg.avg;
    end
    
    clear avg ;
    
    data_slct{2}    = virtsens; clear virtsens;
    
    clear nw* ext_essai l nb n
    
    virtsens        = ft_appenddata([],data_slct{:}); clear data_slct ;
    
    tlist           = [-0.7 0.6];
    twin            = 0.5;
    clist           = {'bsl','actv'};
    
    for t = 1:length(tlist)
        
        cfg             = [];
        cfg.toilim      = [tlist(t) tlist(t)+twin];
        data            = ft_redefinetrial(cfg, virtsens);
        
        cfg             = [];
        cfg.foilim      = [5 15];
        cfg.method      = 'mtmfft';
        cfg.taper       = 'dpss';
        cfg.output      = 'fourier';
        cfg.tapsmofrq   = 2;
        freq            = ft_freqanalysis(cfg, data);
        
        cfg             = [];
        cfg.method      = 'coh';
        coh             = ft_connectivityanalysis(cfg, freq); clear freq ;
        
        save(['../data/tfr/' suj '.CnD.CohPrimer.' clist{t} '.mat'],'coh'); clear coh ;
        
    end
    
    clearvars -except coh ;
    
end
    