clear ; close all;

list_suj                                = [1:4 8:17];
list_data                               = {'eeg'};
list_orig                               = {'CnD.eeg','pt1.CnD.meg','pt2.CnD.meg','pt3.CnD.meg'};
list_feat                               = {'inf.unf','left.right'};

for ns = 1:length(list_suj)
    
    for ndata = 1:length(list_orig)
        
        fname                           = ['../data/preproc_data/yc' num2str(list_suj(ns)) '.' list_orig{ndata} '.sngl.dwn100.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        if ndata == 1
            % eeg
            fname_in                    = ['../data/eegvol/yc' num2str(list_suj(ns)) '.eegVolElecLead.mat'];
            fprintf('\nLoading %50s\n',fname_in);
            load(fname_in);
            vol.elec                    = elec;
            
            data                        = rmfield(data,'cfg');
            data                        = rmfield(data,'hdr');
            data                        = rmfield(data,'grad');
            
        else
            % meg
            fname_in                    = ['/Volumes/heshamshung/alpha_compare/headfield/yc' num2str(list_suj(ns)) '.VolGrid.5mm.mat'];
            fprintf('\nLoading %50s\n',fname_in);
            load(fname_in);
            
            npart                       = list_orig{ndata}(3);
            fname_in                    = ['/Volumes/heshamshung/alpha_compare/headfield/yc' num2str(list_suj(ns)) '.pt' npart '.adjusted.leadfield.5mm.mat'];
            fprintf('\nLoading %50s\n',fname_in);
            load(fname_in);
            
        end
        
        cfg                             = [];
        cfg.latency                     = [-0.1 2];
        data                            = ft_selectdata(cfg,data); 
        
        cfg                             =[];
        %         cfg.preproc.lpfiler             ='yes';
        %         cfg.preproc.lpfreq              = 30;
        %         cfg.preproc.lpfilttype          ='firws';
        cfg.covariance                  ='yes';
        cfg.covariancewindow            = [-0.1 2];
        filter_avg                      = ft_timelockanalysis(cfg, data); clear data;
        
        spatialfilter                   = h_ramaComputeFilter(filter_avg,leadfield,vol);
        
        for nfeat = 1:2
            
            fname_in                    = ['/Volumes/heshamshung/alpha_compare/decode/topo/yc' num2str(list_suj(ns)) '.' list_orig{ndata} '.' list_feat{nfeat} '.auc.topo.mat'];
            fprintf('\nLoading %50s\n',fname_in);
            load(fname_in);
            
            data                        = [];
            data.avg                    = [scores]' * [spatialfilter]';
            data.avg                    = data.avg';
            data.dimord                 = 'chan_time';
            data.label                  = cellstr(num2str([1:size(spatialfilter,1)]'));
            data.time                   = filter_avg.time(1:end-1);
            
            fname_out                   = ['../data/wt_lcmv/yc' num2str(list_suj(ns)) '.' list_orig{ndata} '.' list_feat{nfeat} '.lp30.wt_lcmv.prob.mat'];
            fprintf('saving %50s\n',fname_out);
            save(fname_out,'data');
            
            clear data fname_out fname_in
            
        end
        
        keep list_* ns ndata
        
    end
    
end