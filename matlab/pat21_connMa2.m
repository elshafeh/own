clear; clc ; dleiftrip_addpath ;

for a = 2:4
    
    for b = 1:3
        
        cnd = 'CnD';
        
        suj_list    = [1:4 8:17];
        suj         = ['yc' num2str(suj_list(a))];
        
        load(['../data/' suj '/headfield/' suj '.pt' num2str(b) '.adjusted.leadfield.5mm.mat']); clc ;
        
        load(['../data/' suj '/headfield/' suj '.VolGrid.5mm.mat']); clc ;
        
        fprintf('\nLoading %20s\n',['../data/' suj '/elan/' suj '.pt' num2str(b) '.' cnd]);
        load(['../data/' suj '/elan/' suj '.pt' num2str(b) '.' cnd '.mat']);
        
        cfg                 = [];
        cfg.bpfilter        = 'yes';
        cfg.bpfreq          = [1 20];
        dataica             = ft_preprocessing(cfg,data_elan);
        
        clear data_elan
        
        cfg                         = [];
        cfg.latency                 = [-3 3];
        dataica                     = ft_selectdata(cfg,dataica);
        
        cfg                         = [];
        cfg.covariance              = 'yes';
        cfg.covariancewindow        = [-0.6 1.1];
        avg                         = ft_timelockanalysis(cfg,dataica);
        
        clear data_elan
        
        load ../data/yctot/index/conMaIndx.mat ;
        
        cfg                     =   [];
        cfg.method              =   'lcmv';
        cfg.grid.pos            =   leadfield.pos(indx_tot(:,1),:);
        cfg.headmodel           =   vol;
        cfg.lcmv.keepfilter     =   'yes';
        cfg.lcmv.fixedori       =   'yes';
        cfg.lcmv.projectnoise   =   'yes';
        cfg.lcmv.keepmom        =   'yes';
        cfg.lcmv.projectmom     =   'yes';
        cfg.lcmv.lambda         =   '15%';
        source                  =   ft_sourceanalysis(cfg, avg);
        
        spatialfilter = cat(1,source.avg.filter{:});
        
        source = rmfield(source,'time');
        source = rmfield(source,'pos');
        source = rmfield(source,'method');
        source = rmfield(source,'avg');
        source = rmfield(source,'cfg');
        
        ext_essai = 'connMars' ;
        
        fname_out = [suj '.pt' num2str(b) '.' cnd '.virt.' ext_essai '.CommonFilter'];
        fprintf('\n\nSaving %50s \n\n',fname_out);
        save(['../data/' suj '/filter/' fname_out '.mat'],'spatialfilter','source','-v7.3')
        fprintf('Done!\n');
        
        clear source
        
        virtsens = [];
        
        ft_progress('init','text',    'Please wait...');
        
        for i=1:length(dataica.trial)
            virtsens.trial{i}=spatialfilter*dataica.trial{i};
            ft_progress(i/length(dataica.trial), 'Processing Trial %d from %d\n', i, length(dataica.trial));
        end;
        
        virtsens.time       =   dataica.time;
        virtsens.fsample    =   dataica.fsample;
        
        for i=1:length(virtsens.trial{1}(:,1))
            virtsens.label{i} = num2str(i);
        end
        
        virtsens_carr{b} = virtsens ;
        
        clearvars -except suj a b virtsens_carr cnd ext_essai
        
    end
    
    virtsens = ft_appenddata([],virtsens_carr{:});
    virtsens = rmfield(virtsens,'cfg');
    
    clear virtsens_carr
    
    fname_out = [suj '.' cnd '.virt.' ext_essai '.tcourse'];
    fprintf('\n\nSaving %50s \n\n',fname_out);
    save(['../data/' suj '/pe/' fname_out '.mat'],'virtsens','-v7.3');
    
end