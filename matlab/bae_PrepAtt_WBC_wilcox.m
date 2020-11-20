clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

load ../data_fieldtrip/template/template_grid_0.5cm.mat

for sb = 1:21
    
    suj         = ['yc' num2str(sb)] ;
    
    list_freq   = {'60t100Hz'};
    list_time   = {'.fDIS.p100p300','.DIS.p100p300'};
    list_roi    = {'MinEvoked.audLR'};
    list_mesure = {'plvConn','cohConn'};
    list_cue    = {''};
    
    for ncue = 1:length(list_cue)
        for nfreq = 1:length(list_freq)
            for nroi = 1:length(list_roi)
                for nmes = 1:length(list_mesure)
                    for ntime = 1:length(list_time)
                        
                        fname_in = ['../data/' suj '/field/' suj list_cue{ncue} list_time{ntime} '.' list_freq{nfreq} '.' list_roi{nroi} '.' list_mesure{nmes} '.NewBroadAreas.mat'];
                        
                        fprintf('Loading %s\n',fname_in);
                        load(fname_in)
                        
                        source_gavg(sb,ncue,nfreq,nroi,nmes,ntime,:) = source;
                        
                        clear  source
                        
                    end
                end
            end
        end
    end
end

clearvars -except source_gavg list_* *_list

load ../data_fieldtrip/template/template_grid_0.5cm.mat

for ncue = 1:length(list_cue)
    for nfreq = 1:length(list_freq)
        for nroi = 1:length(list_roi)
            for nmes = 1:length(list_mesure)
                
                
                all_p               = []; all_h             = []; all_stat_zval     = []; all_stat_ranksum  = [];

                ft_progress('init','text',    'Computing test-statistic...');

                vox_list            = [1:length(template_grid.pos)]';
                where_vox_are       = vox_list(template_grid.inside==1);
                
                for n_samp = 1:size(where_vox_are,1)
                    
                    ft_progress(n_samp/size(where_vox_are,1), 'Processing voxel %d from %d\n', n_samp, size(where_vox_are,1));
                    
                    dat_x                       = source_gavg(:,ncue,nfreq,nroi,nmes,2,where_vox_are(n_samp));
                    dat_y                       = source_gavg(:,ncue,nfreq,nroi,nmes,1,where_vox_are(n_samp));
                    
                    [dat_p,dat_h,dat_stat]      = ranksum(dat_x,dat_y);
                    
                    all_p                       = [all_p ; dat_p];
                    all_h                       = [all_h; dat_h];
                    all_stat_zval               = [all_stat_zval ; dat_stat.zval];
                    all_stat_ranksum            = [all_stat_ranksum ; dat_stat.ranksum];
                    
                end
                
                [corrected_p, corrected_h]                              = bonf_holm(all_p,0.05);
                
                [fdr_h, ~, fdr_adj_ci_cvrg, fdr_adj_p]                  = fdr_bh(all_p);
                
                stat{ncue,nfreq,nroi,nmes}.p_val                        = zeros(length(vox_list),1);
                stat{ncue,nfreq,nroi,nmes}.p_val_corr                   = zeros(length(vox_list),1);
                stat{ncue,nfreq,nroi,nmes}.mask                         = zeros(length(vox_list),1);
                stat{ncue,nfreq,nroi,nmes}.stat                         = zeros(length(vox_list),1);
                stat{ncue,nfreq,nroi,nmes}.fdr_p                        = zeros(length(vox_list),1);
                stat{ncue,nfreq,nroi,nmes}.fdr_mask                     = zeros(length(vox_list),1);

                stat{ncue,nfreq,nroi,nmes}.p_val(where_vox_are)         = all_p;
                stat{ncue,nfreq,nroi,nmes}.p_val_corr(where_vox_are)    = corrected_p;
                stat{ncue,nfreq,nroi,nmes}.mask(where_vox_are)          = corrected_h;
                stat{ncue,nfreq,nroi,nmes}.stat(where_vox_are)          = all_stat_zval;
                stat{ncue,nfreq,nroi,nmes}.fdr_p(where_vox_are)         = fdr_adj_p;
                stat{ncue,nfreq,nroi,nmes}.fdr_mask(where_vox_are)      = fdr_h;
                

            end
        end
    end
end

clearvars -except source_gavg list_* *_list stat

load ../data_fieldtrip/template/template_grid_0.5cm.mat

for ncue = 1:length(list_cue)
    for nfreq = 1:length(list_freq)
        for nroi = 1:length(list_roi)
            for nmes = 1:length(list_mesure)
                
                for iside = [1 2]
                    
                    lst_side                = {'left','right','both','left','right'};
                    lst_view                = [-95 1;95 1;0 88; 88 -2; -88 -2];
                    
                    z_lim                   = 5;
                    
                    clear source ;
                    
                    stolplot                = stat{ncue,nfreq,nroi,nmes};
                    
                    source.pos              = template_grid.pos ;
                    source.dim              = template_grid.dim ;
                    
                    tpower                  = stolplot.stat .* stolplot.mask; % stolplot.fdr_mask ; % stolplot.mask; % 
                    
                    tpower(tpower == 0)     = NaN;
                    source.pow              = tpower ; clear tpower;
                    
                    cfg                     =   [];
                    cfg.method              =   'surface';
                    cfg.funparameter        =   'pow';
                    cfg.funcolorlim         =   [-z_lim z_lim];
                    cfg.opacitylim          =   [-z_lim z_lim];
                    cfg.opacitymap          =   'rampup';
                    cfg.colorbar            =   'off';
                    cfg.camlight            =   'no';
                    %                     cfg.projthresh          =   0.2;
                    cfg.projmethod          =   'nearest';
                    cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
                    cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
                    
                    ft_sourceplot(cfg, source);
                    view(lst_view(iside,:))
                    
                    title([list_cue{ncue} '.' list_freq{nfreq} '.' list_roi{nroi} '.' list_mesure{nmes}]);

                    
                end
            end
        end
    end
end      