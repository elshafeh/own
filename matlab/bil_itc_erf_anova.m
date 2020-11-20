clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

if isunix
    project_dir                     = '/project/3015079.01/';
    start_dir                       = '/project/';
else
    project_dir                     = 'P:/3015079.01/';
    start_dir                       = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                  	= suj_list{nsuj};
    list_cue                        = {'cuelock'};
    
    for ncue = 1:length(list_cue)
        for nbin = 1:5
            
            fname               	= [project_dir 'data/' subjectName '/erf/' subjectName '.' list_cue{ncue} '.itc.withcorrect.bin' num2str(nbin) '.erf.mat'];
            fprintf('loading %s\n',fname);
            load(fname);
            
            t1                    	= find(round(avg_comb.time,2) == round(-0.11,2));
            t2                  	= find(round(avg_comb.time,2) == round(0.01,2));
            
            bsl                  	= mean(avg_comb.avg(:,t1:t2),2);
            avg_comb.avg         	= avg_comb.avg - bsl ; clear bsl t1 t2;
            alldata{nsuj,nbin,ncue}	= avg_comb; clear avg_comb;
            
            
        end
    end
    
    fprintf('\n');
    
end

keep alldata list_*; clc ;

%%

nsuj                                = size(alldata,1);
[design,neighbours]                 = h_create_design_neighbours(nsuj,alldata{1,1},'meg','t'); clc;

cfg                                 = [];
cfg.method                          = 'ft_statistics_montecarlo';
cfg.statistic                       = 'ft_statfun_depsamplesFmultivariate';
cfg.correctm                        = 'cluster';
cfg.clusteralpha                    = 0.05;
cfg.clusterstatistic                = 'maxsum';
cfg.clusterthreshold                = 'nonparametric_common';
cfg.tail                            = 1; % For a F-statistic, it only make sense to calculate the right tail
cfg.clustertail                     = cfg.tail;
cfg.alpha                           = 0.05;
cfg.computeprob                     = 'yes';
cfg.numrandomization                = 1000;
cfg.neighbours                      = neighbours;

cfg.minnbchan                       = 3; % !!
cfg.alpha                           = 0.025;

cfg.numrandomization                =  1000;
cfg.design                          = design;

design                              = zeros(2,5*nsuj);
design(1,1:nsuj)                    = 1;
design(1,nsuj+1:2*nsuj)             = 2;
design(1,nsuj*2+1:3*nsuj)           = 3;
design(1,nsuj*3+1:4*nsuj)           = 4;
design(1,nsuj*4+1:5*nsuj)           = 5;
design(2,:)                         = repmat(1:nsuj,1,5);

cfg.design                          = design;
cfg.ivar                            = 1; % condition
cfg.uvar                            = 2; % subject number

cfg.latency                         = [-0.1 5.5];

for ncue = 1:size(alldata,3)
    stat{ncue}                      = ft_timelockstatistics(cfg, alldata{:,1,ncue},alldata{:,2,ncue},alldata{:,3,ncue},alldata{:,4,ncue},alldata{:,5,ncue});
end

keep stat alldata list_*

%%

nrow                                = 2;
ncol                                = 2;
i                                   = 0;

for ncue = 1:length(stat)
    
    stoplot                         = [];
    stoplot.time                    = stat{ncue}.time;
    stoplot.label                   = stat{ncue}.label;
    stoplot.dimord                  = 'chan_time';
    stoplot.avg                     = squeeze(stat{ncue}.stat .* stat{ncue}.mask);
    
    list_topo                    	= {'*Reds','*Blues'};
    
    if length(unique(stoplot.avg)) > 1
        
        i                           = i + 1;
        subplot(nrow,ncol,i)
        
        cfg                         = [];
        cfg.layout                  = 'CTF275_helmet.mat';
        cfg.marker                  = 'off';
        cfg.comment                 = 'no';
        cfg.colorbar                = 'no';
        cfg.colormap                = brewermap(256, list_topo{ncue});
        %         cfg.ylim                    = 'zeromax';
        ft_topoplotER(cfg,stoplot);
        
        %         i = i +1;
        %         subplot(nrow,ncol,i)
        %         plot(stoplot.time,nanmean(stoplot.avg,1),'-m','LineWidth',2);
        %         xticks([0 1.5 3 4.5]);
        %         xticklabels({'1st cue','1st gab','2nd cue','2nd gab'});
        %         vline([0 1.5 3 4.5],'--k');
        %         xlim(stoplot.time([1 end]));
        
        i = i +1;
        subplot(nrow,ncol,i)
        
        list_chan           	= {'MLO11','MLP31','MLP51','MLP52','MRO11','MRP31','MRP51','MRP52','MZO01','MZP01'};
        
        cfg                     = [];
        cfg.channel             = list_chan;
        cfg.time_limit          = stat{ncue}.time([1 end]);
        cfg.color               = {'-b' '-r'};
        cfg.z_limit             = [-0.1e-13 1.8e-13];
        cfg.linewidth           = 5;
        subplot(nrow,ncol,i);
        h_plotSingleERFstat_selectChannel_nobox(cfg,stat{ncue},squeeze(alldata(:,[1 5],ncue)));
        hline(0,'--k');
        xticks([0 1.5 3 4.5 5.5]);
        xticklabels({'1st cue','1st gab','2nd cue','2nd gab','RT'});
        vline([0 1.5 3 4.5 5.5],'--k');
        
    end
end

% cfg                         = [];
% cfg.channel                 = list_chan;
% nw_stat                     = ft_selectdata(cfg,stat{ncue});clc;
%
% data_plot                   = [];
%
% for nsuj = 1:size(alldata,1)
%     for nbin = 1:size(alldata,2)
%
%         cfg                 = [];
%         cfg.channel      	= list_chan;
%         cfg.latency     	= stat{ncue}.time([1 end]);
%         tmp                 = ft_selectdata(cfg,alldata{nsuj,nbin});
%
%         tmp                 = tmp.avg .* squeeze(nw_stat.mask);
%         tmp(tmp == 0)       = NaN;
%         tmp                 = nanmean(nanmean(tmp));
%
%         data_plot(nsuj,nbin,:)  = tmp; clear tmp;
%
%     end
% end

% mean_data               	= nanmean(data_plot,1);
% bounds                   	= nanstd(data_plot, [], 1);
% bounds_sem              	= bounds ./ sqrt(size(data_plot,1));
%
% errorbar(mean_data,bounds_sem,'-ms');
%
% xlim([0 6]);
%         ylim([0 0.1]);
% xticks([1 2 3 4 5]);
%
% [h2,p2]                 	= ttest(data_plot(:,1),data_plot(:,2));
% [h3,p3]                     = ttest(data_plot(:,1),data_plot(:,3));
% [h4,p4]                     = ttest(data_plot(:,1),data_plot(:,4));
% [h5,p5]                     = ttest(data_plot(:,1),data_plot(:,5));
%
% [h6,p6]                  	= ttest(data_plot(:,2),data_plot(:,3));
% [h7,p7]                 	= ttest(data_plot(:,2),data_plot(:,4));
% [h8,p8]                     = ttest(data_plot(:,2),data_plot(:,5));
%
% [h9,p9]                     = ttest(data_plot(:,3),data_plot(:,4));
% [h10,p10]               	= ttest(data_plot(:,3),data_plot(:,5));
%
% [h11,p11]                  	= ttest(data_plot(:,4),data_plot(:,5));
%
% list_group                  = {[1 2],[1 3],[1 4],[1 5],[2 3],[2 4],[2 5],[3 4],[3 5],[4 5]};
% list_p                      = [p2 p3 p4 p5 p6 p7 p8 p9 p10 p11];