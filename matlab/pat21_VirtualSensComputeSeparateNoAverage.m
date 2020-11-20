clear; clc ; dleiftrip_addpath ;

for t = 1
    
    big_cnd_list    = {{'CnD'}};
    big_filt_list   = {'Filt4VirtualSens.CoV.m800p2000ms.freq.1t120Hz'};
    
    big_ars_list    = 'CnD.SomaGamma' ;
    list_latency    = [-3 3];
    list_bp         = [1 120];
    
    for sb = 1:14
        
        suj_list = [1:4 8:17];
        suj = ['yc' num2str(suj_list(sb))];
        
        cnd_list = big_cnd_list{t};
        
        for cnd = 1:length(cnd_list)
            
            for prt = 1:3
                
                fprintf('\nLoading %20s\n',['../data/elan/' suj '.pt' num2str(prt) '.' cnd_list{cnd}]);
                load(['../data/elan/' suj '.pt' num2str(prt) '.' cnd_list{cnd} '.mat']);
                
                cfg                         = [];
                cfg.bpfilter                = 'yes';
                cfg.bpfreq                  = list_bp;
                dataica                     = ft_preprocessing(cfg,data_elan);
                
                clear data_elan
                
                cfg                         = [];
                cfg.latency                 = list_latency;
                dataica                     = ft_selectdata(cfg,dataica);
                
                fname_out = [suj '.pt' num2str(prt) '.' big_filt_list{t}];
                load(['../data/filter/' fname_out '.mat'])
                
                load ../data/template/source_struct_template_MNIpos.mat
                
                load(['../data/yctot/index/' big_ars_list '.mat'])
                
                vox_order   = [1:length(source.pos)]';
                vox_order   = [vox_order source.inside] ;
                vox_order   = vox_order(vox_order(:,2)==1,1); % because the outside voxels are not in the fitler matrix :)
                
                clear source ;
                
                ft_progress('init','text',    'Please wait...');
                
                virtsens_sin = {};
                
                for d = 1:length(arsenal_list)
                    
                    ft_progress(d/length(arsenal_list), 'Processing ROI %d from %d\n', d, length(arsenal_list));
                    
                    ix              = find(vox_order==arsenal_list{d,2});
                    filt_slct       = spatialfilter(ix,:);
                    
                    clear ix tmp flg*
                    
                    for i=1:length(dataica.trial)
                        virtsens_sin{d}.trial{i}    =   filt_slct*dataica.trial{i};
                        virtsens_sin{d}.trial{i}    =   squeeze(nanmean(virtsens_sin{d}.trial{i},1));
                    end
                    
                    clear i filt_slct
                    
                    virtsens_sin{d}.time       =   dataica.time;
                    virtsens_sin{d}.fsample    =   dataica.fsample;
                    virtsens_sin{d}.label      =   arsenal_list(d,1);
                    
                    clear filt_slct
                    
                end
                
                part_virtsens{prt}              = ft_appenddata([],virtsens_sin{:});
                part_virtsens{prt}.trialinfo    = dataica.trialinfo;
                clear virtsens_sin dataica
                
            end
            
            virtsens = ft_appenddata([],part_virtsens{:});
            virtsens = rmfield(virtsens,'cfg');
            
            clear part_virtsens
            
            fname_out = [suj '.' cnd_list{cnd} big_ars_list(4:end) 'NoAVG' big_filt_list{t}(17:end)];
            
            fprintf('\n\nSaving %50s \n\n',fname_out);
            save(['../data/pe/' fname_out '.mat'],'virtsens','-v7.3')
            
            in_function_computeTFR(virtsens,fname_out)
            
            clear virtsens spatialfilter vox_order indx_arsenal roi_list fname_out
            
        end
    end
end