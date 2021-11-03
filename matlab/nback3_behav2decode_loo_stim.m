clear;clc;

suj_list                    = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    sujname                 = ['sub' num2str(suj_list(nsuj))];
    
    dir_files            	= '~/Dropbox/project_me/data/nback/';
    ext_decode          	= 'stim';
    
    % load indices
    index_trials{1}         = [];
    index_trials{2}         = [];
    
    fname                   = [dir_files 'trialinfo/' sujname '.flowinfo.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    for nback = [1 2]
        
        % choose trials with target
        sub_info           	= trialinfo(trialinfo(:,1) == nback+4 & trialinfo(:,2) == 2,[4 5 6]);
        
        %         % choose all trials
        %         sub_info           	= trialinfo(trialinfo(:,1) == nback+4,[4 5 6]);
        
        % remove incorrect trials for RT analyses
        sub_info_correct  	= sub_info(sub_info(:,1) == 1 | sub_info(:,1) == 3,:);
        
        % remove zeros
        sub_info_correct  	= sub_info_correct(sub_info_correct(:,2) ~= 0,:);
        
        % remove outliers
        [index_good,~]     	= calc_tukey(sub_info_correct(:,2));
        sub_info_correct  	= sub_info_correct(index_good,:);
        
        median_rt         	= median(sub_info_correct(:,2));
        
        %median split
        index_trials{1}    	= [index_trials{1} ; sub_info_correct(sub_info_correct(:,2) < median_rt,3)]; % fast
        index_trials{2}  	= [index_trials{2} ; sub_info_correct(sub_info_correct(:,2) > median_rt,3)]; % slow
        
    end
    
    list_stim               = [1 2 3 4 5 6 7 8 9];
    
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
        
        for nbin = [1 2]
            
            idx_trials   	= index_trials{nbin};
            AUC_bin_test   	= [];
            
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
            
            avg                             = [];
            avg.avg                         = AUC_bin_test;
            avg.time                        = time_axis;
            avg.label                       = {['decoding ' ext_decode]};
            avg.dimord                      = 'chan_time';
            
            alldata{nsuj,nbin,nstim}        = avg; clear avg;
            
        end
    end
    
end

%%

keep alldata list_* ext_decode

for nsuj = 1:size(alldata,1)
    for nbin = 1:size(alldata,2)
        
        tmp         = [];
        i           = 0;
        
        for nstim = 1:size(alldata,3)
            if ~isempty(alldata{nsuj,nbin,nstim})
                tmp     = [tmp; alldata{nsuj,nbin,nstim}.avg];
                i       = nstim;
            end
        end
                
        newdata{nsuj,nbin}          = alldata{nsuj,nbin,1};
        newdata{nsuj,nbin}.avg      = nanmean(tmp,1); clear tmp;
        
        
        clear tmp;
        
    end
end

alldata                         = newdata;

%%

keep alldata list_* ext_decode

nsuj                            = size(alldata,1);
[design,neighbours]             = h_create_design_neighbours(nsuj,alldata{1},'gfp','t'); clc;


cfg                             = [];
cfg.clusterstatistic            = 'maxsum';cfg.method = 'montecarlo';
cfg.correctm                    = 'cluster';cfg.statistic = 'depsamplesT';
cfg.uvar                        = 1;cfg.ivar = 2;
cfg.tail                        = 0;cfg.clustertail  = 0;
cfg.neighbours                  = neighbours;
cfg.channel                     = 1;

cfg.latency                     = [-0.1 1];
cfg.clusteralpha                = 0.05; % !!
cfg.minnbchan                   = 0; % !!
cfg.alpha                       = 0.025;

cfg.numrandomization            = 1000;
cfg.design                      = design;

allstat{1}                      = ft_timelockstatistics(cfg, alldata{:,1}, alldata{:,2});

keep alldata list_* allstat ext_decode


%%

clc; close all;

nrow                         	= 2;
ncol                          	= 2;
i                             	= 0;
plimit                       	= 0.05;

for nband = 1:size(allstat,1)
    
    stat                        = allstat{nband,1};
    stat.mask                   = stat.prob < plimit;
    
    for nchan = 1:length(stat.label)
        
        vct                     = stat.prob(nchan,:);
        min_p                   = min(vct);
        
        cfg                     = [];
        cfg.channel             = nchan;
        cfg.time_limit          = stat.time([1 end]);
        
        cfg.color           	= [109 179 177; 111 71 142];
        cfg.color            	= cfg.color ./ 256;
        
        cfg.z_limit             = [0.04 0.2]; %[0.1 0.5]; %
       
        cfg.linewidth           = 010;
        cfg.lineshape           = '-k';
        
        i = i+1;
        subplot(nrow,ncol,i);
        h_plotSingleERFstat_selectChannel_nobox(cfg,stat,alldata);
        
        ylabel({stat.label{nchan}, ['p= ' num2str(round(min_p,3))]})
        
        vline(0,'--k');
        
        if strcmp(ext_decode,'condition')
            hline(0.35,'--k');
        elseif strcmp(ext_decode,'target')
            hline(0.35,'--k');
        elseif strcmp(ext_decode,'first')
            hline(0.17,'--k');
        elseif strcmp(ext_decode,'stim')
            hline(0.07,'--k');
        end
        
        legend({'fast' '' 'slow' ''});
        
        set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
        
        
    end
end