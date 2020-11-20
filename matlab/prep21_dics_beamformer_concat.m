clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_list            = {'yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'}; % 'yc1','yc2','yc3','yc4','yc8',

clearvars -except suj_list

for sb = 1:length(suj_list)
    
    suj             = suj_list{sb};
    
    list_cond_main  = {'pt1.CnD','pt2.CnD','pt3.CnD'};
    vox_size        = 0.5;
    
    load(['/Volumes/PAT_MEG2/Fieldtripping/data/headfield/' suj '.VolGrid.5mm.mat']);
    
    pkg.vol         = vol;
    
    clear vol leadfield
    
    for nelan = 1:length(list_cond_main)
        
        fname_in            = ['/Volumes/PAT_MEG2/Fieldtripping/data/all_data/' suj '.' list_cond_main{nelan} '.mat'];
        
        n_prt               = str2double(list_cond_main{nelan}(3));
        
        load(['/Volumes/PAT_MEG2/Fieldtripping/data/headfield/' suj '.pt' num2str(n_prt) '.adjusted.leadfield.5mm.mat']);
        
        pkg.leadfield       = leadfield; clear leadfield;
        
        fprintf('Loading %s\n',fname_in);
        load(fname_in)
        
        tlist               = [-0.6 0.6];
        twin                = [0.4 0.4];
        tpad                = 0.025;
        
        ext_time_filt            = '';
        
        for ntime = 1:length(tlist)
            
            cfg             = [];
            cfg.latency     = [tlist(ntime)-tpad tlist(ntime)+tpad+twin(ntime)];
            poi{ntime}      = ft_selectdata(cfg,data_elan);
            
            if tlist(ntime) < 0
                ext_time_filt        = [ext_time_filt 'm' num2str(abs(tlist(ntime)-tpad)*1000) 'm' num2str(abs(tlist(ntime)+tpad+twin(ntime))*1000)];
            else
                ext_time_filt        = [ext_time_filt 'p' num2str(abs(tlist(ntime)-tpad)*1000) 'p' num2str(abs(tlist(ntime)+tpad+twin(ntime))*1000)];
            end
            
            if ntime < length(tlist)
                ext_time_filt        = [ext_time_filt 'Concat'];
            end
            
        end
        
        data_filter                 = ft_appenddata([],poi{:}); clear data_elan ;
        
        flist                       = [9 13];
        fpad                        = [2 2];
        
        for nfreq = 1:length(flist)
            
            taper_type              = 'dpss';
            
            cfg                     = [];
            cfg.method              = 'mtmfft';
            cfg.output              = 'powandcsd';
            cfg.taper               = taper_type;
            cfg.foi                 = flist(nfreq);
            cfg.tapsmofrq           = fpad(nfreq);
            freq                    = ft_freqanalysis(cfg,data_filter); clc ;
            
            ext_freq_filt           = [num2str(cfg.foi-cfg.tapsmofrq) 't' num2str(cfg.foi+cfg.tapsmofrq) 'Hz'];
            
            cfg                     = [];
            cfg.method              = 'dics';
            cfg.frequency           = freq.freq;
            cfg.grid                = pkg.leadfield;
            cfg.headmodel           = pkg.vol;
            cfg.dics.keepfilter     = 'yes';
            cfg.dics.fixedori       = 'yes';
            cfg.dics.projectnoise   = 'yes';
            cfg.dics.lambda         = '5%';
            source                  = ft_sourceanalysis(cfg, freq);
            
            com_filter              = source.avg.filter;
            
            FnameFilterOut = [suj '.' list_cond_main{nelan} '.' ext_freq_filt '.' ext_time_filt '.wConcatDICSCommonFilter' '.' taper_type '.' num2str(vox_size) 'cm'];
            fprintf('\n\nSaving %50s \n\n',FnameFilterOut);
            
            for ntime = 1:length(tlist)
                
                cond_ix_sub         = {'N','L','R'};
                cond_ix_cue         = {0,1,2};
                cond_ix_dis         = {0,0,0};
                cond_ix_tar         = {1:4,1:4,1:4};
                
                for ncue = 1:length(cond_ix_sub)
                    
                    trial_choose    = h_chooseTrial(poi{ntime},cond_ix_cue{ncue},cond_ix_dis{ncue},cond_ix_tar{ncue});
                    
                    cfg             = [];
                    cfg.trials      = trial_choose ;
                    data_sub        = ft_selectdata(cfg,poi{ntime});
                    
                    new_suj         = ['../data/paper_data/' suj '.' list_cond_main{nelan}(1:3) '.' cond_ix_sub{ncue} list_cond_main{nelan}(5:end)];
                    
                    source          = h_dicsSeparate(new_suj,data_sub,tlist(ntime),twin(ntime),tpad,flist(nfreq),fpad(nfreq), ...
                        com_filter,pkg,['wConcatTightDicSource' '.' taper_type num2str(vox_size) 'cm'],'5%',taper_type); % create source
                    
                    
                end
            end
        end
    end
end