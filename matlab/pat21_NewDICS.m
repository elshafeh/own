clear ; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    for prt = 1:3
        
        suj_list = [1:4 8:17];
        
        list_cond = {'nDT'};
        
        suj         = ['yc' num2str(suj_list(sb))] ;
        fname_in    = [suj '.pt' num2str(prt) '.nDT'];
        
        fprintf('Loading %50s\n',fname_in);
        load(['../data/elan/' fname_in '.mat'])
        
        fprintf('\nLoading Leadfield\n');
        load(['../data/headfield/' suj '.pt' num2str(prt) '.adjusted.leadfield.5mm.mat']);
        load(['../data/headfield/' suj '.VolGrid.5mm.mat']); clc ;
        
        load(['../data/filter/' suj '.pt' num2str(prt) '.nDTGammaComFilter.m1600p700.40t80Hz.mat'])
        
        tlist             = [-1.4 0.1 0.2 0.3 0.4];
        flist             = [50 70];
        twin              = 0.1;
        ext_time          = {'m1400m1300','p100p200','p200p300','p300p400','p400p500'};
        ext_freq          = {'40t60Hz','60t80Hz'} ;
        
        for f = 1:length(flist)
            for t = 1:length(tlist)
                
                lm1             = tlist(t);
                lm2             = tlist(t) + twin;
                
                cfg             = [];
                cfg.toilim      = [lm1 lm2];
                poi             = ft_redefinetrial(cfg, data_elan);
                
                cfg               = [];
                cfg.method        = 'mtmfft';
                cfg.foi           = flist(f);
                cfg.tapsmofrq     = 10;
                cfg.output        = 'powandcsd';
                freq              = ft_freqanalysis(cfg,poi); clear poi;
                
                source            = h_freq2sourceSep(freq,com_filter,leadfield,vol) ; clear freq ;
                source_name       = ['../data/source/' suj '.pt' num2str(prt) '.nDTGamma.' ext_freq{f} '.' ext_time{t} '.mat'];
                
                save(source_name,'source') ;
                clear source ;
                
            end
        end
        clear data_elan com_filter
    end
end