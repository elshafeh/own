clear ; clc ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    load(['../data/tfr/' suj '.CnD.Paper.TimeCourse.KeepTrial.wav.5t18Hz.m4p4.mat'])
    
    cfg                 = [];
    cfg.avgoverrpt      = 'yes';
    freq                = ft_selectdata(cfg,freq);
    
    cfg                 = [];
    cfg.baseline        = [-0.6 -0.2];
    cfg.baselinetype    = 'relchange';
    freq                = ft_freqbaseline(cfg,freq);
    
    lst_occ = [1 2];
    lst_aud = [3 4 5 6];
    
    t_list = 0.6:0.1:1;
    f_list = 7:15;
    
    for chnOcc = 1:2
        for chnAud = 1:4
            for f = 1:length(f_list)
                for t = 1:length(t_list)
                    
                    lmf         = find(round(freq.freq) == f_list(f));
                    lmt1        = find(round(freq.time,2) == round(t_list(t),2));
                    lmt2        = find(round(freq.time,2) == round(t_list(t)+0.1,2));

                    dataOcc     = squeeze(mean(freq.powspctrm(chnOcc,lmf,lmt1:lmt2),3));
                    dataAud     = squeeze(mean(freq.powspctrm(chnAud,lmf,lmt1:lmt2),3));

                    dataCorr(sb,chnOcc,chnAuf,f,t)    = rho;
                    dataP(sb,chnOcc,chnAuf,f,t)       = p;
                    
                    clear rho p lm*
                    
                end
            end
        end
    end
    
    clearvars -except  
    
end