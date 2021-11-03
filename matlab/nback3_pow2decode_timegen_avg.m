clear; clc;

suj_list                                = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    list_behav                          = {'fast' 'slow'};
    
    list_band                           = {'alpha.pre' 'beta.pre'};
    list_bin                            = {'b1' 'b2'};
    
    ext_decode                          = 'stim';
    
    for nband = 1:length(list_band)
        for nbin = 1:length(list_bin)
            
            list_stim                   = [1 2 3 4 5 6 7 8 9]; % [1:10];
            pow                         = [];
            
            for nstim = 1:length(list_stim)
                
                fname_in                = ['~/Dropbox/project_me/data/nback/timegen/sub' num2str(suj_list(nsuj)) '.' list_band{nband} ...
                '.' list_bin{nbin} '.decoding.stim' num2str(list_stim(nstim)) '.nodemean.withback.downsample.auc.timegen.mat'];
                fprintf('loading %s\n',fname_in);
                load(fname_in);
                
                pow(nstim,:,:)          = scores; clear scores;
                
            end
            
            pow                         = mean(pow,1);
            
            t1                          = nearest(time_axis,0.1);
            t2                          = nearest(time_axis,0.3);
            
            avg                         = [];
            
            avg.avg                     = squeeze(mean(pow(:,t1:t2,:),2));
            if size(avg.avg,2) < size(avg.avg,1)
                avg.avg           	= avg.avg';
            end
            avg.label                   = {['decoding ' ext_decode]};
            avg.dimord                  = 'chan_time';
            avg.time                    = time_axis;
            
            alldata{nsuj,nband,nbin}    = avg; clear avg;
            
        end
    end
    
end

keep alldata list_band

%%

nsuj                          	= size(alldata,1);
[design,neighbours]            	= h_create_design_neighbours(nsuj,alldata{1,1},'gfp','t'); clc;

cfg                             = [];
cfg.clusterstatistic            = 'maxsum';cfg.method = 'montecarlo';
cfg.correctm                    = 'cluster';cfg.statistic = 'depsamplesT';
cfg.uvar                        = 1;cfg.ivar = 2;
cfg.tail                        = 0;cfg.clustertail  = 0;

cfg.latency                     = [0 2];
cfg.clusteralpha                = 0.05; % !!
cfg.alpha                       = 0.025;

cfg.numrandomization            = 1000;
cfg.design                      = design;

for nband = 1:size(alldata,2)
    
    allstat{nband}          	= ft_timelockstatistics(cfg, alldata{:,nband,1}, alldata{:,nband,2});
    [min_p(nband), ~]       	= h_pValSort(allstat{nband});
    
end

%%

close all;

plimit                          = 0.1;
zlimit                          = [0.3 1];

nrow                            = 2;
ncol                            = 2;
nchan                           = 1;
i                               = 0;

for nband = 1:length(allstat)
    
    stat                        = allstat{nband};
    stat.mask                   = stat.prob < plimit;
    
    cfg                       	= [];
    cfg.time_limit            	= [-0.1 2]; %stat.time([1 end]);
    cfg.color                  	= {'-b' '-r'};
    cfg.z_limit                	= [0.3 1];
    cfg.linewidth              	= 6;
    
    i = i+1;
    subplot(nrow,ncol,i);
    h_plotSingleERFstat_singlechannel(cfg,stat,squeeze(alldata(:,nband,:)));
    ylabel({stat.label{nchan}, ['p = ' num2str(round(min_p(nband),3))]});
    title(list_band{nband});
    legend({'low' '' 'high' ''});
    vline(0,'--k');
    set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
    
    if min_p(nband) < plimit
    
        sig_time                        = stat.mask .* stat.time;
        sig_time                        = find(sig_time ~= 0);
        
        plotdata                        = [];
        
        for nsuj = 1:size(alldata,1)
            for nbin = [1 2]
                plotdata(nsuj,nbin)     = mean(alldata{nsuj,nband,nbin}.avg(:,sig_time),2);
            end
        end
        
        i = i+1;
        subplot(nrow,ncol,i);
        hold on;
        boxplot(plotdata);
        ylim([0.5 0.51]);
        yticks([]);
        xticklabels({'low' 'high'});
        
        
    end
    
    
    mask_mean                   = mean(stat.mask,1);
    mask_mean(mask_mean ~= 0)   = 1;
    sig_time                    = mask_mean .* stat.time;
    
end