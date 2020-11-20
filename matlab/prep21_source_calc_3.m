clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_list                = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj                 = ['yc' num2str(suj_list(sb))] ;
    
    fname_in            = ['/Volumes/Pat22Backup/meg21_fieldtrip_data_backup/data/all_data/' suj '.VolGrid.0.5cm.mat'];
    fprintf('\nLoading %50s\n',fname_in);
    load(fname_in);
    
    taper_type          = 'dpss';
    
    for prt = 1:3
        
        cond_main       = 'CnD.noncorr';
        fname_in        = ['/Volumes/PAT_MEG2/Fieldtripping/data/all_data/' suj '.pt' num2str(prt) '.' cond_main '.mat'];
        fprintf('\nLoading %50s\n',fname_in);
        load(fname_in);
        
        fname_in        = ['/Volumes/PAT_MEG2/Fieldtripping/data/headfield/' suj '.pt' num2str(prt) '.adjusted.leadfield.5mm.mat'];
        fprintf('\nLoading %50s\n',fname_in);
        load(fname_in);
        
        cfg             = [];
        cfg.latency     = [-3 3];
        data_elan       = ft_selectdata(cfg,data_elan);
        
        pkg.leadfield   = leadfield;
        pkg.vol         = vol;
        
        %         fname_in        = ['/Volumes/PAT_MEG2/Fieldtripping/data/all_data/' suj '.pt' num2str(prt) '.CnD.m800p2000.5t15Hz.NewCommonFilter.mat'];
        %         fprintf('\nLoading %50s\n',fname_in);
        %         load(fname_in);
        
        for list_lambda         = {'5%'};
            
            com_filter          = h_dicsCommonFilter(suj,data_elan,pkg,[-0.8 2],10,5,['pt' num2str(prt) '.' cond_main], ...
                [taper_type list_lambda{:} 'FixedCommonDicFilter0.5cm'],list_lambda{:},taper_type); % create common filter
            
            list_name_cue       = {''};
            cond_ix_cue         = {0:2};
            cond_ix_dis         = {0};
            cond_ix_tar         = {1:4};
            
            for ncue            = 1:length(list_name_cue)
                
                cfg             = [];
                cfg.trials      = h_chooseTrial(data_elan,cond_ix_cue{ncue},cond_ix_dis{ncue},cond_ix_tar{ncue});
                data_slct       = ft_selectdata(cfg,data_elan);
                
                %                 data_slct       = h_removeEvoked(data_slct);
                
                tlist           = [-0.6 0.6 0.2];
                twin            = [0.4 0.4 0.4];
                flist           = [9 13];
                fpad            = [2 2];
                tpad            = 0.025;
                
                for ntime = 1:length(tlist)
                    for nfreq = 1:length(flist)
                        
                        new_suj     = ['../data/revised_paper_source/' suj '.pt' num2str(prt) '.' list_name_cue{ncue} cond_main];
                        
                        source      = h_dicsSeparate(new_suj,data_slct,tlist(ntime),twin(ntime),tpad,flist(nfreq),fpad(nfreq), ...
                            com_filter,pkg,[taper_type 'New' list_lambda{:} 'Source'],list_lambda{:},taper_type); % create source
                        
                        clear source
                        
                    end
                end
            end
            
            clc ; clear com_filter ;
            
        end
    end
end