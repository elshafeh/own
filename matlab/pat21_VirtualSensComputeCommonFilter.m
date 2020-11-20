clear; clc ; dleiftrip_addpath ;

list            = {{'CnD'}};
list_latency    = [-3 3];
list_covariance = [-0.8 2];
list_bp         = {{[1 20;40 120;1 120]}};
list_ext        = {'CnD'};
% 
% for t = 1:length(list)
%     tmp_freq        = [num2str(list_bp(1)) 't' num2str(list_bp(end)) 'Hz'];
%     tmp_time1       = ['m' num2str(abs(list_covariance(t,1))*1000)];
%     tmp_time2       = ['p' num2str(abs(list_covariance(t,2))*1000) 'ms'];
%     list_essai{t}   = [list_ext{t} '.' tmp_freq '.' tmp_time1 tmp_time2 '.ComFilt4Virtual'];
% end
% 
% clear tmp* t

for t = 1:length(list)
    
    cnd = list{t};
    
    for sb = 1:14
        
        suj_list    = [1:4 8:17];
        suj         = ['yc' num2str(suj_list(sb))];
        load(['../data/headfield/' suj '.VolGrid.5mm.mat']); clc ;
        
        for prt = 1:3
            
            for cnd_cue = 1:length(cnd)
                fname = ['../data/elan/' suj '.pt' num2str(prt) '.' cnd{cnd_cue} '.mat'];
                fprintf('\nLoading %20s\n',fname);
                load(fname);
                tmp{cnd_cue} = data_elan ; clear data_elan ;
            end
            
            if length(tmp) > 1
                data_elan = ft_appenddata([],tmp{:}) ; clear tmp ;
            else
                data_elan = tmp{1}; clear tmp;
            end
            
            ext_essai                   = list_essai{t};
            
            cfg                         = [];
            cfg.bpfilter                = 'yes';
            cfg.bpfreq                  = list_bp;
            dataica                     = ft_preprocessing(cfg,data_elan);
            
            clear data_elan
            
            cfg                         = [];
            cfg.latency                 = list_latency;
            dataica                     = ft_selectdata(cfg,dataica);
            
            cfg                         = [];
            cfg.covariance              = 'yes';
            cfg.covariancewindow        = list_covariance(t,:);
            avg                         = ft_timelockanalysis(cfg,dataica);
            
            clear dataica
            
            load(['../data/headfield/' suj '.pt' num2str(prt) '.adjusted.leadfield.5mm.mat']); clc ;
            
            spatialFiler                = h_ramaComputeFilter(dataica,leadfield,vol);

            fname_out = [suj '.pt' num2str(prt) '.' ext_essai];
            fprintf('\n\nSaving %50s \n\n',fname_out);
            save(['../data/filter/' fname_out '.mat'],'spatialfilter','-v7.3')
            
            clear spatialfilter leadfield
            
        end
    end
end