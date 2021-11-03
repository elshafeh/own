clear; clc;

suj_list                        = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    list_behav                  = {'1back.all' '2back.all'};
    
    for nbehav = 1:2
        
        file_list               = [];
        
        for nstim = [1 2 3 45 6 7 8 9]
            file_list         	= [file_list;dir(['~/Dropbox/project_me/data/nback/load_timegen/sub' num2str(suj_list(nsuj)) '.' list_behav{nbehav} ...
                '.decoding.stim' num2str(nstim) '.nodemean.auc.timegen.mat'])];
        end
        
        pow                     = [];
        
        for nfile = 1:length(file_list)
            
            fname_in            = [file_list(nfile).folder filesep file_list(nfile).name];
            fprintf('loading %s\n',file_list(nfile).name);
            load(fname_in);
            
            pow(nfile,:,:)      = scores; clear scores;
            
        end
        
        pow                     = mean(pow,1);
        
        time_window             = [0.1 0.3];
        
        t1                   	= nearest(time_axis,time_window(1));
        t2                   	= nearest(time_axis,time_window(2));
        
        avg                   	= [];
        
        avg.avg                	= squeeze(mean(pow(:,t1:t2,:),2));
        if size(avg.avg,2) < size(avg.avg,1)
            avg.avg           	= avg.avg';
        end

        
        avg.label             	= {'decoding stim'};
        avg.dimord            	= 'chan_time';
        avg.time            	= time_axis;
        
        alldata{nsuj,nbehav}    = avg; clear freq;
        
    end
    
end

keep alldata

%%

nsuj                            = size(alldata,1);
[design,neighbours]             = h_create_design_neighbours(nsuj,alldata{1,1},'gfp','t'); clc;

cfg                             = [];
cfg.clusterstatistic            = 'maxsum';cfg.method = 'montecarlo';
cfg.correctm                    = 'cluster';cfg.statistic = 'depsamplesT';
cfg.uvar                        = 1;cfg.ivar = 2;
cfg.tail                        = 0;cfg.clustertail  = 0;

cfg.latency                     = [-0.1 2];
cfg.clusteralpha                = 0.05; % !!
cfg.alpha                       = 0.05;

cfg.numrandomization            = 1000;
cfg.design                      = design;

stat                            = ft_timelockstatistics(cfg, alldata{:,1}, alldata{:,2});
[min_p, p_val]                  = h_pValSort(stat);

mask_mean                       = mean(stat.mask,1);
mask_mean(mask_mean ~= 0)       = 1;
sig_time                        = mask_mean .* stat.time;

%%

figure;
nrow                            = 2;
ncol                         	= 2;
i                               = 0;
plimit                         	= 0.05;

stat.mask                       = stat.prob < plimit;

nchan                           = 1;

cfg                           	= [];
cfg.channel                   	= 1;
cfg.time_limit                	= stat.time([1 end]); % [-0.1 2]; %
cfg.color                     	= [83 51 137; 197 94 32]; % [58 161 122; 47 123 182];
cfg.color                     	= cfg.color ./ 256;

cfg.z_limit                   	= [0.3 1];

cfg.linewidth               	= 5;
cfg.lineshape               	= '-k';

i = i+1;
subplot(nrow,ncol,i);
h_plotSingleERFstat_selectChannel_nobox(cfg,stat,alldata);

ylabel({stat.label{nchan}, ['p = ' num2str(round(min_p,3))]});
title('1b versus 2b');

legend({'1back' '' '2back' ''});

vline([0],'--k');

set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');