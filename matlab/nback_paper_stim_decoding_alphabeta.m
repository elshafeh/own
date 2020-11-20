clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                            = [1:33 35:36 38:44 46:51];
allpeaks                            = [];

for nsuj = 1:length(suj_list)
    load(['J:/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.mat']);
    allpeaks(nsuj,1)                = apeak; clear apeak;
    allpeaks(nsuj,2)                = bpeak; clear bpeak;
end

allpeaks(isnan(allpeaks(:,2)),2)  	= nanmean(allpeaks(:,2));

keep suj_list allpeaks

for nsuj = 1:length(suj_list)
    
    list_nback                   	= [1 2];
    list_cond                       = {'1back','2Back'};
    list_color                      = 'rgb';
    list_freq                       = 1:30;
    
    i                               = 0;
    
    for nback = [1 2]
        
        list_lock                   = {'isfirst'};
        pow                         = [];
        
        for nlock = 1:length(list_lock)
            for nfreq = 1:length(list_freq)
                
                file_list         	= dir(['J:/nback/sens_level_auc/cond/sub' num2str(suj_list(nsuj)) '.sess*.' ...
                    num2str(nback) 'back.' num2str(list_freq(nfreq)) 'Hz.' list_lock{nlock} '.bsl.dwn70.excl.auc.mat']);
                
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
        
        for test_band = {'alpha' 'beta'}
            
            switch test_band{:}
                case 'alpha'
                    bnd_width  	= 1;
                    apeak    	= allpeaks(nsuj,1);
                    xi        	= find(round(list_freq) == round(apeak - bnd_width));
                    yi         	= find(round(list_freq) == round(apeak + bnd_width));
                case 'beta'
                    bnd_width  	= 2;
                    apeak     	= allpeaks(nsuj,2);
                    xi         	= find(round(list_freq) == round(apeak - bnd_width));
                    yi       	= find(round(list_freq) == round(apeak + bnd_width));
            end
            
            avg             	= [];
            avg.avg           	= squeeze(mean(pow(:,xi:yi,:),2));
            
            if size(avg.avg,1) > size(avg.avg,2)
                avg.avg         = avg.avg';
            end
            
            avg.label        	= list_lock;
            avg.dimord        	= 'chan_time';
            avg.time          	= time_axis;
            
            i                  	= i + 1;
            alldata{nsuj,i}    	= avg; clear avg;
            
            list_cond{i}      	= ['B' num2str(nback) ' ' test_band{:}(1:2)];
            
            
        end
    end
end

re_arrange_vct                  = [1 3 2 4]; % [1 3 5 2 4 6];
alldata                         = alldata(:,re_arrange_vct);
list_cond                       = list_cond(re_arrange_vct);

keep alldata list_cond

%%

nbsuj                           = size(alldata,1);
[~,neighbours]                  = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg                             = [];
cfg.latency                     = [-0.1 2];
cfg.method                      = 'ft_statistics_montecarlo';
cfg.statistic                   = 'ft_statfun_depsamplesFmultivariate';
cfg.correctm                    = 'cluster';
cfg.clusteralpha                = 0.05;
cfg.clusterstatistic            = 'maxsum'; %'maxsum', 'maxsize', 'wcm'
cfg.clusterthreshold            = 'nonparametric_common';
cfg.tail                        = 1; % For a F-statistic, it only make sense to calculate the right tail
cfg.clustertail                 = cfg.tail;
cfg.alpha                       = 0.05;
cfg.computeprob                 = 'yes';
cfg.numrandomization            = 1000;
cfg.neighbours                  = neighbours;

design                          = zeros(2,4*nbsuj);
design(1,1:nbsuj)               = 1;
design(1,nbsuj+1:2*nbsuj)       = 2;
design(1,nbsuj*2+1:3*nbsuj)     = 3;
design(1,nbsuj*3+1:4*nbsuj)     = 4;
design(2,:)                     = repmat(1:nbsuj,1,4);
cfg.design                      = design;
cfg.ivar                        = 1; % condition
cfg.uvar                        = 2; % subject number
stat                            = ft_timelockstatistics(cfg, alldata{:,1}, alldata{:,2}, alldata{:,3},alldata{:,4});

%%

figure;
nrow                     	= 2;
ncol                     	= 2;

cfg                         = [];
cfg.channel                 = 1;
cfg.p_threshold             = 0.05;
cfg.z_limit                 = [0.47 0.6];
cfg.time_limit              = stat.time([1 end]);
cfg.color                   = 'rbgk';
cfg.linewidth               = 15;
subplot(nrow,ncol,1);
h_plotSingleERFstat_selectChannel_nobox(cfg,stat,alldata);
vline(0,'-k');
hline(0.5,'-k');
xticks([0:0.4:2]);

subplot(nrow,ncol,2);
hold on;
for ncond = 1:size(alldata,2)
    plot(0,ncond,['-' cfg.color(ncond)],'LineWidth',6)
end

legend({'1b al' '2b al' '1b be' '2b be'});