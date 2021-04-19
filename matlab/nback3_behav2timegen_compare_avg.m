clear; clc;

suj_list                        = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    list_behav                  = {'fast' 'slow'};
    ext_decode                  = 'stim'; % target first stim
    
    for nbehav = 1:2
        
        file_list               = dir(['~/Dropbox/project_me/data/nback/behav_timegen/sub' num2str(suj_list(nsuj)) '.' list_behav{nbehav} ...
            '.decoding.' ext_decode '*.yesdemean.auc.timegen.mat']);
        
        pow                     = [];
        
        for nfile = 1:length(file_list)
            
            fname_in            = [file_list(nfile).folder filesep file_list(nfile).name];
            fprintf('loading %s\n',fname_in);
            load(fname_in);
            
            pow(nfile,:,:)      = scores; clear scores;
            
        end
        
        pow                     = mean(pow,1);
        
        t1                   	= nearest(time_axis,0.2);
        t2                   	= nearest(time_axis,0.4);
        
        avg                   	= [];
        
        avg.avg                	= squeeze(mean(pow(:,t1:t2,:),2));
        if size(avg.avg,2) < size(avg.avg,1)
            avg.avg           	= avg.avg';
        end
        avg.label             	= {['decoding ' ext_decode]};
        avg.dimord            	= 'chan_time';
        avg.time            	= time_axis;
        
        
        alldata{nsuj,nbehav}  	= avg; clear avg;
        
    end
    
end

%%

nsuj                            = size(alldata,1);
[design,neighbours]             = h_create_design_neighbours(nsuj,alldata{1,1},'gfp','t'); clc;

cfg                             = [];
cfg.clusterstatistic            = 'maxsum';cfg.method = 'montecarlo';
cfg.correctm                    = 'cluster';cfg.statistic = 'depsamplesT';
cfg.uvar                        = 1;cfg.ivar = 2;
cfg.tail                        = 0;cfg.clustertail  = 0;

cfg.latency                     = [0 2];
cfg.clusteralpha                = 0.05; % !!
cfg.alpha                       = 0.05;

cfg.numrandomization            = 1000;
cfg.design                      = design;

stat                            = ft_timelockstatistics(cfg, alldata{:,1}, alldata{:,2});
[min_p, p_val]                  = h_pValSort(stat);


%%

figure;
nrow                            = 1;
ncol                         	= 1;
i                               = 0;
zlimit                          = [0.3 1];
plimit                         	= 0.05;

stat.mask                       = stat.prob < plimit;

nchan                           = 1;

cfg                             = [];
cfg.time_limit               	= [-0.1 2]; %stat.time([1 end]);
cfg.color                       = {'-b' '-r'};
cfg.z_limit                     = zlimit(nchan,:);
cfg.linewidth                   = 6;

i = i+1;
subplot(nrow,ncol,i);
h_plotSingleERFstat_singlechannel(cfg,stat,alldata);

ylabel({stat.label{nchan}, ['p = ' num2str(round(min_p,3))]});
title('Fast versus Slow');

legend({'fast' '' 'slow' ''});

vline([0],'--k');

set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
