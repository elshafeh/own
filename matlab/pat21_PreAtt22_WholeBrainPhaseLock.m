clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

for sb = 1:21
    
    suj             = ['yc' num2str(sb)];
    list_cond       = {'LNCnD','RNCnD','LCnD','RCnD','CnD'};
    list_time       = {'m600m200','p600p1000'};
    list_freq       = {'7t11Hz'};
    
    ext_name        = 'OriginalPCC.0.5cm';
    
    for ncue = 1:length(list_cond)
        for ntime = 1:length(list_time)
            for nfreq = 1:length(list_freq)
                
                
                fname   = ['../data/pcc_data/' suj '.' list_cond{ncue} '.' list_time{ntime} '.' list_freq{nfreq} '.' ext_name '.mat'];
                
                fprintf('Loading %30s\n',fname);
                load(fname);
                index_voxels_in             = find(source.inside==1);
                
                new_source                  = source;
                new_source.inside           = source.inside(index_voxels_in);
                new_source.pos              = source.pos(index_voxels_in);
                new_source.avg.csd          = source.avg.csd(index_voxels_in);
                new_source.avg.noisecsd     = source.avg.noisecsd(index_voxels_in);
                new_source.avg.mom          = source.avg.mom(index_voxels_in);
                new_source.avg.csdlabel     = source.avg.csdlabel(index_voxels_in);

                fprintf('Computing Connectivity\n');
                
                cfg                         = [];
                cfg.method                  = 'plv';
                source_conn                 = ft_connectivityanalysis(cfg, new_source);
                
                new_conn                    = [];
                new_conn.pos                = source_conn.pos;
                new_conn.pow                = source_conn.plvspctrm(5,:)';
                
                cfg                         =   [];
                cfg.method                  =   'surface';
                cfg.funparameter            =   'pow';
                cfg.funcolorlim             =   [-5 5];
                cfg.opacitylim              =   [-5 5];
                cfg.opacitymap              =   'rampup';
                cfg.colorbar                =   'off';
                cfg.camlight                =   'no';
                cfg.projthresh              =   0.2;
                cfg.projmethod              =   'nearest';
                cfg.surffile                =   'surface_white_both.mat';
                cfg.surfinflated            =   'surface_inflated_both_caret.mat';
                ft_sourceplot(cfg, new_conn);
                
                
            end
        end
    end
end
