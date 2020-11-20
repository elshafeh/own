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
    
    list_band                       = {'alpha' 'beta'};
    list_nback                   	= {'1back' '2back'};
    
    list_width                      = [1 2];
    i                               = 0;
    
    for nband = 1:length(list_band)
        for nback = 1:length(list_nback)
            
            list_freq               = round(allpeaks(nsuj,nband)-nband : allpeaks(nsuj,nband)+nband);
            pow                  	= [];
            
            for nfreq = 1:length(list_freq)
                
                file_list         	= dir(['J:/nback/sens_level_auc/cond/sub' num2str(suj_list(nsuj)) '.sess*.' list_nback{nback} ... 
                    '.' num2str(list_freq(nfreq)) 'Hz.istarget.bsl.dwn70.excl.auc.mat']);
                
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
            avg.time              	= time_axis;
            
            i                       = i+1;
            alldata{nsuj,i}         = avg; clear avg;
            
            list_cond{i}        	= [list_nback{nback} ' ' list_band{nband}(1:2)];
            fprintf('\n');
        end
    end
end

keep alldata list_cond

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

design                    	= zeros(2,4*nbsuj);
design(1,1:nbsuj)          	= 1;
design(1,nbsuj+1:2*nbsuj)  	= 2;
design(1,nbsuj*2+1:3*nbsuj)	= 3;
design(1,nbsuj*3+1:4*nbsuj)	= 4;
design(2,:)               	= repmat(1:nbsuj,1,4);
cfg.design               	= design;

cfg.design                  = design;
cfg.ivar                    = 1; % condition
cfg.uvar                    = 2; % subject number

stat                        = ft_timelockstatistics(cfg, alldata{:,1}, alldata{:,2}, alldata{:,3},alldata{:,4});

save('../data/stat/nback_multivar_cat_avgstim_target.mat','stat')

%%

figure;
nrow                     	= 2;
ncol                     	= 2;

cfg                         = [];
cfg.channel                 = 1;
cfg.z_limit                 = [0.46 0.65];
cfg.time_limit              = stat.time([1 end]);
cfg.color                   = {'-r' '-b' '--r' '--b'};
cfg.linewidth               = 10;
subplot(nrow,ncol,1);
h_plotSingleERFstat_selectChannel_nobox(cfg,stat,alldata);
xlim(stat.time([1 end]));
vline(0,'--k');
hline(0.5,'--k');

subplot(nrow,ncol,2);
hold on;
for ncond = 1:size(alldata,2)
    plot(0,ncond,cfg.color{ncond},'LineWidth',6)
end
legend(list_cond)

cfg.z_limit = [0.45 0.7];

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
                    
                    t1          	= find(round(alldata{nsub,ncond}.time,2) == round(stat.time(1),2));
                    t2              = find(round(alldata{nsub,ncond}.time,2) == round(stat.time(end),2));
                    t1             	= t1(1);
                    t2            	= t2(end);
                    
                    vct_y          	= alldata{nsub,ncond}.avg(1,t1:t2);
                    grnd          	= vct .* vct_y; 
                    grnd(grnd == 0) = NaN;
                    data_plot(nsub,ncond)       = nanmean(grnd);
                    
                    clear vct_y t1 t2 find_chan_in_data
                    
                end
            end
            
            mean_data             	= nanmean(data_plot,1);
            bounds               	= nanstd(data_plot, [], 1);
            bounds_sem            	= bounds ./ sqrt(size(data_plot,1));
            
            subplot(nrow,ncol,2+ncluster);
            errorbar(mean_data,bounds_sem,'-ks');
            
            nb_con               	= size(alldata,2);
            
            xlim([0 nb_con+1]);
            xticks(1:nb_con);
            xticklabels(list_cond);

            vct_test               	= {[1 2] [1 3] [2 4] [3 4]};
            vct_p                	=[];
            
            for nt = 1:length(vct_test)
                [h_lu,p_lu]       	= ttest(data_plot(:,vct_test{nt}(1)),data_plot(:,vct_test{nt}(2)));
                vct_p            	= [vct_p p_lu]; clear h_lu p_lu
            end
            
            vct_p                	= vct_p .* length(vct_test);
            fnd_sig               	= find(vct_p < 0.05);
            
            vct_p                  	= vct_p(fnd_sig);
            vct_test               	= vct_test(fnd_sig);
            
            ylim(cfg.z_limit);
            yticks(cfg.z_limit);
            
            hline(0.5,'--r');
            
            sigstar(vct_test,vct_p);
            set(gca,'FontSize',14,'FontName', 'Calibri','FontWeight','Light');
            
        end
    end
end