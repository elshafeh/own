clear ; clc ; dleiftrip_addpath ;

con_array       = {{'CnD'},{'nDT'},{'DIS','fDIS'}};
fil_array       = [0.14 20;0.5 20; 0.5 20];
cov_array       = [-0.2 1.2; -0.2 0.6; -0.2 0.6];
win_array       = [-0.2 1.1; -0.2 0.6; -0.2 0.6];
ext_array       = {'CnD.pe.ComFilter','nDT.pe.ComFilter','DisfDis.pe.ComFilter'};
    
suj_list        = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))] ;
    
    load(['../data/headfield/' suj '.VolGrid.5mm.mat']);
    
    for prt = 1:3
        
        load(['../data/headfield/' suj '.pt' num2str(prt) '.adjusted.leadfield.5mm.mat']);
        
        for t = 1:length(con_array)
            for x = 1:length(con_array{t});
                fname_in = [suj '.pt' num2str(prt) '.' con_array{t}{x}];
                fprintf('Loading %50s\n',fname_in);
                load(['../data/elan/' fname_in '.mat'])
                data_carrier{x}      = data_elan ; clear data_elan ;
            end
            
            if length(data_carrier) == 1
                data = data_carrier{:} ; clear data_carrier ;
            else
                data = ft_appenddata([],data_carrier{:}) ;clear data_carrier ;
            end
            
            cfg                     = [];
            cfg.bpfilter            = 'yes';
            cfg.bpfreq              = fil_array(t,:);
            data_preproc            = ft_preprocessing(cfg,data); clear data ;
            
            cfg                     = [];
            cfg.covariance          = 'yes';
            cfg.covariancewindow    = cov_array(t,:);
            avg                     = ft_timelockanalysis(cfg,data_preproc);
            
            cfg                     = [];
            cfg.latency             = win_array(t,:);
            avg                     = ft_selectdata(cfg,avg);
                        
            cfg                     =   [];
            cfg.method              =   'lcmv';
            cfg.grid                =   leadfield; cfg.headmodel       =   vol;
            cfg.lcmv.keepfilter     =   'yes'; cfg.lcmv.fixedori       =   'yes';
            cfg.lcmv.projectnoise   =   'yes'; cfg.lcmv.keepmom        =   'yes';
            cfg.lcmv.projectmom     =   'yes';
            cfg.lcmv.lambda         =   '15%';
            source                  =   ft_sourceanalysis(cfg, avg);
            
            clear avg
            
            spatialfilter = source.avg.filter;
            
            clear source cfg
            
            ext_essai = ext_array{t};
            fname_out = [suj '.pt' num2str(prt) '.' ext_essai];
            fprintf('\n\nSaving %50s \n\n',fname_out);
            save(['../data/filter/' fname_out '.mat'],'spatialfilter','-v7.3')
            
            clear spatialfilter
        end
    end
end