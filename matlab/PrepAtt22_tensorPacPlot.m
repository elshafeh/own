addpath(genpath('../fieldtrip-20151124/'));
addpath('DrosteEffect-BrewerMap-b6a6efc/');

suj_list                = [1:4 8:17];

for ngroup = 1
    for sb = 1:length(suj_list)
        
        suj                 = ['yc' num2str(suj_list(sb))] ;
        
        list_cnd            = {'NCnD','LCnD','RCnD'};
        
        list_mth            = {'KLD','MVL','HR','PhaSyn'}; % ,'ndPAC'
        
        list_tme            = {'m600m200','p600p1000'};
        
        for ncue = 1:length(list_cnd)
            for nmethod = 1:length(list_mth)
                for ntime = 1:length(list_tme)
                    
                    fname   = ['../data/prep21_pac/' suj '.' list_cnd{ncue} '.' list_tme{ntime} '.' ...
                        list_mth{nmethod} '.SwPhAmp.DivMean.NonZTransMinEvokedSepTensorPac.mat'];
                    
                    fprintf('Loading %30s\n',fname);
                    load(fname);
                    
                    transform_label                             = {'LHemi_Aud','RHemi_Aud'};
                    transform_index                             = {1:10,11:20};
                    
                    sub_tmp{ntime}                              = h_transform_freq(py_pac,transform_index,transform_label);
                    
                end
                
                allsuj_data{ngroup}{sb,ncue,nmethod}            = sub_tmp{1};
                %                 allsuj_data{ngroup}{sb,ncue,nmethod}.powspctrm  = (sub_tmp{2}.powspctrm - sub_tmp{1}.powspctrm)./sub_tmp{1}.powspctrm; clear sub_tmp
                
            end
        end
    end
end

clearvars -except allsuj_data list_*



for nchan = 1:2 % :length(data_to_plot.label)
    
    figure;
    i = 0 ;
    
    for ngroup = 1:length(allsuj_data)
        
        for nmethod = 1:size(allsuj_data{ngroup},3)
            for ncue = 1:size(allsuj_data{ngroup},2)
                
                data_to_plot            = ft_freqgrandaverage([],allsuj_data{ngroup}{:,ncue,nmethod});
                
                subplot_row             = 4;
                subplot_col             = 3;
                
                i                       = i + 1 ;
                
                subplot(subplot_row,subplot_col,i)
                
                cfg                     = [];
                cfg.channel             = nchan;
                cfg.parameter           = 'powspctrm';
                
                cfg.zlim                = [-9e-16 9e-16];
                cfg.xlim                = [5 15];
                
                cfg.colorbar            = 'no';
                ft_singleplotTFR(cfg,data_to_plot);
                title([list_cnd{ncue} ' ' list_mth{nmethod}]);
                
                colormap(brewermap(256, '*RdYlBu'))
                
            end
        end
    end
end