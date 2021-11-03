clear;clc;

suj_list                    = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    sujname                 = ['sub' num2str(suj_list(nsuj))];
    
    dir_files            	= '~/Dropbox/project_me/data/nback/';
    ext_decode          	= 'stim';
    
    list_stim               = [1 2 3 4 5 6 7 8 9]; %[2 3 4 5 7 8 9]; % 
    
    for nstim = 1:length(list_stim)
        
        % load decoding output
        dir_files          	= '~/Dropbox/project_me/data/nback/';
        fname            	= [dir_files 'auc/' sujname '.decoding.stim' num2str(list_stim(nstim)) '.nodemean.leaveone.mat'];
        fprintf('loading %s\n',fname);
        load(fname); %,'y_array','yproba_array','time_axis','e_array');
        
        % transpose matrices
        y_array            	= y_array';
        yproba_array      	= yproba_array';
        e_array          	= e_array';
        yhat_array          = yhat_array';
        
        measure           	= 'yproba'; % auc yproba
        
        fname             	= [dir_files 'trialinfo/' sujname '.flowinfo.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        sub_info         	= trialinfo(trialinfo(:,2) == 2,[4 5 6]); %trialinfo(:,[4 5 6]);
        
        sub_info_correct 	= sub_info(sub_info(:,1) == 1 | sub_info(:,1) == 3,:); % remove incorrect trials for RT analyses
        sub_info_correct 	= sub_info_correct(sub_info_correct(:,2) ~= 0,:); % remove zeros
        
        [index_good,~]      = calc_tukey(sub_info_correct(:,2));
        sub_info            = sub_info(index_good,:);
        
        median_rt         	= median(sub_info_correct(:,2));
        
        index_trials{1}  	= sub_info_correct(sub_info_correct(:,2) < median_rt,3); % fast
        index_trials{2}  	= sub_info_correct(sub_info_correct(:,2) > median_rt,3); % slow
        
        for nbin = [1 2]
            
            idx_trials                      = index_trials{nbin};
            
            AUC_bin_test                 	= [];
            disp('computing AUC');
            
            for ntime = 1:size(y_array,2)
                
                if strcmp(measure,'yproba')
                    
                    yproba_array_test     	= yproba_array(idx_trials,ntime);
                    
                    if min(unique(y_array(:,ntime))) == 1
                        yarray_test        	= y_array(idx_trials,ntime) - 1;
                    else
                        yarray_test       	= y_array(idx_trials,ntime);
                    end
                    
                    try 
                        [~,~,~,AUC_bin_test(ntime)]	= perfcurve(yarray_test,yproba_array_test,1);
                    catch
                        AUC_bin_test(ntime)         = NaN;
                    end
                        
                elseif strcmp(measure,'auc')
                    AUC_bin_test(ntime)     = mean(e_array(idx_trials,ntime));
                elseif strcmp(measure,'confidence')
                    AUC_bin_test(ntime)     = mean(yhat_array(idx_trials,ntime));
                end
            end
            
            avg                	= [];
            avg.avg            	= AUC_bin_test;
            avg.time           	= time_axis;
            avg.label          	= {['decoding ' ext_decode num2str(list_stim(nstim))]};
            avg.dimord         	= 'chan_time';
            
            alldata{nsuj,nbin,nstim}        = avg; clear avg;
            
        end
    end
    
end

keep alldata

%%

nsuj                            = size(alldata,1);
[design,neighbours]             = h_create_design_neighbours(nsuj,alldata{1},'gfp','t'); clc;

for nstim = 1:size(alldata,3)
    
    cfg                      	= [];
    cfg.clusterstatistic      	= 'maxsum';cfg.method = 'montecarlo';
    cfg.correctm            	= 'cluster';cfg.statistic = 'depsamplesT';
    cfg.uvar                   	= 1;cfg.ivar = 2;
    cfg.tail                   	= 0;cfg.clustertail  = 0;
    cfg.neighbours            	= neighbours;
    cfg.channel                	= 1;
    
    cfg.latency              	= [0 1];
    cfg.clusteralpha            	= 0.05; % !!
    cfg.minnbchan             	= 0; % !!
    cfg.alpha                  	= 0.025;
    
    cfg.numrandomization       	= 1000;
    cfg.design                 	= design;
    
    allstat{nstim}          	= ft_timelockstatistics(cfg, alldata{:,1,nstim}, alldata{:,2,nstim});
    
end

%%

clc; close all;

nrow                         	= 3;
ncol                          	= 3;
i                             	= 0;

zlimit                        	= [0.4 1];
plimit                       	= 0.3;

for nstim = 1:length(allstat)
    
    stat                        = allstat{nstim};
    stat.mask                   = stat.prob < plimit;
    
    for nchan = 1:length(stat.label)
        
        vct                     = stat.prob(nchan,:);
        min_p                   = min(vct);
        
        cfg                     = [];
        cfg.channel             = nchan;
        cfg.time_limit          = [-0.1 1];
        
        cfg.color           	= [109 179 177; 111 71 142];
        cfg.color            	= cfg.color ./ 256;
        
        cfg.z_limit             = [0 0.2];
        
        cfg.linewidth           = 2;
        cfg.lineshape           = '-x';
        
        i = i+1;
        subplot(nrow,ncol,i);
        h_plotSingleERFstat_selectChannel_nobox(cfg,stat,alldata);
        
        ylabel({stat.label{nchan}, ['p= ' num2str(round(min_p,3))]})
        
        vline(0,'--k');
        
        hline(0.07,'--k');
        
        legend({'fast' '' 'slow' ''});
        
        set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
        
        
    end
end