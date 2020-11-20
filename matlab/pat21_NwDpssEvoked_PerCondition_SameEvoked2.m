clear ; clc ; dleiftrip_addpath ;

suj_list    = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj         = ['yc' num2str(suj_list(sb))] ;
    load(['../data/headfield/' suj '.VolGrid.5mm.mat']);
    
    for ext_lock    = {'CnD'};

        for n_prt = 1:3
            
            load(['../data/headfield/' suj '.pt' num2str(n_prt) '.adjusted.leadfield.5mm.mat']);
            fname_in = [suj '.pt' num2str(n_prt) '.' ext_lock{:}];
            fprintf('Loading %50s\n',fname_in);
            load(['../data/elan/' fname_in '.mat'])
            
            avg   = ft_timelockanalysis([],data_elan);
            
            for n = 1:length(data_elan.trial)
                data_elan.trial{n} = data_elan.trial{n}-avg.avg;
            end
            
            clear avg
            
            lst_cnd_cue     = {'L','R'};

            extFilt_time    = 'm300p700';
            extFilt_freq    = '50t130Hz';
            extFilt_lock    = 'DisfDis';
            extFilt_dur     =  'MinusEvokedHanning.CommonFilter';
            nfilterout      = ['../data/filter/' suj '.pt' num2str(n_prt) '.' extFilt_lock '.' extFilt_time '.' extFilt_freq '.' extFilt_dur '.mat'];
            
            load(nfilterout);
            
            for ncue = 1:length(lst_cnd_cue)
                
                tlist = [-0.2:0.1:0.5 -0.2:0.1:0.5 -0.2:0.1:0.5];
                flist = [repmat(70,1,length(tlist)/3) repmat(90,1,length(tlist)/3) repmat(110,1,length(tlist)/3)];
                fpad  = 10;
                twin  = 0.1;
                tpad  = 0;
                
                for ntest = 1:length(tlist)
                    
                    cfg                     = [];
                    cfg.toilim              = [tlist(ntest)-tpad tlist(ntest)+tpad+twin];
                    cfg.trials              = h_chooseTrial(data_elan,ncue,0:3,1:4); % Here is where you choose the trials !!!
                    poi                     = ft_redefinetrial(cfg, data_elan);
                    
                    cfg                     = [];
                    cfg.method              = 'mtmfft';
                    cfg.foi                 = flist(ntest);
                    cfg.tapsmofrq           = fpad;
                    cfg.output              = 'powandcsd';
                    cfg.taper               = 'hanning';
                    freq                    = ft_freqanalysis(cfg,poi);
                    
                    if tlist(ntest) < 0
                        ext_ext= 'm';
                    else
                        ext_ext='p';
                    end
                    
                    ext_time                = [ext_ext num2str(floor(abs(tlist(ntest)*1000))) ext_ext num2str(floor(abs((tlist(ntest)+twin)*1000)))];
                    ext_freq                = [num2str(flist(ntest)-cfg.tapsmofrq) 't' num2str(flist(ntest)+cfg.tapsmofrq) 'Hz'];
                    
                    cfg                     = [];
                    cfg.method              = 'dics';
                    cfg.frequency           = freq.freq;
                    cfg.grid                = leadfield;
                    cfg.grid.filter         = com_filter ;
                    cfg.headmodel           = vol;
                    cfg.dics.fixedori       = 'yes';
                    cfg.dics.projectnoise   = 'yes';
                    cfg.dics.lambda         = '5%';
                    source                  = ft_sourceanalysis(cfg, freq);
                    source                  = source.avg.pow;
                    
                    clear freq poi
                    
                    ext_dur  = 'MinusSameEvokedHanning.source';
                    ext_name = [suj '.pt' num2str(n_prt) '.'  lst_cnd_cue{ncue} ext_lock{:}  '.' ext_time '.' ext_freq '.' ext_dur '.mat'];
                    fprintf('Saving Source\n');
                    
                    save(['../data/source/' ext_name],'source','-v7.3');
                    clear source ext_name
                    
                end
            end
            
            clear leadfield com_filter data_elan
            
        end
        
    end
    
    clear vol grid
    
end