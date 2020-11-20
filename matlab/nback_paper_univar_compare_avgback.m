clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                      	= [1:33 35:36 38:44 46:51];
allpeaks                     	= [];

for nsuj = 1:length(suj_list)
    load(['J:/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.mat']);
    allpeaks(nsuj,1)          	= apeak; clear apeak;
    allpeaks(nsuj,2)         	= bpeak; clear bpeak;
end

allpeaks(isnan(allpeaks(:,2)),2)	= nanmean(allpeaks(:,2));

keep suj_list allpeaks

for nsuj = 1:length(suj_list)
    
    subjectName              	= ['sub' num2str(suj_list(nsuj))];clc;
    list_stim               	= {'first' 'target'};
    i                           = 0;
    list_cond                 	= {};
    
    for nback = [1 2]
        
        % load data from both sessions
        check_name             	= dir(['J:/nback/tf_sens/' subjectName '.sess*.' num2str(nback) 'back.*.stim.1t100Hz.sens.mat']);
        
        
        for nf = 1:length(check_name)
            
            fname             	= [check_name(nf).folder filesep check_name(nf).name];
            fprintf('loading %s\n',fname);
            load(fname);
            
            % baseline-correct
            cfg                	= [];
            cfg.baseline      	= [-0.4 -0.2];
            cfg.baselinetype   	= 'relchange';
            freq_comb       	= ft_freqbaseline(cfg,freq_comb);
            
            tmp{nf}             = freq_comb; clear freq_comb;
            
        end
        
        % avearge both sessions
        freq                    = ft_freqgrandaverage([],tmp{:}); clear tmp nf check_name;
        
        for test_band = {'alpha' 'beta'}
            
            switch test_band{:}
                case 'alpha'
                    bnd_width  	= 1;
                    apeak    	= allpeaks(nsuj,1);
                    xi        	= find(round(freq.freq) == round(apeak - bnd_width));
                    yi         	= find(round(freq.freq) == round(apeak + bnd_width));
                case 'beta'
                    bnd_width  	= 2;
                    apeak     	= allpeaks(nsuj,2);
                    xi         	= find(round(freq.freq) == round(apeak - bnd_width));
                    yi       	= find(round(freq.freq) == round(apeak + bnd_width));
            end
            
            avg             	= [];
            avg.avg           	= squeeze(mean(freq.powspctrm(:,xi:yi,:),2));
            avg.label        	= freq.label;
            avg.dimord        	= 'chan_time';
            avg.time          	= freq.time;
            
            i                  	= i + 1;
            alldata{nsuj,i}    	= avg; clear avg;
            
            list_cond{i}      	= ['B'  num2str(nback) ' ' test_band{:}(1:2)];
            
            
        end
    end
end

re_arrange_vct                  = [1 3 2 4]; %
alldata                         = alldata(:,re_arrange_vct);
list_cond                       = list_cond(re_arrange_vct);

keep alldata list_cond ext_stim

%% compute anova

nbsuj                           = size(alldata,1);
[~,neighbours]                  = h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

cfg                             = [];

cfg.latency                     = [-0.1 1];

cfg.minnbchan                   = 4;
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

% design                          = zeros(2,6*nbsuj);
% design(1,1:nbsuj)               = 1;
% design(1,nbsuj+1:2*nbsuj)       = 2;
% design(1,nbsuj*2+1:3*nbsuj)     = 3;
% design(1,nbsuj*3+1:4*nbsuj)     = 4;
% design(1,nbsuj*4+1:5*nbsuj)     = 5;
% design(1,nbsuj*5+1:6*nbsuj)     = 6;
% design(2,:)                     = repmat(1:nbsuj,1,6);
% cfg.design                      = design;
% cfg.ivar                        = 1; % condition
% cfg.uvar                        = 2; % subject number
% stat                            = ft_timelockstatistics(cfg, alldata{:,1}, alldata{:,2}, alldata{:,3}, ...
%     alldata{:,4}, alldata{:,5}, alldata{:,6});

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

%% plot

statplot                        = [];
statplot.time                   = stat.time;
statplot.label                  = stat.label;
statplot.dimord                 = stat.dimord;
statplot.avg                    = stat.mask .* stat.stat;

figure;
nrow                            = 2;
ncol                            = 4;

cfg                             = [];
cfg.layout                      = 'neuromag306cmb.lay';
% cfg.zlim                        = [0 20];
cfg.colormap                    = brewermap(256,'*RdBu');
cfg.marker                      = 'off';
cfg.comment                     = 'no';
cfg.colorbar                    = 'yes';
subplot(nrow,ncol,1);
ft_topoplotER(cfg,statplot);
title(['p = ' num2str(stat.posclusters(1).prob,3)]);

list_chan               = {'MEG1632+1633','MEG1642+1643','MEG1732+1733','MEG1832+1833','MEG1842+1843', ...
    'MEG1912+1913','MEG1922+1923','MEG1932+1933','MEG1942+1943','MEG2012+2013', ...
    'MEG2022+2023','MEG2032+2033','MEG2042+2043','MEG2112+2113','MEG2232+2233', ...
    'MEG2242+2243','MEG2312+2313','MEG2322+2323','MEG2332+2333','MEG2342+2343','MEG2442+2443'};

cfg                             = [];
cfg.channel                     = list_chan;
subplot(nrow,ncol,2);
ft_singleplotER(cfg,statplot);
xlim(statplot.time([1 end]));
ax	= gca;
lm  = ax.YAxis.Limits([1 end]);
ylim(round(lm));
yticks(round(lm));
vline(0,'-k');title('');

cfg                             = [];
cfg.channel                     = list_chan;
cfg.time_limit                  = stat.time([1 end]);
cfg.color                       = {'-r' '-b' '--r' '--b'}; % 'rgbmck';
cfg.z_limit                     = [-0.5 0.5];
cfg.linewidth                   = 10;
subplot(nrow,ncol,3);
h_plotSingleERFstat_selectChannel_nobox(cfg,stat,alldata);
xlim(statplot.time([1 end]));
vline(0,'--k');
hline(0,'--k');

subplot(nrow,ncol,4);
hold on;
for ncond = 1:size(alldata,2)
    plot(0,ncond,cfg.color{ncond},'LineWidth',6)
end
legend(list_cond)
set(gca,'FontSize',20,'FontName', 'Calibri','FontWeight','Light');
xticks([]);yticks([]);

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
                
                find_chan_in_data   = [];
                find_chan_in_stat   = [];
                
                for nc = 1:length(list_chan)
                    find_chan_in_data            	= [find_chan_in_data; find(strcmp(list_chan{nc},alldata{nsub,ncond}.label))];
                    find_chan_in_stat            	= [find_chan_in_stat; find(strcmp(list_chan{nc},stat.label))];
                end
                
                vct_y                   = alldata{nsub,ncond}.avg(find_chan_in_data,t1:t2);
                data_plot(nsub,ncond)   = mean(mean(vct(find_chan_in_stat,:) .* vct_y));
                
                clear vct_y t1 t2 find_chan_in_data
                
            end
        end
        
        %         [h3,p3]                 	= ttest(data_plot(:,1),data_plot(:,4));
        %         [h4,p4]                   	= ttest(data_plot(:,2),data_plot(:,3));
        
        mean_data                   = nanmean(data_plot,1);
        bounds                      = nanstd(data_plot, [], 1);
        bounds_sem                  = bounds ./ sqrt(size(data_plot,1));
        
        subplot(nrow,ncol,4+ncluster);
        errorbar(mean_data,bounds_sem,'-ks');
        
        nb_con                      = size(alldata,2);
        
        xlim([0 nb_con+1]);
        xticks(1:nb_con);
        xticklabels(list_cond);
        
        vct_test                    = {[1 2] [1 3] [2 4] [3 4]};
        vct_p                       =[];
        
        for nt = 1:length(vct_test)
            [h_lu,p_lu]             = ttest(data_plot(:,vct_test{nt}(1)),data_plot(:,vct_test{nt}(2)));
            vct_p                	= [vct_p p_lu]; clear h_lu p_lu
        end
        
        vct_p                       = vct_p .* length(vct_test);
        fnd_sig                     = find(vct_p < 0.05);
        
        vct_p                       = vct_p(fnd_sig);
        vct_test                	= vct_test(fnd_sig);
        
        cfg.z_limit = [-0.25 0.25];
        
        ylim(cfg.z_limit);
        yticks(cfg.z_limit);
        hline(0,'--r');
        sigstar(vct_test,vct_p);
        set(gca,'FontSize',14,'FontName', 'Calibri','FontWeight','Light');
        
    end
end