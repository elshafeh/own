clear ; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))] ;
    ext_res     = '1cm';
    
    load(['../data/all_data/' suj '.VolGrid.' ext_res '.mat']);
    
    ext_lock    = 'CnD';
    
    for n_prt = 1:3
        
        load(['../data/all_data/' suj '.pt' num2str(n_prt) '.adjusted.leadfield.' ext_res '.mat']);
        
        fname_in = [suj '.pt' num2str(n_prt) '.' ext_lock];
        fprintf('Loading %50s\n',fname_in);
        
        load(['/Volumes/PAT_MEG2/Fieldtripping/data/elan/' fname_in '.mat'])
        
        % create common filter
        
        cfg                     = [];
        cfg.toilim              = [-0.8 2];
        poi                     = ft_redefinetrial(cfg, data_elan);
        
        cfg                     = [];
        cfg.method              = 'mtmfft';
        cfg.output              = 'fourier';
        cfg.keeptrials          = 'yes';
        cfg.foi                 = 10;
        cfg.tapsmofrq           = 5;
        freqCommon              = ft_freqanalysis(cfg,poi);
        
        cfg                     = [];
        cfg.frequency           = freqCommon.freq;
        cfg.method              = 'pcc';
        cfg.grid                = leadfield;
        cfg.headmodel           = vol;
        cfg.keeptrials          = 'yes';
        cfg.pcc.lambda          = '10%';
        cfg.pcc.projectnoise    = 'yes';
        cfg.pcc.keepfilter      = 'yes';
        cfg.pcc.fixedori        = 'yes';
        source                  = ft_sourceanalysis(cfg, freqCommon);
        com_filter              = source.avg.filter;
        
        clear source freqCommon
        
        nfilterout = ['../data/all_data/' suj '.pt' num2str(n_prt) '.' ext_lock '.pccCommonFilter' ext_res '.mat'];
        fprintf('Saving Filter\n');
        save(nfilterout,'com_filter','-v7.3');
        
        tlist = [-0.6 0.2 0.6 1.4];
        flist = [9 13];
        twin  = 0.4;
        tpad  = 0.25;
        fpad  = 2;
        
        for f = 1:length(flist)
            for t = 1:length(tlist)
                
                cfg                     = [];
                cfg.toilim              = [tlist(t)-tpad tlist(t)+tpad+twin];
                poi                     = ft_redefinetrial(cfg, data_elan);
                
                cfg                     = [];
                cfg.method              = 'mtmfft';
                cfg.output              = 'fourier';
                cfg.keeptrials          = 'yes';
                cfg.foi                 = flist(f);
                cfg.tapsmofrq           = fpad;
                freq                    = ft_freqanalysis(cfg,poi);
                
                if tlist(t) < 0
                    ext_ext= 'm';
                else
                    ext_ext='p';
                end
                
                ext_time              = [ext_ext num2str(abs(tlist(t)*1000)) ext_ext num2str(abs((tlist(t)+twin)*1000))];
                ext_freq              = [num2str(flist(f)-fpad) 't' num2str(flist(f)+fpad) 'Hz'];
                
                cfg                   = [];
                cfg.frequency         = freq.freq;
                cfg.method            = 'pcc';
                cfg.grid              = leadfield;
                cfg.grid.filter       = com_filter;
                cfg.headmodel         = vol;
                cfg.keeptrials        = 'yes';
                cfg.pcc.lambda        = '10%';
                cfg.pcc.projectnoise  = 'yes';
                source                = ft_sourceanalysis(cfg, freq);
                
                source.pos            = grid.MNI_pos;
                
                cfg                   = [];
                cfg.method            = 'coh';
                cfg.complex           = 'absimag';
                source_conn           = ft_connectivityanalysis(cfg, source);
                
                source_conn.dimord    = 'pos_pos';
                
                cfg                   = [];
                cfg.method            = 'degrees';
                cfg.parameter         = 'cohspctrm';
                cfg.threshold         = .1;
                network_full          = ft_networkanalysis(cfg,source_conn);
                
                source                = rmfield(source,'cfg');
                source_conn           = rmfield(source_conn,'cfg');
                network_full          = rmfield(network_full,'cfg');

                clear freq poi
                
                ext_name = [suj '.pt' num2str(n_prt) '.' ext_lock '.' ext_time '.' ext_freq '.PCCSource' ext_res '.mat'];
                fprintf('Saving Source\n');
                save(['../data/all_data/' ext_name],'source','source_conn','network_full','-v7.3');
                
                clear source ext_name source_conn network_full
                
            end
        end
        
        clear leadfield com_filter data_elan
        
    end
    
    clear vol grid
    
end