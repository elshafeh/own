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
    
    list_cond                       = {'1back','2Back'};
    list_band                       = {'alpha' 'beta'};
    list_lock                       = 'istarget';% istarget % isfirst;
    
    list_width                      = [1 2];
    i                               = 0;
    
    for nband = 1:length(list_band)
        list_freq                   = round(allpeaks(nsuj,nband)-nband : allpeaks(nsuj,nband)+nband);
        
        for nback = 1:length(list_cond)
            
            
            
            pow                  	= [];
            
            for nfreq = 1:length(list_freq)
                file_list         	= dir(['J:/nback/sens_level_auc/cond/sub' num2str(suj_list(nsuj)) '.sess*.' ...
                    list_cond{nback} '.' num2str(list_freq(nfreq)) 'Hz.' list_lock '.bsl.dwn70.excl.auc.mat']);
                
                if isempty(file_list)
                    error('file not found!');
                end
                
                for nf = 1:length(file_list)
                    fname         	= [file_list(nf).folder filesep file_list(nf).name];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    pow           	= [pow;scores]; clear scores;
                end
            end
            
            
            avg                 	= [];
            avg.label           	= {'auc'};
            avg.avg              	= nanmean(pow,1); clear pow;
            avg.dimord            	= 'chan_time';
            avg.time              	= -1.5:0.02:2;
            
            i                       = i+1;
            alldata{nsuj,i}         = avg; clear avg;
            
            list_final{i}        	= ['B' list_cond{nback}(1) ' ' list_band{nband}(1:2)];
            
        end
    end
end

keep alldata list_final;

%%

nbsuj                       = size(alldata,1);
[~,neighbours]              = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg                         = [];
cfg.method                  = 'ft_statistics_montecarlo';
cfg.statistic               = 'ft_statfun_depsamplesFmultivariate';
cfg.correctm                = 'cluster';
cfg.clusteralpha            = 0.05;
cfg.clusterstatistic        = 'maxsum';
cfg.clusterthreshold        = 'nonparametric_common';
cfg.tail                     = 1; % For a F-statistic, it only make sense to calculate the right tail
cfg.clustertail             = cfg.tail;
cfg.alpha                   = 0.05;
cfg.computeprob             = 'yes';
cfg.numrandomization        = 1000;
cfg.neighbours              = neighbours;
cfg.latency                 = [-0.1 1];

design                          = zeros(2,4*nbsuj);
design(1,1:nbsuj)               = 1;
design(1,nbsuj+1:2*nbsuj)       = 2;
design(1,nbsuj*2+1:3*nbsuj)     = 3;
design(1,nbsuj*3+1:4*nbsuj)     = 4;
design(2,:)                     = repmat(1:nbsuj,1,4);
cfg.design                      = design;

cfg.design                  = design;
cfg.ivar                    = 1; % condition
cfg.uvar                    = 2; % subject number

stat                        = ft_timelockstatistics(cfg, alldata{:,1}, alldata{:,2}, alldata{:,3},alldata{:,4});

%%

figure;
nrow                     	= 2;
ncol                     	= 2;

cfg                         = [];
cfg.channel                 = 1;
cfg.p_threshold             = 0.05;
cfg.z_limit                 = [0.45 0.7];
cfg.time_limit              = stat.time([1 end]);
cfg.color                   = 'rgbk';
cfg.linewidth               = 10;
subplot(nrow,ncol,1);
h_plotSingleERFstat_selectChannel_nobox(cfg,stat,alldata);
xlim(stat.time([1 end]));
vline(0,'--k');
hline(0.5,'--k');

subplot(nrow,ncol,2);
hold on;
for ncond = 1:size(alldata,2)
    plot(0,ncond,['-' cfg.color(ncond)],'LineWidth',6)
end
legend(list_final)

cfg.z_limit = [0.5 0.7];

if isfield(stat,'posclusters')
    for ncluster = 1:length(stat.posclusters)
        
        nw_mat                      = stat.posclusterslabelmat;
        nw_mat(nw_mat ~= ncluster)  = 0;
        nw_mat(nw_mat == ncluster)  = 1;
        
        vct                         = nw_mat .* stat.mask .* stat.stat;
        vct(vct ~= 0)               = 1;
        
        if length(unique(vct)) > 1
            
            data_plot                   = [];
            
            for nsub = 1:size(alldata,1)
                for ncond = 1:size(alldata,2)
                    
                    t1                  = find(round(alldata{nsub,ncond}.time,2) == round(stat.time(1),2));
                    t2              	= find(round(alldata{nsub,ncond}.time,2) == round(stat.time(end),2));
                    t1                  = t1(1);
                    t2                  = t2(end);
                    
                    vct_y               = alldata{nsub,ncond}.avg(1,t1:t2);
                    grnd                = vct .* vct_y; 
                    grnd(grnd == 0) = NaN;
                    data_plot(nsub,ncond)       = nanmean(grnd);
                    
                    clear vct_y t1 t2 find_chan_in_data
                    
                end
            end
            
            [h1,p1]                   	= ttest(data_plot(:,1),data_plot(:,2));
            [h2,p2]                 	= ttest(data_plot(:,1),data_plot(:,3));
            [h3,p3]                 	= ttest(data_plot(:,1),data_plot(:,4));
            [h4,p4]                   	= ttest(data_plot(:,2),data_plot(:,3));
            [h5,p5]                 	= ttest(data_plot(:,2),data_plot(:,4));
            [h6,p6]                 	= ttest(data_plot(:,3),data_plot(:,4));
            
            
            mean_data                   = nanmean(data_plot,1);
            bounds                      = nanstd(data_plot, [], 1);
            bounds_sem                  = bounds ./ sqrt(size(data_plot,1));
            
            subplot(nrow,ncol,2+ncluster);
            errorbar(mean_data,bounds_sem,'-ks');
            
            nb_con                      = size(alldata,2);
            
            xlim([0 nb_con+1]);
            xticks(1:nb_con);
            xticklabels(list_final);

            title({['b1 al vs b2 al = ' num2str(round(p1,3))], ...
                ['b1 al vs b1 be = ' num2str(round(p2,3))],...
                ['b1 al vs b2 be = ' num2str(round(p3,3))], ...
                ['b2 al vs b1 be = ' num2str(round(p4,3))],...
                ['b2 al vs b2 be = ' num2str(round(p5,3))],...
                ['b1 be vs b2 be= ' num2str(round(p6,3))]});
            
            ylim(cfg.z_limit);
            yticks(cfg.z_limit);
            
            
        end
    end
end