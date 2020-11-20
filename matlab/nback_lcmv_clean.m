clear ; close all; global ft_default
ft_default.spmversion = 'spm12';

for nsuj = [1:33 35:36 38:44 46:51]
    
    subjectname                                     = ['sub' num2str(nsuj)];
    
    fname                                           = ['J:temp\nback\data\voxbrain\preproc\sub' num2str(nsuj) '.session1.brain1vox.mat'];
    chk                                             = dir(fname);
    
    if isempty(chk)
        
        fname                                       = ['J:/temp/nback/data/source/volgrid/' subjectname '.volgrid.0.5cm.mat'];
        fprintf('\nloading %s\n',fname);
        load(fname);
        
        for nsession = 1:2
            
            fname_out                               = ['J:temp\nback\data\voxbrain\preproc\' subjectname '.session' num2str(nsession) '.brain1vox.mat'];
            chk                                     = dir(fname_out);
            
            if isempty(chk)
                
                fname                               =['K:/nback/nback_' num2str(nsession) '/data_sess' num2str(nsession) '_s' num2str(nsuj) '.mat'];
                fprintf('loading %s\n',fname);
                load(fname);
                
                fname                               = ['J:/temp/nback/data/source/lead/' subjectname '.session' num2str(nsession) '.leadfield.0.5cm.mat'];
                fprintf('loading %s\n',fname);
                load(fname);
                
                cfg                                 = [];
                cfg.resamplefs                      = 100;
                cfg.detrend                         = 'no';
                cfg.demean                          = 'no';
                data                                = ft_resampledata(cfg, data);
                
                cfg                                 = [];
                cfg.latency                         = [-1 2];
                data                                = ft_selectdata(cfg,data);
                data                                = rmfield(data,'cfg');
                
                spatialfilter                       = nk_virt_common_filter(data,[-0.5 1],leadfield,vol);
                data                                = nk_virt_compute(data,'../data/stock/brain1vox.mat',spatialfilter);
                
                fprintf('\nsaving %s\n',fname_out);
                save(fname_out,'data','-v7.3'); clc;
                
            end
        end
    end
end