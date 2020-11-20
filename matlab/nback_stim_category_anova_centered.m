clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                            = [1:33 35:36 38:44 46:51];
allpeaks                            = [];

for nsuj = 1:length(suj_list)
    load(['J:/temp/nback/data/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.mat']);
    allpeaks(nsuj,1)                = apeak; clear apeak;
    allpeaks(nsuj,2)                = bpeak; clear bpeak;
end

allpeaks(isnan(allpeaks(:,2)),2)  	= nanmean(allpeaks(:,2));

keep suj_list allpeaks

for nsuj = 1:length(suj_list)
    
    list_nback                   	= [0 1 2];
    list_cond                       = {'0back','1back','2Back'};
    list_color                      = 'rgb';
    
    list_cond                       = list_cond(list_nback+1);
    list_freq                       = 1:30;
    
    for nback = 1:length(list_nback)
        
        list_lock                   = {'istarget'};
        pow                         = [];
        
        for nlock = 1:length(list_lock)
            for nfreq = 1:length(list_freq)
                
                file_list         	= dir(['J:/temp/nback/data/sens_level_auc/cond/sub' num2str(suj_list(nsuj)) '.sess*.' ...
                    num2str(list_nback(nback)) 'back.' num2str(list_freq(nfreq)) 'Hz.' list_lock{nlock} '.bsl.dwn70.excl.auc.mat']);
                
                tmp              	= [];
                
                if isempty(file_list)
                    error('file not found!');
                end
                
                for nf = 1:length(file_list)
                    fname         	= [file_list(nf).folder filesep file_list(nf).name];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    tmp           	= [tmp;scores]; clear scores;
                end
                
                pow(nlock,nfreq,:) 	= nanmean(tmp,1); clear tmp;
                
            end
        end
        
        list_name                   = {'alpha peak'};
        list_peak                   = [allpeaks(nsuj,1)];
        list_width                  = [1];
        
        %         list_name                   = {'beta peak'};
        %         list_peak                   = [allpeaks(nsuj,2)];
        %         list_width                  = [2];
        
        list_final                  = {};
        tmp                         = [];
        
        for np = 1:length(list_peak)
            
            xi                      = find(round(list_freq) == round(list_peak(np) - list_width(np)));
            yi                      = find(round(list_freq) == round(list_peak(np) + list_width(np)));
            
            zi                      = squeeze(pow(:,xi:yi,:)); clear xi yi;
            
            if size(zi,3) == 1
                tmp                 = [tmp; squeeze(nanmean(zi,1))];
            else
                tmp                 = [tmp;squeeze(nanmean(zi,2))];
            end
            
            clear zi;
            
            for luc = 1:length(list_lock)
                list_final{end+1}    = [list_name{np} ' ' list_lock{luc}];
            end
            
        end
        
        avg                         = [];
        avg.label                   = list_final; clear list_final
        avg.avg                     = tmp; clear tmp;
        avg.dimord                  = 'chan_time';
        avg.time                    = -1.5:0.02:2;
        
        alldata{nsuj,nback}         = avg; clear avg;
        
    end
end

keep alldata list_*;

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
title(list_name{1});

if length(unique(stat.mask)) > 1
    
    i                           = 1;
    
    cluster_list                = {[1 2],3};
    
    for ncluster = 1:length(cluster_list)
        
        find_cluster                            = [];
        for ni = 1:length(cluster_list{ncluster})
            find_cluster                        = [find_cluster find(stat.posclusterslabelmat == cluster_list{ncluster}(ni))];
        end
        
        find_cluster                            = sort(find_cluster);
        chk_sig                                 = find(stat.mask(find_cluster)==1);
        
        if ~isempty(chk_sig)
            
            i                                   = i+1;
            time_win                            = find_cluster([1 end]);
            data_plot                           = [];
            
            for nsub = 1:size(alldata,1)
                for ncond = 1:size(alldata,2)
                    data_plot(nsub,ncond)       = mean(alldata{nsub,ncond}.avg(1,time_win),2);
                end
            end
            
            mean_data                           = nanmean(data_plot,1);
            bounds                              = nanstd(data_plot, [], 1);
            bounds_sem                          = bounds ./ sqrt(size(data_plot,1));
            
            subplot(nrow,ncol,i);
            errorbar(mean_data,bounds_sem,'-ks');
            
            xlim([0 4]);
            xticks([1 2 3]);
            xticklabels(list_cond);
            
            ylim([0.48 0.8]);
            yticks([0.48 0.8]);
            
        end
        
    end
    
end