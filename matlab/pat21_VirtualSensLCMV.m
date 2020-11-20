clear; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    suj = ['yc' num2str(suj_list(sb))];
    
    cnd_list = {'DIS','fDIS'};
    
    for prt = 1:3
        
        ext_filt = 'disfdis';
        
        FnameFiltIn = [suj '.pt' num2str(prt) '.' ext_filt '.lcmv.CommonFilter'];
        load(['../data/filter/' FnameFiltIn '.mat'])
        
        for cnd = 1:length(cnd_list)
            
            fprintf('\nLoading %20s\n',['../data/elan/' suj '.pt' num2str(prt) '.' cnd_list{cnd}]);
            load(['../data/elan/' suj '.pt' num2str(prt) '.' cnd_list{cnd} '.mat']);
            
            cfg                 = [];
            cfg.bpfilter        = 'yes';
            cfg.bpfreq          = [0.5 20];
            dataica             = ft_preprocessing(cfg,data_elan);
            
            cfg                 = [];
            cfg.latency         = [-0.2 0.8];
            dataica             = ft_selectdata(cfg,dataica);
            
            ext_filt = 'disfdis';
            
            arsenal_list    = {'avgHL','avgHR','avgSTL','avgSTR'};
            
            load ../data/yctot/index/lcmv.N1.DIS.mat
            
            indx_tot = indx_arsenal ;
            
            roi_list = unique(indx_tot(:,2));
            
            for d = 1:length(roi_list)
                
                fprintf('Computing region %2d out of %2d\n',d,length(roi_list));
                
                virtsens_sin{d} = [];
                
                ix              = indx_tot(indx_tot(:,2) == roi_list(d),1);
                filt_slct       = cell2mat(spatialfilter(ix,:));
                
                for i=1:length(dataica.trial)
                    virtsens_sin{d}.trial{i}=filt_slct*dataica.trial{i};
                    virtsens_sin{d}.trial{i}= squeeze(mean(virtsens_sin{d}.trial{i},1));
                end
                
                clear i
                
                virtsens_sin{d}.time       =   dataica.time;
                virtsens_sin{d}.fsample    =   dataica.fsample;
                virtsens_sin{d}.label      =   arsenal_list(d);
                
                clear filt_slct
                
            end
            
            clear d
            
            virtsens = ft_appenddata([],virtsens_sin{:});
            
            fname_out = [suj '.pt' num2str(prt) '.' cnd_list{cnd} '.virtlcmvN1.TimeCourse'];
            fprintf('\n\nSaving %50s \n\n',fname_out);
            save(['../data/pe/' fname_out '.mat'],'virtsens','-v7.3')
            
            clear virtsens
            
        end
        
    end
    
end