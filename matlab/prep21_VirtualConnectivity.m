clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_list = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'};

clearvars -except suj_list

for sb = 2:length(suj_list)
    
    suj                         = suj_list{sb};
    
    fprintf('Loading Virtual Data For %s\n',suj)
    
    dir_data                    = '../data/paper_data/';
    ext_virt_in                 = '50t120Hz.m800p2000msCov.mat';
   
    load([dir_data suj '.CnD.prep21.AV.' ext_virt_in]);
            
    for nchan = 1:length(virtsens.label)
        where_under = strfind(virtsens.label{nchan},'_');
        virtsens.label{nchan}(where_under) = ' ';
    end
    
    data_temp{1}                = virtsens ;

    load([dir_data suj '.CnD.prep21.maxTDBU.' ext_virt_in]);
        
    for nchan = 1:length(virtsens.label)
        where_under = strfind(virtsens.label{nchan},'_');
        virtsens.label{nchan}(where_under) = ' ';
    end
    
    data_temp{2}                = virtsens ;
    
    data                        = ft_appenddata([],data_temp{:}); clear virtsens data_temp ;
    
    list_cue                    = {'R','L','N'};
    list_ix_cue                 = {2,1,0};
    list_ix_tar                 = {1:4,1:4,1:4};
    list_ix_dis                 = {0,0,0};
    
    for ncue = 1:length(list_cue)
        
        cfg                     = [];
        cfg.trials              = h_chooseTrial(data,list_ix_cue{ncue},list_ix_dis{ncue},list_ix_tar{ncue});
        new_data                = ft_selectdata(cfg,data);
        
        new_data                = h_removeEvoked(new_data);
        
        cfg                     = [];
        cfg.method              = 'wavelet';
        cfg.output              = 'fourier';
        cfg.toi                 = -1:0.01:2;
        %--%
        cfg.foi                 = 60:5:100;
        ext_freq                = [num2str(round(cfg.foi(1))) 't' num2str(round(cfg.foi(end))) 'Hz'];
        %--%
        cfg.keeptrials          = 'yes';
        freq                    = ft_freqanalysis(cfg,new_data);
        
        %         fprintf('Saving Virtual Frequency For %s\n',suj)
        
        ext_name_out            = 'MinEvoked';
        ext_virt_use            = 'prep21.AV.maxTDBU';
        
        %         save([dir_data suj '.' list_cue{ncue} 'CnD.' ext_virt_use '.' ext_freq '.freqAndCfG_4fucntionalConnectivity' ext_name_out '.mat'],'freq','cfg','-v7.3');
        
        clc ; fprintf('Calculating PLV For %s\n',[suj ' ' list_cue{ncue} 'CnD'])
        
        cfg                     = [];
        cfg.method              = 'plv';
        freq_conn               = ft_connectivityanalysis(cfg,freq);
        
        freq_conn.powspctrm = freq_conn.plvspctrm; freq_conn = rmfield(freq_conn,'dof');
        freq_conn = rmfield(freq_conn,'cfg'); freq_conn = rmfield(freq_conn,'plvspctrm');
        
        save([dir_data suj '.' list_cue{ncue} 'CnD.' ext_virt_use '.' ext_freq '.plv' ext_name_out '.mat'],'freq_conn','-v7.3'); clear freq_conn
        
        %         clc ; fprintf('Calculating COH For %s\n',[suj ' ' list_cue{ncue} 'CnD'])
        %         cfg                     = [];
        %         cfg.method              = 'coh';
        %         cfg.complex             = 'absimag';
        %         freq_conn               = ft_connectivityanalysis(cfg,freq);
        %         freq_conn.powspctrm     = freq_conn.cohspctrm; freq_conn = rmfield(freq_conn,'dof');
        %         freq_conn = rmfield(freq_conn,'cfg'); freq_conn = rmfield(freq_conn,'cohspctrm');
        %         save([dir_data suj '.' list_cue{ncue} 'CnD.' ext_virt_use '.' ext_freq '.coh' ext_name_out '.mat'],'freq_conn','-v7.3'); clear freq_conn
        
        clear freq new_data; clc;
        
    end
    
    clear data ;
    
end