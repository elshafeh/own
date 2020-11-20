clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_list       = [1:4 8:17];

suj_list                = [1:4 8:17];

for ngroup = 1
    for sb = 1:length(suj_list)
        
        suj                 = ['yc' num2str(suj_list(sb))] ;
        
        list_cnd            = {'RCnD','LCnD','NCnD'};
        
        list_mth            = {'KLD','MVL','ndPAC','HR','PhaSyn'};
        
        list_tme            = {'m600m200','p600p1000'};
        
        for ncue = 1:length(list_cnd)
            for nmethod = 1:length(list_mth)
                for ntime = 1:length(list_tme)
                    
                    fname   = ['../data/paper_data/' suj '.' list_cnd{ncue} '.' list_tme{ntime} '.' ...
                        list_mth{nmethod} '.NoSurr.NoNorm.SameFreqNonZTransMinEvokedSepTensorPac.mat'];
                    
                    fprintf('Loading %30s\n',fname);
                    load(fname);
                    
                    transform_label                     = {'Left Aud','Right _Aud'};
                    transform_index                     = {1:10,11:20};
                    
                    sub_tmp{ntime}                      = h_transform_freq(py_pac,transform_index,transform_label);
                    
                end
                
                allsuj_data{ngroup}{sb,ncue,nmethod}                = sub_tmp{1};
                allsuj_data{ngroup}{sb,ncue,nmethod}.powspctrm      = (sub_tmp{2}.powspctrm - sub_tmp{1}.powspctrm)./sub_tmp{1}.powspctrm; clear sub_tmp;
                
            end
        end
    end
end

clearvars -except allsuj_data list_*

nsuj                    = size(allsuj_data{1},1);
[design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_data{1}{1},'virt','t'); clc;

cfg                     = [];
cfg.latency             = [7 15];

cfg.frequency           = [60 100];
cfg.avgoverfreq         = 'yes';

cfg.dim                 = allsuj_data{1}{1}.dimord;
cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_depsamplesT';
cfg.parameter           = 'powspctrm';
cfg.correctm            = 'cluster';

cfg.numrandomization    = 1000;
cfg.alpha               = 0.025;
cfg.tail                = 0;
cfg.neighbours          = neighbours;
cfg.minnbchan           = 0;
cfg.design              = design;
cfg.uvar                = 1;
cfg.ivar                = 2;

ix_test                 = [1 2; 1 3; 2 3];
itot                    = 0;
list_test               = {};

for ngroup = 1:length(allsuj_data)
    for nmethod = 1:length(list_mth)
        for ntest = 1:size(ix_test,1)
            
            itot                    = itot + 1;
            stat{itot}              = ft_freqstatistics(cfg,allsuj_data{ngroup}{:,ix_test(ntest,1),nmethod}, allsuj_data{ngroup}{:,ix_test(ntest,2),nmethod});
            list_test{itot}         = [list_mth{nmethod} ' '  list_cnd{ix_test(ntest,1)} 'v' list_cnd{ix_test(ntest,2)}];
            
        end
    end
end

p_limit = 0.5;

for ntest = 1:length(stat)
    
    stat_to_plot                = stat{ntest};
    [min_p,p_val]               = h_pValSort(stat_to_plot);
    
    if min_p < p_limit
        
        figure;
        
        for nchan = 1:length(stat_to_plot.label)
            
            subplot(2,1,nchan)
            
            stat_to_plot.mask   = stat_to_plot.prob < p_limit;
            [x_ax,y_ax,z_ax]    = size(stat_to_plot.stat);
            
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
                cfg.maskstyle                   = 'outline';
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