clear ; clc ; close all;

addpath(genpath('../fieldtrip-20151124/'));
addpath('DrosteEffect-BrewerMap-b6a6efc/');

suj_list                = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj                 = ['yc' num2str(suj_list(sb))] ;
    
    list_cnd            = {'CnD'}; % {'NCnD','LCnD','RCnD'};
    
    %     list_mth            = {'KLD.SwPhAmp.DivMean.','MVL.SwPhAmp.DivMean.','HR.SwPhAmp.DivMean.','PhaSyn.SwPhAmp.DivMean.'};
    %     list_mth            = {'KLD.NoSurr.NoNorm.','MVL.NoSurr.NoNorm.','HR.NoSurr.NoNorm.','PhaSyn.NoSurr.NoNorm.','ndPAC.NoSurr.NoNorm.'};
    
    list_mth            = {'KLD.NoSurr.Zscore.','MVL.NoSurr.Zscore.','HR.NoSurr.Zscore.','PhaSyn.NoSurr.Zscore.','ndPAC.NoSurr.Zscore.'};
    
    list_tme            = {'m600m200','p600p1000'};
    
    for ntime = 1:length(list_tme)
        for nmethod = 1:length(list_mth)
            for ncue = 1:length(list_cnd)
                fname   = ['../data/prep21_pac/' suj '.' list_cnd{ncue} '.' list_tme{ntime} '.' ...
                    list_mth{nmethod} 'NonZTransMinEvokedSepTensorPac.mat'];
                
                fprintf('Loading %30s\n',fname);
                load(fname);
                
                transform_label                     = {'left AuX','right AuX'};
                transform_index                     = {1:10,11:20};
                
                sub_tmp                             = h_transform_freq(py_pac,transform_index,transform_label);
                
                allsuj_data{sb,ncue,nmethod,ntime}  = sub_tmp; clear sub_tmp ; clc;
                
            end
        end
    end
end

clearvars -except allsuj_data list_*

nsuj                    = size(allsuj_data,1);
[design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_data{1},'virt','t'); clc;
cfg                     = [];

cfg.latency             = [6 20];
cfg.frequency           = [40 110];

% cfg.avgoverfreq         = 'yes';
% cfg.avgovertime         = 'yes';

cfg.dim                 = allsuj_data{1}.dimord;
cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_depsamplesT';
cfg.parameter           = 'powspctrm';

cfg.correctm            = 'bonferroni';

cfg.numrandomization    = 1000;
cfg.alpha               = 0.025;
cfg.tail                = 0;
cfg.neighbours          = neighbours;
cfg.minnbchan           = 0;
cfg.design              = design;
cfg.uvar                = 1;
cfg.ivar                = 2;

ntest                   = 0;
list_test               = {};

for ncue = 1:size(allsuj_data,2)
    for nmethod = 1:size(allsuj_data,3)
        
        ntest                   = ntest + 1;
        stat{ntest}             = ft_freqstatistics(cfg,allsuj_data{:,ncue,nmethod,2}, allsuj_data{:,ncue,nmethod,1});
        list_test{ntest}        = [list_cnd{ncue} ' ' list_mth{nmethod}];
        
    end
end

clearvars -except allsuj_data list_* stat

who_seg     = {};
i           = 0;
p_limit     = 0.05;


clearvars -except allsuj_data list_* stat who_seg p_limit

figure;
i = 0;

for nchan = 1:2 % length(stat_to_plot.label)
    for ntest = 1:length(stat)
        
        stat_to_plot                = stat{ntest};
        [min_p,p_val]               = h_pValSort(stat_to_plot);
        
        if min_p < p_limit
            
            %         figure;
            
            i = i +1;
            
            subplot(2,5,i)
            
            stat_to_plot.mask           = stat_to_plot.prob < p_limit;
            [x_ax,y_ax,z_ax]            = size(stat_to_plot.stat);
            
            if y_ax == 1
                
                plot(stat_to_plot.time,squeeze(stat_to_plot.mask(nchan,:,:) .* stat_to_plot.stat(nchan,:,:)));
                ylim([-3 3]);
                xlim([stat_to_plot.time(1) stat_to_plot.time(end)])
                
            elseif z_ax == 1
                
                plot(stat_to_plot.freq,squeeze(stat_to_plot.mask(nchan,:,:) .* stat_to_plot.stat(nchan,:,:)));
                ylim([-3 3]);
                xlim([stat_to_plot.freq(1) stat_to_plot.freq(end)])
                
            else
                
                cfg                             = [];
                cfg.channel                     = nchan;
                cfg.parameter                   = 'stat';
                cfg.colorbar                    = 'no';
                cfg.maskparameter               = 'mask';
                cfg.maskalpha                   = 1;
                cfg.maskstyle                   = 'opacity';
                cfg.zlim                        = [-2 2];
                ft_singleplotTFR(cfg,stat_to_plot);
                
            end
            
            title([list_test{ntest} ' ' stat_to_plot.label{nchan}]);
            
            xlabel('Phase (Hz)');
            ylabel('Amplitude (Hz)');
            
            colormap(brewermap(256, '*RdYlBu'));
            
        end
    end
end


for ntest = 1:length(stat)
    
    [min_p,p_val]     = h_pValSort(stat{ntest});
    
    if min_p < p_limit
        
        i               = i + 1;
        
        who_seg{i,1}    = list_test{ntest};
        who_seg{i,2}    = min_p;
        who_seg{i,3}    = p_val;
        
    end
end