h_start('/Users/heshamelshafei/Dropbox/ade_training/fieldtrip-20190127/');

suj_list            = [1:4 8:17];

for sb = 2:length(suj_list)
    
    suj             = ['yc' num2str(suj_list(sb))];
    
    list_cond_main  = {'pt1.CnD','pt2.CnD','pt3.CnD'};
    
    vox_size        = 0.5;
    dir_data        = '/Volumes/PAT_MEG2/Fieldtripping/data/';
    
    load([dir_data 'headfield/' suj '.VolGrid.5mm.mat']);
    
    pkg.vol         = vol;
    
    clear vol leadfield
    
    for nelan = 1:length(list_cond_main)
        
        fname_in            = [dir_data 'all_data/' suj '.' list_cond_main{nelan} '.mat'];
        
        load([dir_data 'headfield/' suj '.pt' num2str(nelan) '.adjusted.leadfield.5mm.mat']);
        
        pkg.leadfield       = leadfield; clear leadfield;
        
        fprintf('Loading %s\n',fname_in);
        load(fname_in)
        
        list_concat         = [-0.6 0.6];
        list_name           = {'m600m200p600p1200'};
        
        for nconcat = 1:size(list_concat,1)
            
            tlist            = list_concat(nconcat,:);
            twin             = [0.4 0.4];
            tpad             = 0.0;
            
            ext_time         = '';
            
            for ntime = 1:length(tlist)
                
                cfg             = [];
                cfg.latency     = [tlist(ntime)-tpad tlist(ntime)+tpad+twin(ntime)];
                poi{ntime}      = ft_selectdata(cfg,data_elan);
                
                if tlist(ntime) < 0
                    ext_time        = [ext_time 'm' num2str(abs(tlist(ntime)-tpad)*1000) 'm' num2str(abs(tlist(ntime)+tpad+twin(ntime))*1000)];
                else
                    ext_time        = [ext_time 'p' num2str(abs(tlist(ntime)-tpad)*1000) 'p' num2str(abs(tlist(ntime)+tpad+twin(ntime))*1000)];
                end
                
                if ntime < length(tlist)
                    ext_time        = [ext_time 'Concat'];
                end
                
            end
            
            data_filter             = ft_appenddata([],poi{:}); clear data_elan ;
            
            taper_type              = 'dpss';
            
            cfg                     = [];
            cfg.method              = 'mtmfft';
            cfg.output              = 'fourier';
            cfg.keeptrials          = 'yes';
            cfg.taper               = taper_type;
            cfg.foi                 = 80;
            cfg.tapsmofrq           = 20;
            freq                    = ft_freqanalysis(cfg,data_filter); 
            
            ext_freq                = [num2str(cfg.foi-cfg.tapsmofrq) 't' num2str(cfg.foi+cfg.tapsmofrq) 'Hz'];
            
            cfg                     = [];
            cfg.method              = 'pcc';
            cfg.frequency           = freq.freq; 
            cfg.grid                = pkg.leadfield; 
            cfg.headmodel           = pkg.vol;
            cfg.pcc.lambda          = '5%'; 
            cfg.pcc.keepfilter      = 'yes'; 
            cfg.pcc.projectnoise    = 'yes'; 
            cfg.pcc.fixedori        = 'yes'; 
            cfg.keeptrials          = 'yes';
            source                  = ft_sourceanalysis(cfg, freq);
            com_filter              = source.avg.filter;
            
            FnameFilterOut          = [suj '.' list_cond_main{nelan} '.' ext_freq '.' ext_time '.wConcatPCCommonFilter' '.' taper_type '.' num2str(vox_size) 'cm'];
            fprintf('\n\nSaving %50s \n\n',FnameFilterOut);
            
            clear ext_freq ext_time
            
            for ntime = 1:length(tlist)
                
                cond_ix_sub         = {''};
                cond_ix_cue         = {0:2};
                cond_ix_dis         = {0};
                cond_ix_tar         = {1:4};
                
                for ncue = 1:length(cond_ix_sub)
                    
                    trial_choose    = h_chooseTrial(poi{ntime},cond_ix_cue{ncue},cond_ix_dis{ncue},cond_ix_tar{ncue});
                    
                    cfg             = [];
                    cfg.trials      = trial_choose ;
                    data_sub        = ft_selectdata(cfg,poi{ntime});
                    
                    flist           = 80;
                    fpad            = 20;
                    
                    for nfreq = 1:length(flist)
                        
                        new_suj     = ['../data/source/' suj '.' cond_ix_sub{ncue} list_cond_main{nelan}];
                        
                        source      = h_pccSeparate(new_suj,data_sub,tlist(ntime),twin(ntime),tpad,flist(nfreq),fpad(nfreq), ...
                            com_filter,pkg,['wConcat' list_name{nconcat} 'PCCSource.' taper_type '.' num2str(vox_size) 'cm'],'yes',taper_type); % create source
                        
                        clear source new_suj
                        
                    end
                    
                    clear data_sub
                    
                end
            end
        end
    end
end