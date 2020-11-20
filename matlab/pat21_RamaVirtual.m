clear ; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    load(['../data/headfield/' suj '.VolGrid.5mm.mat']); clc ;
    
    for prt = 1:3
        
        cnd = {'DIS','fDIS'};
        
        load(['../data/headfield/' suj '.pt' num2str(prt) '.adjusted.leadfield.5mm.mat']); clc ;
        
        for cnd_cue = 1:length(cnd)
            fname = ['../data/elan/' suj '.pt' num2str(prt) '.' cnd{cnd_cue} '.mat'];
            fprintf('\nLoading %20s\n',fname);
            load(fname);
            data_sep{cnd_cue} = data_elan ; clear data_elan ;
        end
        
        if length(data_sep) > 1
            data_elan = ft_appenddata([],data_sep{:}) ;
        else
            data_elan = data_sep{1};
        end
        
        [ext_essai,dataica,avg]             = h_ramaPreprocess(data_elan,[1 140],[-0.6 0.6],[-3 3],suj,prt,[cnd{:}]); clear data_elan;
        spatialfilter                       = h_ramaComputeFilter(avg,leadfield,vol,ext_essai);
        [roi_list,vox_order,arsenal_list]   = h_ramaPrepareIndex('RamaAlphaFusion');

        for xi = 1:length(cnd)            
            [~,dataica_sep,~]               = h_ramaPreprocess(data_sep{xi},[1 140],[-0.6 0.6],[-3 3],suj,prt,[cnd{:}]);
            part_virtsens{xi,prt}          = h_ramaComputeVirtsens(dataica_sep,spatialfilter,roi_list,arsenal_list,vox_order); clear dataica_sep ;
        end
        
        clear spatialfilter roi_list arsenal_list vox_order dataica leadfield data_sep
        
    end
    
    clearvars -except cnd sb part_virtsens suj
    
    for xi = 1:length(cnd)
        
        virtsens                                = ft_appenddata([],part_virtsens{xi,:});
        virtsens                                = rmfield(virtsens,'cfg');
        
        fname_out                               = [suj '.' cnd{xi} '.RamaBigCov'];
        
        fprintf('\n\nSaving %50s \n\n',fname_out);
        save(['../data/pe/' fname_out '.mat'],'virtsens','-v7.3')
        
        in_function_computeTFR(virtsens,fname_out);
        in_function_computeTFRMinusEvoked(virtsens,fname_out);
        
        clear virtsens
        
    end
end