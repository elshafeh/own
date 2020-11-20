clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

if isunix
    project_dir                 = '/project/3015079.01/';
    start_dir                   = '/project/';
else
    project_dir                 = 'P:/3015079.01/';
    start_dir                   = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                 = suj_list{nsuj};
    fname                       = [project_dir 'data/' subjectName '/tf/' subjectName '.firstcuelock.1overf.orig.alphabetaPeak.' ...
        'm1000m0ms.mat'];
    load(fname);
    allpeaks(nsuj,1)            = [apeak_orig];
    allpeaks(nsuj,2)            = [bpeak_orig];
    
end

allpeaks(isnan(allpeaks(:,2)),2) 	= nanmean(allpeaks(:,2));

keep allpeaks suj_list project_dir

for nsuj = 1:length(suj_list)
    
    subjectName                 = suj_list{nsuj};
    pow                         = [];
    
    for nbin = 1:5
        
        fname                   = [project_dir 'data/' subjectName '/tf/' subjectName '.itc.withcorrect.bin' num2str(nbin) '.mtm.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        test_band               = 'beta';
        
        switch test_band
            case 'alpha'
                f_focus        	= allpeaks(nsuj,1);
                f_width        	= 1;
            case 'beta'
                f_focus     	= allpeaks(nsuj,2);
                f_width      	= 2;
        end
        
        f1      = find(round(freq_comb.freq) == round(f_focus-f_width));
        f2      = find(round(freq_comb.freq) == round(f_focus+f_width));
        
        pow(nbin,:,:)           = squeeze(nanmean(freq_comb.powspctrm(:,f1:f2,:),2));
        
    end
    
    bsl                         = squeeze(mean(pow,1));
    
    for nbin = 1:5
        avg                     = [];
        avg.time                = freq_comb.time;
        avg.label               = freq_comb.label;
        avg.dimord              = 'chan_time';
        avg.avg                 = squeeze(pow(nbin,:,:)) ./ bsl;
        alldata{nsuj,nbin}      = avg; clear avg;
    end
    
    keep alldata allpeaks suj_list nsuj project_dir
    
    fprintf('\n');
    
end

keep alldata ; clc ;

%%

nsuj                            = size(alldata,1);
[design,neighbours]             = h_create_design_neighbours(nsuj,alldata{1,1},'meg','t'); clc;

cfg                             = [];
cfg.method                      = 'ft_statistics_montecarlo';
cfg.statistic                   = 'ft_statfun_depsamplesFmultivariate';
cfg.correctm                    = 'cluster';
cfg.clusteralpha                = 0.05;
cfg.clusterstatistic            = 'maxsum';
cfg.clusterthreshold            = 'nonparametric_common';
cfg.tail                        = 1; % For a F-statistic, it only make sense to calculate the right tail
cfg.clustertail                 = cfg.tail;
cfg.alpha                       = 0.05;
cfg.computeprob                 = 'yes';
cfg.numrandomization            = 1000;
cfg.neighbours                  = neighbours;

cfg.minnbchan                   = 2; % !!
cfg.alpha                       = 0.025;

cfg.numrandomization            = 1000;
cfg.design                      = design;

design                          = zeros(2,5*nsuj);
design(1,1:nsuj)                = 1;
design(1,nsuj+1:2*nsuj)         = 2;
design(1,nsuj*2+1:3*nsuj)       = 3;
design(1,nsuj*3+1:4*nsuj)       = 4;
design(1,nsuj*4+1:5*nsuj)       = 5;
design(2,:)                     = repmat(1:nsuj,1,5);

cfg.design                      = design;
cfg.ivar                        = 1; % condition
cfg.uvar                        = 2; % subject number

cfg.latency                     = [0 4.5];

stat                            = ft_timelockstatistics(cfg, alldata{:,1},alldata{:,2},alldata{:,3},alldata{:,4},alldata{:,5});
stat                            = rmfield(stat,'cfg');

keep stat alldata

%%

nrow                          	= 3;
ncol                         	= 3;
i                               = 0;

stoplot                         = [];
stoplot.time                    = stat.time;
stoplot.label                   = stat.label;
stoplot.dimord                  = 'chan_time';
stoplot.avg                     = squeeze(stat.stat .* stat.mask);

if length(unique(stoplot.avg)) > 1
    
    i                           = i + 1;
    subplot(nrow,ncol,i)
    
    cfg                         = [];
    cfg.layout                  = 'CTF275_helmet.mat'; %'CTF275.lay';
    cfg.marker                  = 'off';
    cfg.comment                 = 'no';
    cfg.colorbar                = 'no';
    cfg.colormap                = brewermap(256, '*Purples');
    cfg.ylim                    = 'zeromax';
    ft_topoplotER(cfg,stoplot);
    
    i = i +1;
    subplot(nrow,ncol,i)
    plot(stoplot.time,nanmean(stoplot.avg,1),'-m','LineWidth',2);
    xticks([0 1.5 3 4.5]);
    xticklabels({'1st cue','1st gab','2nd cue','2nd gab'});
    vline([0 1.5 3 4.5],'--k');
    xlim(stoplot.time([1 end]));
    
    i = i +1;
    subplot(nrow,ncol,i)
    
    data_plot                   = [];
    
    for nsuj = 1:size(alldata,1)
        for nbin = 1:size(alldata,2)
            
            cfg                 = [];
            cfg.channel      	= {'MLO11','MLO12','MLO13','MLO14','MLO21', ...
                'MLO22','MLO23','MLO31','MLO32','MLO34', ...
                'MLO41','MLO42','MLO43','MLO44','MLO53','MLP11',... 
                'MLP21','MLP22','MLP31','MLP32','MLP33','MLP34',...
                'MLP41','MLP42','MLP43','MLP44','MLP51','MLP52',...
                'MLP53','MLP54','MLP55','MLP56','MLT16','MLT27',...
                'MLT57','MRO21','MRP11','MRP21','MRP51'};
            cfg.latency     	= stat.time([1 end]);
            tmp                 = ft_selectdata(cfg,alldata{nsuj,nbin});clc;
            nw_stat             = ft_selectdata(cfg,stat);clc;
            
            tmp                 = tmp.avg .* squeeze(nw_stat.mask);
            tmp(tmp == 0)       = NaN;
            tmp                 = nanmean(nanmean(tmp));
            
            data_plot(nsuj,nbin,:)  = tmp; clear tmp;
            
        end
    end
    
    mean_data               	= nanmean(data_plot,1);
    bounds                   	= nanstd(data_plot, [], 1);
    bounds_sem              	= bounds ./ sqrt(size(data_plot,1));
    
    errorbar(mean_data,bounds_sem,'-ms');
    
    xlim([0 6]);
    %         ylim([0 0.1]);
    xticks([1 2 3 4 5]);
    xticklabels({'Fastest','','Median','','Slowest'});
    
    [h2,p2]                 	= ttest(data_plot(:,1),data_plot(:,2));
    [h3,p3]                     = ttest(data_plot(:,1),data_plot(:,3));
    [h4,p4]                     = ttest(data_plot(:,1),data_plot(:,4));
    [h5,p5]                     = ttest(data_plot(:,1),data_plot(:,5));
    
    [h6,p6]                  	= ttest(data_plot(:,2),data_plot(:,3));
    [h7,p7]                 	= ttest(data_plot(:,2),data_plot(:,4));
    [h8,p8]                     = ttest(data_plot(:,2),data_plot(:,5));
    
    [h9,p9]                     = ttest(data_plot(:,3),data_plot(:,4));
    [h10,p10]               	= ttest(data_plot(:,3),data_plot(:,5));
    
    [h11,p11]                  	= ttest(data_plot(:,4),data_plot(:,5));
    
    list_group                  = {[1 2],[1 3],[1 4],[1 5],[2 3],[2 4],[2 5],[3 4],[3 5],[4 5]};
    list_p                      = [p2 p3 p4 p5 p6 p7 p8 p9 p10 p11];
    
end