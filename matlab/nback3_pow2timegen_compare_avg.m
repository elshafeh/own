clear; clc;

suj_list                                = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    list_behav                          = {'fast' 'slow'};
    
    list_band                           = {'alpha.pre' 'alpha.post' 'beta.pre' 'beta.post'};
    list_bin                            = {'b1' 'b2'};
    
    ext_decode                          = 'target'; % stim first target
    
    for nband = 1:length(list_band)
        for nbin = 1:length(list_bin)
            
            file_list                   = dir(['~/Dropbox/project_me/data/nback/timegen/sub' num2str(suj_list(nsuj)) '.' list_band{nband} ...
                '.' list_bin{nbin} '.decoding.' ext_decode '*.nodemean.auc.timegen.mat']);
            
            pow                         = [];
            
            for nfile = 1:length(file_list)
                
                fname_in                = [file_list(nfile).folder filesep file_list(nfile).name];
                fprintf('loading %s\n',fname_in);
                load(fname_in);
                
                pow(nfile,:,:)          = scores; clear scores;
                
            end
            
            pow                         = mean(pow,1);
            
            t1                          = nearest(time_axis,0.2);
            t2                          = nearest(time_axis,0.4);
            
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

plimit                          = 0.15;
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
    cfg.z_limit                	= zlimit(nchan,:);
    cfg.linewidth              	= 6;
    
    i = i+1;
    subplot(nrow,ncol,i);
    h_plotSingleERFstat_singlechannel(cfg,stat,squeeze(alldata(:,nband,:)));
    
    ylabel({stat.label{nchan}, ['p = ' num2str(round(min_p(nband),3))]});
    title(list_band{nband});
    
    legend({'low' '' 'high' ''});
    
    vline(0,'--k');
    
    set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
    
    
end