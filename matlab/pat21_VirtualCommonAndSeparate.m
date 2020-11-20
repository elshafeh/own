clear; clc ; dleiftrip_addpath ;

list = {{'CnD'}};

for t = 1
    
    cnd = list{t};
    
    for sb = 1:14
        
        suj_list = [1:4 8:17];
        
        suj = ['yc' num2str(suj_list(sb))];
        
        load(['../data/headfield/' suj '.VolGrid.5mm.mat']); clc ;
        
        for prt = 1:3
            
            for cnd_cue = 1:length(cnd)
                fname = ['/Volumes/PAT_MEG/Fieldtripping/data/' suj '/elan/' suj '.pt' num2str(prt) '.' cnd{cnd_cue} '.mat'];
                fprintf('\nLoading %20s\n',fname);
                load(fname);
                tmp{cnd_cue} = data_elan ; clear data_elan ;
            end
            
            data_elan                   = tmp{1} ; clear tmp ;
            
            cfg                         = [];
            cfg.bpfilter                = 'yes';
            cfg.bpfreq                  = [1 20];
            dataica                     = ft_preprocessing(cfg,data_elan);
            
            clear data_elan
            
            cfg                         = [];
            cfg.latency                 = [-3 3];
            dataica                     = ft_selectdata(cfg,dataica);
            
            cfg                         = [];
            cfg.covariance              = 'yes';
            cfg.covariancewindow        = [-0.8 1.2];
            avg                         = ft_timelockanalysis(cfg,dataica);
            
            load(['../data/headfield/' suj '.pt' num2str(prt) '.adjusted.leadfield.5mm.mat']); clc ;
            cfg                     =   [];
            cfg.method              =   'lcmv';
            cfg.grid                =   leadfield;
            cfg.headmodel           =   vol;
            cfg.lcmv.keepfilter     =   'yes';
            cfg.lcmv.fixedori       =   'yes';
            cfg.lcmv.projectnoise   =   'yes';
            cfg.lcmv.keepmom        =   'yes';
            cfg.lcmv.projectmom     =   'yes';
            cfg.lcmv.lambda         =   '15%';
            source                  =   ft_sourceanalysis(cfg, avg);
            
            clear avg
            
            spatialfilter           = cat(1,source.avg.filter{:});
            ext_essai               = 'CnD.m800p1200Cov.1t20Hz';
            
            clear source cfg
            
            fname_out = [suj '.pt' num2str(prt) '.virt.' ext_essai '.CommonFilter'];
            fprintf('\nSaving %50s \n\n',fname_out);
            save(['../data/filter/' fname_out '.mat'] ,'spatialfilter','-v7.3')
            
            clear leadfield
            
            load ../data/yctot/index/NewSourceAudVisMotor.mat
            load ../data/template/source_struct_template_MNIpos.mat
            
            roi_list    = unique(indx_arsenal(:,2));
            vox_order   = [1:length(source.pos)]';
            vox_order   = [vox_order source.inside] ;
            vox_order   = vox_order(vox_order(:,2)==1,1); % because the outside voxels are not in the fitler matrix :)
            
            clear source ;
            ft_progress('init','text',    'Please wait...');
            
            for d = 1:length(roi_list)
                
                ft_progress(d/length(roi_list), 'Processing ROI %d from %d\n', d, length(roi_list));
                
                virtsens_sin{d} = [];
                tmp             = indx_arsenal(indx_arsenal(:,2) == roi_list(d),1);
                
                ix = [];
                
                for i =1:length(tmp)
                    ix = [ix; find(vox_order==tmp(i))];
                end
                
                filt_slct       = spatialfilter(ix,:);
                
                clear ix tmp
                
                for i=1:length(dataica.trial)
                    virtsens_sin{d}.trial{i}    =   filt_slct*dataica.trial{i};
                    virtsens_sin{d}.trial{i}    =   squeeze(mean(virtsens_sin{d}.trial{i},1));
                end
                
                clear i filt_slct
                
                virtsens_sin{d}.time       =   dataica.time;
                virtsens_sin{d}.fsample    =   dataica.fsample;
                virtsens_sin{d}.label      =   list_arsenal(roi_list(d));
                
                clear filt_slct
                
            end
            
            part_virtsens{prt}              = ft_appenddata([],virtsens_sin{:});
            part_virtsens{prt}.trialinfo    = dataica.trialinfo;
            
            clear virtsens_sin dataica
            
        end
        
        virtsens = ft_appenddata([],part_virtsens{:});
        virtsens = rmfield(virtsens,'cfg');
        
        clear part_virtsens
        
        fname_out = [suj '.CnD.MaxAudVizMotor.SmallCov.VirtTimeCourse'];
        fprintf('\n\nSaving %50s \n\n',fname_out);
        save(['../data/pe/' fname_out '.mat'],'virtsens','-v7.3')
        
        clear virtsens spatialfilter vox_order indx_arsenal roi_list fname_out
        
    end
end