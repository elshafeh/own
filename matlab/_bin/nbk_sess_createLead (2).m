clear ; global ft_default
ft_default.spmversion = 'spm12';

load suj_list_peak.mat

for nsuj = [1:32 39:length(suj_list)]
    
    subjectname                             = ['sub' num2str(suj_list(nsuj))];
    
    vox_res                                 = '0.5cm';
    fname                                   = ['../data/template/template_grid_' vox_res '.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    fname                                   = ['../data/source/mri/mri_' num2str(suj_list(nsuj)) '.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    [vol, grid]                             = h_create_normalisedHeadmodel(mri,template_grid); clear fname;
    
    fname_out                               = ['../data/source/volgrid/' subjectname '.volgrid.' vox_res '.mat'];
    fprintf('\nsaving %s\n',fname_out);
    save(fname_out,'vol','grid','-v7.3');
    
    clear fnam*
    
    for nsession = 1:2
        
        %         fname                               = ['../data/prepro/stack/data_sess' num2str(nsession) '_s' num2str(suj_list(nsuj)) '_3stacked.mat'];
        %         fprintf('\nloading %s\n',fname);
        %         load(fname);
        %         grad                                = data.grad;
        %         label                               = data.label;
        
        fname                               = ['../data/prepro/stack/' subjectname '.session' num2str(nsession) '.stk.grad.mat'];
        fprintf('\loading %s\n',fname);
        load(fname);
        
        cfg                                 = [];
        cfg.grid                            = grid;
        cfg.grad                            = grad;
        cfg.headmodel                       = vol;
        cfg.channel                         = 'MEG';
        leadfield                           = ft_prepare_leadfield(cfg);
        
        cfg                                 = [];
        cfg.channel                         = label;
        leadfield                           = ft_selectdata(cfg,leadfield);
        leadfield                           = rmfield(leadfield,'cfg');
        
        fname_out                           = ['../data/source/lead/' subjectname '.session' num2str(nsession) '.leadfield.' vox_res '.mat'];
        fprintf('\nsaving %s\n',fname_out);
        save(fname_out,'leadfield','-v7.3');
        
        clear leadfield grad data label;
        
    end
end