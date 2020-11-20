clear;clc;
addpath('../toolbox/sigstar-master/');

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:30 %length(suj_list)
    
    subjectName             = suj_list{nsuj};
    
    frequency_list          = {'theta' 'alpha' 'beta' 'gamma'};
    
    decoding_list           = {'freq' 'ori'};
    cue_list                = {'pre.freq' 'pre.ori' 'retro.freq' 'retro.ori'};
    
    lock_list               = {'1stgab'}; % '2ndgab'};
    
    for nfreq = 1:length(frequency_list)
        for ncue = 1:length(cue_list)
            
            avg                 = [];
            avg.avg             = [];
            avg.label           = {};
            
            for nlock = 1:length(lock_list)
                for ndeco = 1:length(decoding_list)
                    % load files for both gabors
                    fname 	= ['F:/bil/decode/' subjectName '.1stcue.lock.' frequency_list{nfreq} ...
                        '.centered.cue.' cue_list{ncue}  '.decoding.' lock_list{nlock} '.' decoding_list{ndeco} '.correct.ninjauc.mat'];
                    
                    fprintf('loading %s\n',fname);
                    load(fname);
                    avg.avg     = [avg.avg;scores]; clear sources;
                    
                    avg.label 	= [avg.label [lock_list{nlock} ' ' decoding_list{ndeco}]];
                    
                end
            end
            
            avg.dimord 	= 'chan_time';
            avg.time   	= time_axis;
            
            alldata{nsuj,nfreq,ncue}         = avg; clear avg;
            
            
        end
    end
end

keep alldata list* *list

% compute anova

for nfreq = 1:size(alldata,2)
    
    nbsuj                               = size(alldata,1);
    [~,neighbours]                      = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');
    
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
    
    cfg.latency                         = [-0.2 6];
    cfg.minnbchan                       = 0;
    
    design(1,1:nbsuj)                   = 1;
    design(1,nbsuj+1:2*nbsuj)           = 2;
    design(1,nbsuj*2+1:3*nbsuj)         = 3;
    design(1,nbsuj*3+1:4*nbsuj)         = 4;
    design(2,:)                         = repmat(1:nbsuj,1,4);
    
    cfg.design                          = design;
    cfg.ivar                            = 1; % condition
    cfg.uvar                            = 2; % subject number
    
    stat{nfreq}                         = ft_timelockstatistics(cfg, alldata{:,nfreq,1}, alldata{:,nfreq,2}, alldata{:,nfreq,3}, alldata{:,nfreq,4});
    
end

close all;
figure;
i                                       = 0;
nrow                                    = 5;
ncol                                    = 5;

for nfreq = 1:length(stat)
    
    s_focus     = stat{nfreq};
    chk         = length(unique(s_focus.mask .* s_focus.stat));
    data_focus  = squeeze(alldata(:,nfreq,:));
    
    if chk > 1
        
        for nchan = 1:length(s_focus.label)
            
            zlimit                          = [0.46 0.7];
            
            cfg                             = [];
            cfg.channel                     = nchan;
            cfg.time_limit                  = s_focus.time([1 end]);
            cfg.color                       = 'kbmr';
            cfg.z_limit                     = zlimit;
            cfg.linewidth                   = 10;
            
            i = i+1;
            subplot(nrow,ncol,i);
            h_plotSingleERFstat_selectChannel_nobox(cfg,s_focus,data_focus);
            ylabel(s_focus.label{nchan});
            
            vline([0 1.5 3 4.5 5.5],'--k');
            xticklabels({'1st Cue' '1st G' '2nd Cue' '2nd G' 'RT'});
            xticks([0 1.5 3 4.5 5.5]);
            hline(0.5,'--k');
            
            title(frequency_list{nfreq});
            
            chk_sig                         = s_focus.mask .* s_focus.stat;
            chk_sig                         = chk_sig(nchan,:);
            
            if length(unique(chk_sig)) > 1
                
                chk_clust_mat               = s_focus.mask .* s_focus.posclusterslabelmat;
                chk_clust_mat               = chk_clust_mat(nchan,:);
                
                clust_nmbr                  = unique(chk_clust_mat(chk_clust_mat>0));
                
                for ncluster = 1:length(clust_nmbr)
                    
                    tmp_mat                 = chk_clust_mat;
                    
                    tmp_mat(tmp_mat ~= clust_nmbr(ncluster)) = 0;
                    tmp_mat(tmp_mat == clust_nmbr(ncluster)) = 1;
                    
                    for nsub = 1:size(data_focus,1)
                        for ncond = 1:size(data_focus,3)
                            t1              = find(round(data_focus{nsub,ncond}.time,2) == round(s_focus.time(1),2));
                            t2              = find(round(data_focus{nsub,ncond}.time,2) == round(s_focus.time(end),2));
                            tmp_data        = data_focus{nsub,ncond}.avg(nchan,[t1:t2]);
                            tmp_data        = tmp_data .* tmp_mat;
                            tmp_data(tmp_data == 0) = NaN;
                            data_plot(nsub,ncond)       = nanmean(tmp_data);
                        end
                    end
                    
                    [h1,p1]                   	= ttest(data_plot(:,1),data_plot(:,2));
                    [h2,p2]                    	= ttest(data_plot(:,1),data_plot(:,3));
                    [h3,p3]                   	= ttest(data_plot(:,1),data_plot(:,4));
                    [h4,p4]                   	= ttest(data_plot(:,2),data_plot(:,3));
                    [h5,p5]                   	= ttest(data_plot(:,2),data_plot(:,4));
                    [h6,p6]                   	= ttest(data_plot(:,3),data_plot(:,4));
                    
                    mean_data               	= nanmean(data_plot,1);
                    bounds                    	= nanstd(data_plot, [], 1);
                    bounds_sem                	= bounds ./ sqrt(size(data_plot,1));
                    
                    i = i + 1;
                    subplot(nrow,ncol,i);
                    errorbar(mean_data,bounds_sem,'-ks');
                    
                    xlim([0 size(data_focus,2)+1]);
                    xticks([1:size(data_focus,2)]);
                    
                    xticklabels(cue_list);
                    
                    hline(0.5,'--k');
                    ylim(zlimit);
                    yticks(zlimit);
                    ylabel({[s_focus.label{nchan} ' #' num2str(ncluster)] [' ' num2str(round(tmp_time(t_find(1)),2)) ' - ' num2str(round(tmp_time(t_find(end)),2))]})
                    
                    %             list_group                          = {[1 2],[1 3],[1 4],[2 3],[2 4],[3 4]};
                    %             sigstar(list_group,p_val)
                    
                end
            end
        end
    end
end