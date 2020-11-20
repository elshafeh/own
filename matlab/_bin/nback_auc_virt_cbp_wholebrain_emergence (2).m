clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load suj_list_peak.mat

list_freq                                                       = {'alpha1Hz.virt.demean','beta3Hz.virt.demean'};
list_condition                                                  = {'0Ball','1Ball','2Ball' };

for n_suj = 1:length(suj_list)
    for n_freq = 1:length(list_freq)
        for n_con = 1:length(list_condition)
            
            fname                                               = ['../data/decode_data/virt/sub' num2str(suj_list(n_suj)) '.' list_condition{n_con} '.' list_freq{n_freq}];
            fname                                               = [fname '.auc.bychan.mat'];
            
            fprintf('loading %s\n',fname);
            load(fname);
            
            time_window                                         = 0.1;
            list_time                                           = 0:time_window:5;
            list_time_name                                      = {}; 
            
            for n_time = 1:length(list_time)-1
                
                list_time_name{n_time}                          = ['p' num2str(list_time(n_time)*1000) 'p' num2str((list_time(n_time)+time_window)*1000)];
                
                ix1                                             = find(round(time_axis,2) == list_time(n_time));
                ix2                                             = find(round(time_axis,2) == list_time(n_time)+time_window);
                pow                                             = mean(scores(:,ix1:ix2),2);
                
                source                                          = h_towholebrain(pow,'../data/template/brainnetome_roi1cm.mat','../data/template/template_grid_1cm.mat');
                alldata{n_suj,n_con,n_time,n_freq}              = source; clear source tmp;
                
            end
        end
    end
end

keep alldata list_*

cfg                                 =   [];
cfg.dim                             =   alldata{1}.dim;
cfg.method                          =   'montecarlo';
cfg.statistic                       =   'depsamplesT';
cfg.parameter                       =   'pow';
cfg.correctm                        =   'cluster';
cfg.clusteralpha                    =   0.05;  % First Threshold
cfg.clusterstatistic                =   'maxsum';
cfg.numrandomization                =   1000;
cfg.alpha                           =   0.025;
cfg.tail                            =   0;
cfg.clustertail                     =   0;

nsuj                                =   size(alldata,1);
cfg.design(1,:)                     =   [1:nsuj 1:nsuj];
cfg.design(2,:)                     =   [ones(1,nsuj) ones(1,nsuj)*2];
cfg.uvar                            =   1;
cfg.ivar                            =   2;

for n_con = 1:length(list_condition)
    for n_time = 1:length(list_time_name)
        
        stat{n_con,n_time}                          =   ft_sourcestatistics(cfg, alldata{:,n_con,n_time,1},...
            alldata{:,n_con,n_time,2});
        
        [min_p(n_con,n_time),p_val{n_con,n_time}]  	= h_pValSort(stat{n_con,n_time});

        
    end
end

keep keep alldata list_* stat min_p p_val

for n_con = 1:length(list_condition)
    for n_time = 1:length(list_time_name)
        
        if min_p(n_con,n_time) < 0.05
            
            stolplot                            = stat{n_con,n_time};
            stolplot.mask                       = stolplot.prob < 0.05;
            
            source.pos                          = stolplot.pos ;
            source.dim                          = stolplot.dim ;
            tpower                              = stolplot.stat .* stolplot.mask;
            tpower(tpower == 0)                 = NaN;
            source.pow                          = tpower ; clear tpower;
            
            z_lim                               = 3;
            
            cfg                                 = [];
            cfg.method                          = 'surface';
            cfg.funparameter                    = 'pow';
            cfg.funcolorlim                     = [-z_lim z_lim];
            cfg.opacitylim                      = [-z_lim z_lim];
            cfg.opacitymap                      = 'rampup';
            cfg.colorbar                        = 'off';
            cfg.camlight                        = 'no';
            cfg.projmethod                      = 'nearest';
            cfg.surffile                        = 'surface_white_both.mat';
            cfg.surfinflated                    =  'surface_inflated_both_caret.mat';
            ft_sourceplot(cfg, source);
            
            title([list_condition{n_con} ' ' list_time_name{n_time}]);
            
        end
    end
end