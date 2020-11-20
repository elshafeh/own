clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                          	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    list_nback                      = [0 1 2];
    list_cond                       = {'0back','1back','2Back'};
    list_color                      = 'rgb';
    
    list_cond                       = list_cond(list_nback+1);
    list_color                      = list_color(list_nback+1);
    
    for ncond = 1:length(list_nback)
        
        list_lock                   = {'target.dwn70'}; % 
        avg_data                    = [];
        i                           = 0;
        
        for nlock = 1:length(list_lock)
            
            file_list             	= dir(['J:/temp/nback/data/sens_level_auc/cond/sub' num2str(suj_list(nsuj)) '.decoding.' list_cond{ncond} ...
                '.agaisnt.all.lockedon.' list_lock{nlock} '.bsl.excl.auc.mat']);
            
            tmp                     = [];
            
            for nf = 1:length(file_list)
                fname               = [file_list(nf).folder filesep file_list(nf).name];
                fprintf('loading %s\n',fname);
                load(fname);
                tmp                 = [tmp;scores]; clear scores;
            end
            
            avg_data(nlock,:)       = mean(tmp,1); clear tmp;
            
        end
        
        avg                       	= [];
        avg.time               		= time_axis;
        avg.label                   = list_lock;
        avg.avg                   	= avg_data; clear avg_data;
        avg.dimord              	= 'chan_time';
        
        alldata{nsuj,ncond}      	= avg; clear avg pow;
        
    end
end

keep alldata list_*

keep alldata list_cond;

nbsuj                       = size(alldata,1);
[~,neighbours]              = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg                         = [];
cfg.method                  = 'ft_statistics_montecarlo';
cfg.statistic               = 'ft_statfun_depsamplesFmultivariate';
cfg.correctm                = 'cluster';
cfg.clusteralpha            = 0.05;
cfg.clusterstatistic        = 'maxsum'; %'maxsum', 'maxsize', 'wcm'
cfg.clusterthreshold        = 'nonparametric_common';
cfg.tail                     = 1; % For a F-statistic, it only make sense to calculate the right tail
cfg.clustertail             = cfg.tail;
cfg.alpha                   = 0.05;
cfg.computeprob             = 'yes';
cfg.numrandomization        = 1000;
cfg.neighbours              = neighbours;
cfg.latency                 = [-0.1 2];
design                      = zeros(2,3*nbsuj);
design(1,1:nbsuj)           = 1;
design(1,nbsuj+1:2*nbsuj)   = 2;
design(1,nbsuj*2+1:3*nbsuj) = 3;
design(2,:) = repmat(1:nbsuj,1,3);
cfg.design                  = design;
cfg.ivar                    = 1; % condition
cfg.uvar                    = 2; % subject number

stat                        = ft_timelockstatistics(cfg, alldata{:,1}, alldata{:,2}, alldata{:,3});
[min_p,p_val]               = h_pValSort(stat);

save(['../data/stat/anova/nback.cond.ag.all.broadband.mat'],'stat');

figure;
nrow                     	= 2;
ncol                     	= 3;

cfg                         = [];
cfg.channel                 = stat.label{1};
cfg.p_threshold             = 0.05;
cfg.z_limit                 = [0.48 0.8];
cfg.time_limit              = stat.time([1 end]);
cfg.color                   = 'rgb';
cfg.linewidth               = 10;
subplot(nrow,ncol,1);
h_plotSingleERFstat_selectChannel_nobox(cfg,stat,alldata);
vline(0,'-k');
hline(0.5,'-k');
xticks([0:0.4:2]);
title('broadband');

if length(unique(stat.mask)) > 1
    
    i                           = 1;
    
    cluster_list                = {[1 2 3]}; %
    
    for ncluster = 1:length(cluster_list)
        
        find_cluster                            = [];
        for ni = 1:length(cluster_list{ncluster})
            find_cluster                        = [find_cluster find(stat.posclusterslabelmat == cluster_list{ncluster}(ni))];
        end
        
        find_cluster                            = sort(find_cluster);
        chk_sig                                 = find(stat.mask(find_cluster)==1);
        
        tm_points                               = stat.time(find_cluster);
        tim_indx_in_data                        = [];
        
        for nt = 1:length(tm_points)
            tim_indx_in_data = [tim_indx_in_data; find(alldata{1,1}.time == tm_points(nt))];
        end
        
        if ~isempty(chk_sig)
            
            i                                   = i+1;
            time_win                            = find_cluster([1 end]);
            data_plot                           = [];
            
            for nsub = 1:size(alldata,1)
                for ncond = 1:size(alldata,2)
                    data_plot(nsub,ncond)       = mean(alldata{nsub,ncond}.avg(1,tim_indx_in_data),2);
                end
            end
            
            mean_data                           = nanmean(data_plot,1);
            bounds                              = nanstd(data_plot, [], 1);
            bounds_sem                          = bounds ./ sqrt(size(data_plot,1));
            
            [h1,p1]                           	= ttest2(data_plot(:,1),data_plot(:,2),'Tail','both');
            [h2,p2]                           	= ttest2(data_plot(:,1),data_plot(:,3),'Tail','both');
            [h3,p3]                           	= ttest2(data_plot(:,2),data_plot(:,3),'Tail','both');
            
            subplot(nrow,ncol,i);
            errorbar(mean_data,bounds_sem,'-ks');
            
            title([num2str(round(tm_points(1),2)) '-' num2str(round(tm_points(2),2)) ' p0v1= ' num2str(round(p1,5)) '  p0v2= ' num2str(round(p2,5)) '  p1v2= ' num2str(round(p3,5))]);
            
            xlim([0 4]);
            xticks([1 2 3]);
            xticklabels(list_cond);
            
            ylim([0.48 0.8]);
            yticks([0.48 0.8]);
            
        end
        
    end
    
end