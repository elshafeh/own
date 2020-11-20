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
    
    subjectName                     = ['sub' num2str(suj_list(nsuj))];clc;
    list_lock                     	= {'first' 'target'};
    
    i                               = 0;
    list_cond                       = {};
    
    for nback = [1 2]
        for nlock = [1 2]
            % load data from both sessions
            check_name             	= dir(['J:/nback/tf_sens/' subjectName '.sess*.' num2str(nback) 'back.' list_lock{nlock} '.stim.1t100Hz.sens.mat']);
            
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
                
                list_cond{i}      	= ['B' num2str(nback) ' ' test_band{:}(1:2) ' ' list_lock{nlock}(1)];
                
                
            end
        end
    end
end

re_arrange_vct                  = [1 3 5 7 2 4 6 8];
alldata                         = alldata(:,re_arrange_vct);
list_cond                       = list_cond(re_arrange_vct);

keep alldata list_cond

%%

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

design                          = zeros(2,8*nbsuj);
design(1,1:nbsuj)               = 1;
design(1,nbsuj+1:2*nbsuj)       = 2;
design(1,nbsuj*2+1:3*nbsuj)     = 3;
design(1,nbsuj*3+1:4*nbsuj)     = 4;
design(1,nbsuj*4+1:5*nbsuj)     = 5;
design(1,nbsuj*5+1:6*nbsuj)     = 6;
design(1,nbsuj*6+1:7*nbsuj)     = 7;
design(1,nbsuj*7+1:8*nbsuj)     = 8;
design(2,:)                     = repmat(1:nbsuj,1,8);
cfg.design                      = design;

cfg.ivar                        = 1; % condition
cfg.uvar                        = 2; % subject number
stat                            = ft_timelockstatistics(cfg, alldata{:,1}, alldata{:,2}, alldata{:,3}, ...
    alldata{:,4}, alldata{:,5}, alldata{:,6}, alldata{:,7}, alldata{:,8});

keep alldata list_cond stat

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
% cfg.zlim                    = [0 20];
cfg.colormap                    = brewermap(256,'*RdBu');
cfg.marker                      = 'off';
cfg.comment                     = 'no';
cfg.colorbar                    = 'yes';
subplot(nrow,ncol,1);
ft_topoplotER(cfg,statplot);

list_chan                       ={'MEG1832+1833','MEG1922+1923','MEG2012+2013','MEG2022+2023','MEG2032+2033', ...
    'MEG2042+2043','MEG2112+2113','MEG2232+2233','MEG2242+2243','MEG2312+2313', ...
    'MEG2322+2323','MEG2342+2343','MEG2442+2443','MEG2512+2513'};

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
cfg.color                       = {'-r' '-g' '-b' '-k' '--r' '--g' '--b' '--k'};
cfg.z_limit                     = [-0.55 0.55];
cfg.linewidth                   = 10;
subplot(nrow,ncol,3);
h_plotSingleERFstat_selectChannel_nobox(cfg,stat,alldata);
xlim(statplot.time([1 end]));
vline(0,'--k');
hline(0,'--k');

subplot(nrow,ncol,5);
hold on;
for ncond = 1:size(alldata,2)
    plot(0,ncond,cfg.color{ncond},'LineWidth',6)
end
legend(list_cond)

cfg.z_limit = [-0.3 0.2];

for ncluster = 1:length(stat.posclusters)
    
    nw_mat                      = stat.posclusterslabelmat;
    nw_mat(nw_mat ~= ncluster)  = 0;
    nw_mat(nw_mat == ncluster)  = 1;
    
    vct                         = nw_mat .* stat.mask .* stat.stat;
    vct(vct ~= 0)               = 1;
    
    if length(unique(vct)) > 1
        
        data_plot               = [];
        
        for nsub = 1:size(alldata,1)
            for ncond = 1:size(alldata,2)
                
                t1              = find(round(alldata{nsub,ncond}.time,2) == round(stat.time(1),2));
                t2              	= find(round(alldata{nsub,ncond}.time,2) == round(stat.time(end),2));
                t1              = t1(1);
                t2              = t2(end);
                
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
        
        mean_data               = nanmean(data_plot,1);
        bounds                  = nanstd(data_plot, [], 1);
        bounds_sem              = bounds ./ sqrt(size(data_plot,1));
        
        subplot(nrow,ncol,6:7);
        errorbar(mean_data,bounds_sem,'-ks');
        
        tests_done              = {};
        labl_for_title          = {};
        i                       = 0;
        for n_x = 1:size(alldata,2)
            for n_y = 1:size(alldata,2)
                
                tst_label   = [list_cond{n_x} ' vs ' list_cond{n_y}];
                rev_label   = [list_cond{n_y} ' vs ' list_cond{n_x}];
                
                flg         = find(strcmp(tests_done,tst_label));
                
                if isempty(flg)
                    [h_lu,p_lu]      	= ttest(data_plot(:,n_x),data_plot(:,n_y));
                    if p_lu < (0.05/20)
                        i                   = i +1;
                        tests_done          =[tests_done;tst_label;rev_label];
                        labl_for_title{i}   = [tst_label ' p = ' num2str(p_lu)];
                    end
                    clear h_lu p_lu tst_label rev_label flg
                end
                
                
            end
        end
        
        nb_con                  = size(alldata,2);
        
        xlim([0 nb_con+1]);
        xticks(1:nb_con);
        xticklabels(list_cond);
        ylim(cfg.z_limit);
        yticks(cfg.z_limit);
        hline(0,'--r');
        
        subplot(nrow,ncol,8);
        plot(0,0);
        title(labl_for_title);
        
    end
end

keep alldata list_cond stat