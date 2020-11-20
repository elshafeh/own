clear;clc;dleiftrip_addpath;

con_array           = {'DIS','fDIS'};
ext_array           = {'DisfDis.pe.ComFilter','DisfDis.pe.ComFilter'};
cmp_array           = {[-0.05 0:0.05:0.55],[-0.05 0:0.05:0.55]};
twin_array          = {repmat(0.05,1,13),repmat(0.05,1,13)};

cnd_array(1).cue    = {0:2};
cnd_array(1).tar    = {1:4};
cnd_array(1).dis    = {1:3};
cnd_array(1).ext    = {'DIS'};

cnd_array(2).cue    = {0:2};
cnd_array(2).tar    = {1:4};
cnd_array(2).dis    = {1:3};
cnd_array(2).ext    = {'fDIS'};

suj_list            = 15:17;

for sb = 1:length(suj_list)
    
    suj         = ['yc' num2str(suj_list(sb))] ;
    load(['../data/headfield/' suj '.VolGrid.5mm.mat']);
    
    for prt = 1:3
        
        load(['../data/headfield/' suj '.pt' num2str(prt) '.adjusted.leadfield.5mm.mat']);
        
        for cnd_big = 1:length(con_array)
            
            fname     = ['../data/elan/' suj '.pt' num2str(prt) '.' con_array{cnd_big} '.mat'] ;
            fprintf('\nLoading %30s\n',fname);
            load(fname);
           
            cfg                             = [];
            
            if strcmp(con_array{cnd_big},'CnD')
                cfg.lpfilter                = 'yes'; cfg.lpfreq                  = 20;
            else
                cfg.bpfilter                = 'yes'; cfg.bpfreq                  = [0.5 20];
            end
            
            data                            = ft_preprocessing(cfg,data_elan); clear data_elan ;
            
            ext_essai                       = ext_array{cnd_big};
            fnamefilt                       = [suj '.pt' num2str(prt) '.' ext_essai];
            fprintf('\n\nLoading %50s \n\n',fnamefilt); load(['../data/filter/' fnamefilt '.mat'])
            
            for cnd_small = 1:length(cnd_array(cnd_big).ext)
                
                ixCue                       = cnd_array(cnd_big).cue{cnd_small};
                ixDis                       = cnd_array(cnd_big).dis{cnd_small};
                ixTar                       = cnd_array(cnd_big).tar{cnd_small};
                
                cfg                         = [];
                cfg.trials                  = h_chooseTrial(data,ixCue,ixDis,ixTar);
                data_slct                   = ft_selectdata(cfg,data);
                
                for ncomp = 1:size(cmp_array{cnd_big},2)
                    
                    time_window             = twin_array{cnd_big}(ncomp);
                    
                    cfg                     = [];
                    cfg.toilim              = [cmp_array{cnd_big}(ncomp) cmp_array{cnd_big}(ncomp)+time_window];
                    nw_data                 = ft_redefinetrial(cfg,data_slct);
                    
                    if cmp_array{cnd_big}(ncomp) < 0; ext_ext= 'm'; else ext_ext='p'; end
                    
                    ext_time        = [ext_ext num2str(floor(abs(cmp_array{cnd_big}(ncomp)*1000))) ...
                        ext_ext num2str(floor(abs((cmp_array{cnd_big}(ncomp)+time_window)*1000)))];
                    
                    cfg                     = [];
                    cfg.covariance          = 'yes'; cfg.covariancewindow    = 'all';
                    avg                     = ft_timelockanalysis(cfg,nw_data);
                    
                    cfg                     =   [];
                    cfg.method              =   'lcmv'; 
                    cfg.grid                =   leadfield; cfg.grid.filter         =   spatialfilter;  
                    cfg.headmodel           =   vol; cfg.lcmv.fixedori       =   'yes'; 
                    cfg.lcmv.projectnoise   =   'yes'; cfg.lcmv.keepmom        =   'yes'; 
                    cfg.lcmv.projectmom     =   'yes'; cfg.lcmv.lambda         =   '15%';
                    source                  =   ft_sourceanalysis(cfg, avg);
                                        
                    source                  = source.avg.pow;
                    fname_out               = ['../data/new_source/' suj '.pt' num2str(prt) '.' cnd_array(cnd_big).ext{cnd_small} '.'  ext_time 'ms.lcmvSource.mat'];
                    
                    fprintf('\n\nSaving %50s \n\n',fname_out);
                    save(fname_out,'source','-v7.3');
                    
                    clear nw_data avg source ;
                    
                end
                
                clear data_slct ;
                
            end
            
            clear data
            
        end
    end
end