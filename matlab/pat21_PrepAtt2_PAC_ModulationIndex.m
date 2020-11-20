clear ; clc ; dleiftrip_addpath ;

for sb = 2:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    ext_essai   = 'SomaAuditoryVisual.m3000p3000.1t120Hz.fourier.mat';
    
    fprintf('Loading %s\n',['../data/tfr/' suj '.' ext_essai])
    load(['../data/tfr/' suj '.' ext_essai]);
    
    lstlst  = [0.1 1.1; -1.1 -0.1];
    
    for t = 1:2
        
        cfg             = [];
        cfg.latency     = lstlst(t,:) ; %[0.6 1.1];
        frqSlct         = ft_selectdata(cfg,freq);
        
        if cfg.latency(1) < 0
            ext_ext= 'm';
        else
            ext_ext='p';
        end
        
        ext3            = [ext_ext num2str(abs(cfg.latency(1)*1000)) ext_ext num2str(abs((cfg.latency(2))*1000))];
        
        
        cfg             = [];
        cfg.method      = 'mi';
        cfg.freqlow     = [5 20];
        cfg.freqhigh    = [25 120];
        cfg.channel     = 1:12;
        cfg.keeptrials  = 'yes';
        crossfreq       = h_crossfrequencycoupling(cfg, frqSlct);
        crossfreq       = rmfield(crossfreq,'cfg');
        
        ext1            = [num2str(cfg.freqlow(1)) 't' num2str(cfg.freqlow(end))];
        ext2            = [num2str(cfg.freqhigh(1)) 't' num2str(cfg.freqhigh(end))];
        
        save(['../data/tfr/' suj '.SomaAuditoryVisual.' ext1 '.with.' ext2 '.' ext3 'ms.mi.mat'],'crossfreq','-v7.3')
        
        clear crossfreq
        
    end
    
    clear frqSlct freq
    
end