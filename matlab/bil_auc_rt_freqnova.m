clear;clc;
addpath('../toolbox/sigstar-master/');

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                     = suj_list{nsuj};
    
    frequency_list                  = {'theta' 'alpha' 'beta' 'gamma'};
    decoding_list                   = {'rt'};
    
    for nfreq = 1:length(frequency_list)
        
        avg                         = [];
        avg.avg                     = [];
        
        lock_focus                  =  '1stcue'; %
        
        for ndeco = 1:length(decoding_list)
            
            % load files for both gabors
            flist                   = dir(['F:/bil/decode/' subjectName '.' lock_focus '.lock.' frequency_list{nfreq} ...
                '.centered.decodingresp.' decoding_list{ndeco}  '.auc.mat']);
            
            if length(flist )== 1
                score_concat            = [];
                
                for nf = 1:length(flist)
                    fname             	= [flist(nf).folder filesep flist(nf).name];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    score_concat        = [score_concat;scores]; clear scores;
                end
            else
                error('files missing');
            end
            
            avg.avg                 = [avg.avg;nanmean(score_concat,1)];clear score_concat;
        end
        
        avg.label               	= decoding_list;
        avg.dimord                  = 'chan_time';
        avg.time                	= time_axis;
        
        alldata{nsuj,nfreq}         = avg; clear avg;
        
    end
    
    alldata{nsuj,5}                 = alldata{nsuj,1};
    rnd_vct                         = 0.495:0.0001:0.505;
    
    for nc = 1:size(alldata{nsuj,5}.avg,1)
        for nt = 1:size(alldata{nsuj,5}.avg,2)
            alldata{nsuj,5}.avg(nc,nt)    	= rnd_vct(randi(length(rnd_vct)));
        end
    end
    
    frequency_list                  = {'theta' 'alpha' 'beta' 'gamma' 'chance'};
    
end

keep alldata *_list lock_focus

% compute anova
nbsuj                       = size(alldata,1);
[~,neighbours]              = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg                         = [];
cfg.method                  = 'ft_statistics_montecarlo';
cfg.statistic               = 'ft_statfun_depsamplesFmultivariate';
cfg.correctm                = 'cluster';
cfg.clusteralpha            = 0.05;
cfg.clusterstatistic        = 'maxsum';
cfg.clusterthreshold        = 'nonparametric_common';
cfg.tail                 	= 1; % For a F-statistic, it only make sense to calculate the right tail
cfg.clustertail             = cfg.tail;
cfg.alpha                   = 0.05;
cfg.computeprob             = 'yes';
cfg.numrandomization        = 5000;
cfg.neighbours              = neighbours;
cfg.latency                 = [-0.2 6.5];

cfg.minnbchan               = 0;

if size(alldata,2) == 4
    design(1,1:nbsuj)     	= 1;
    design(1,nbsuj+1:2*nbsuj)   = 2;
    design(1,nbsuj*2+1:3*nbsuj) = 3;
    design(1,nbsuj*3+1:4*nbsuj) = 4;
    design(2,:)              	= repmat(1:nbsuj,1,4);
else
    design(1,1:nbsuj)    	= 1;
    design(1,nbsuj+1:2*nbsuj)   = 2;
    design(1,nbsuj*2+1:3*nbsuj) = 3;
    design(1,nbsuj*3+1:4*nbsuj) = 4;
    design(1,nbsuj*4+1:5*nbsuj) = 5;
    design(2,:)              	= repmat(1:nbsuj,1,5);
end

cfg.design                  = design;
cfg.ivar                    = 1; % condition
cfg.uvar                    = 2; % subject number
if size(alldata,2) == 4
    stat                  	= ft_timelockstatistics(cfg, alldata{:,1}, alldata{:,2}, alldata{:,3}, alldata{:,4});
else
    stat                 	= ft_timelockstatistics(cfg, alldata{:,1}, alldata{:,2}, alldata{:,3}, alldata{:,4}, alldata{:,5});
end

keep alldata *_list stat lock_focus

close all; figure;
nrow                    	= 2;
ncol                      	= 2;
i                        	= 0;
zlimit                    	= [0.46 0.8];

for nchan = 1:length(stat.label)
    
    cfg                    	= [];
    cfg.channel          	= nchan;
    cfg.time_limit        	= stat.time([1 end]);
    cfg.color            	= 'kbmry';
    cfg.z_limit            	= zlimit(nchan,:);
    cfg.linewidth         	= 10;
    
    i = i+1;
    subplot(nrow,ncol,i);
    h_plotSingleERFstat_selectChannel_nobox(cfg,stat,alldata);
    ylabel(stat.label{nchan});
    
    vline([0 1.5 3 4.5 5.5],'--k');
    xticklabels({'1st Cue' '1st Gab' '2nd Cue' '2nd Gab' 'Mean RT'});
    xticks([0 1.5 3 4.5 5.5]);
    
    hline(0.5,'--k');
    
end

zlimit                          = [0.47 0.7;0.47 0.6;0.47 0.6];

for nchan = 1:length(stat.label)
    
    chk_sig                     = stat.mask .* stat.stat;
    chk_sig                     = chk_sig(nchan,:);
    
    if length(unique(chk_sig)) > 1
        
        chk_clust_mat           = stat.mask .* stat.posclusterslabelmat;
        chk_clust_mat           = chk_clust_mat(nchan,:);
        
        clust_nmbr              = unique(chk_clust_mat(chk_clust_mat>0));
        
        for ncluster = 1:length(clust_nmbr)
            
            tmp_mat             = chk_clust_mat;
            
            tmp_mat(tmp_mat ~= clust_nmbr(ncluster)) = 0;
            tmp_mat(tmp_mat == clust_nmbr(ncluster)) = 1;
            
            for nsub = 1:size(alldata,1)
                for ncond = 1:size(alldata,2)
                    t1              = find(round(alldata{nsub,ncond}.time,2) == round(stat.time(1),2));
                    t2              = find(round(alldata{nsub,ncond}.time,2) == round(stat.time(end),2));
                    tmp_data        = alldata{nsub,ncond}.avg(nchan,[t1:t2]);
                    tmp_data        = tmp_data .* tmp_mat;
                    tmp_data(tmp_data == 0) = NaN;
                    data_plot(nsub,ncond)       = nanmean(tmp_data);
                end
            end
            
            if size(alldata,2) < 5
                
                [h1,p1]                   	= ttest(data_plot(:,1),data_plot(:,2));
                [h2,p2]                    	= ttest(data_plot(:,1),data_plot(:,3));
                [h3,p3]                   	= ttest(data_plot(:,1),data_plot(:,4));
                [h4,p4]                   	= ttest(data_plot(:,2),data_plot(:,3));
                [h5,p5]                   	= ttest(data_plot(:,2),data_plot(:,4));
                [h6,p6]                   	= ttest(data_plot(:,3),data_plot(:,4));
                
            else
                
                [h1,p1]                   	= ttest(data_plot(:,1),data_plot(:,2));
                [h2,p2]                    	= ttest(data_plot(:,1),data_plot(:,3));
                [h3,p3]                   	= ttest(data_plot(:,1),data_plot(:,4));
                [h4,p4]                   	= ttest(data_plot(:,1),data_plot(:,5));
                [h5,p5]                   	= ttest(data_plot(:,2),data_plot(:,3));
                [h6,p6]                   	= ttest(data_plot(:,2),data_plot(:,4));
                [h7,p7]                   	= ttest(data_plot(:,2),data_plot(:,5));
                [h8,p8]                   	= ttest(data_plot(:,3),data_plot(:,4));
                [h9,p9]                   	= ttest(data_plot(:,3),data_plot(:,5));
                [h10,p10]               	= ttest(data_plot(:,4),data_plot(:,5));
                
            end
            
            mean_data                       = nanmean(data_plot,1);
            bounds                          = nanstd(data_plot, [], 1);
            bounds_sem                      = bounds ./ sqrt(size(data_plot,1));
            
            i = i + 1;
            subplot(nrow,ncol,i);
            errorbar(mean_data,bounds_sem,'-ks','LineWidth',1.5);
            
            xlim([0 size(alldata,2)+1]);
            xticks([1:size(alldata,2)]);
            
            if size(alldata,2) < 5
                xticklabels({'Theta','Alpha','Beta','Gamma'});
            else
                xticklabels({'Theta','Alpha','Beta','Gamma','Chance'});
            end
            
            if size(alldata,2) == 5
                list_test                	= {'TvA' 'TvB' 'TvG' 'TvC' 'AvB' 'AvG' 'AvC' 'BvG' 'BvC' 'GvC'};
                p_val                    	= [p1 p2 p3 p4 p5 p6 p7 p8 p9 p10];
                h_val                    	= [h1 h2 h3 h4 h5 h6 h7 h8 h9 h10];
            else
                list_test                 	= {'TvA' 'TvB' 'TvG' 'AvB' 'AvG' 'BvG'};
                p_val                    	= [p1 p2 p3 p4 p5 p6];
                h_val                    	= [h1 h2 h3 h4 h5 h6];
            end
            
            p_val                           = p_val .* h_val;
            p_val(p_val == 0)               = NaN;
            
            plimit                          = 0.1;
            tit_fig                         = [];
            
            for np = 1:length(p_val)
                if p_val(np) < plimit
                    if p_val(np) == 0
                        tit_fig          	=[tit_fig list_test{np} ' < 0.0001 '];
                    else
                        if np < length(p_val)
                            tit_fig      	=[tit_fig list_test{np} ' '];
                        else
                            tit_fig        	=[tit_fig list_test{np}];    % ' = ' num2str(round(p_val(np),3))
                        end
                    end
                end
            end
            
            tmp_time        = tmp_mat .* stat.time;
            t_find        	= find(tmp_time ~= 0);
            
            title(tit_fig);
            hline(0.5,'--k');
            ylim(zlimit(ncluster,:));
            yticks(zlimit(ncluster,:));
            ylabel({[stat.label{nchan} ' #' num2str(ncluster)] [' ' num2str(round(tmp_time(t_find(1)),2)) ' - ' num2str(round(tmp_time(t_find(end)),2))]})
            
            
        end
    end
end

keep alldata *_list stat