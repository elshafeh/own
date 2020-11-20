clear ; close all;

if isunix
    project_dir = '/project/3015079.01/';
else
    project_dir = 'P:/3015079.01/';
end

suj_list                            = dir([project_dir 'data/sub*/tf/*cuelock.itc.comb.5binned.allchan.minevoked.mat']);
% suj_list                            = dir([project_dir 'data/sub*/tf/*cuelock.itc.comb.5binned.allchan.mat']);

% exclude bad subjects
excl_list                           = {'sub007'};
new_suj_list                        = [];
for ns = 1:length(suj_list)
    if ~ismember(suj_list(ns).name(1:6),excl_list)
        i = i+1;
        new_suj_list                = [new_suj_list;suj_list(ns)];
    end
end

suj_list                            = new_suj_list; clear new_suj_list ns excl_list;

for ns = 1:length(suj_list)
    
    sujName                         = suj_list(ns).name(1:6);
    
    fname                           = [suj_list(ns).folder filesep suj_list(ns).name];
    fprintf('loading %s\n',fname);
    load(fname);
    
    list_legend                     = {};
    
    for nb = 1:length(phase_lock)
        
        freq                        = phase_lock{nb};
        freq                        = rmfield(freq,'rayleigh');
        freq                        = rmfield(freq,'p');
        freq                        = rmfield(freq,'sig');
        freq                        = rmfield(freq,'mask');
        freq                        = rmfield(freq,'mean_rt');
        freq                        = rmfield(freq,'med_rt');
        freq                        = rmfield(freq,'index');
        
        alldata{ns,nb}              = freq; clear freq;
        
    end
    
end

keep alldata

list_freq                           = [2 4; 4 6; 2 6];

nsuj                                = size(alldata,1);
[design,neighbours]                 = h_create_design_neighbours(nsuj,alldata{1,1},'meg','t'); clc;

cfg                                 = [];
cfg.method                          = 'ft_statistics_montecarlo';
cfg.statistic                       = 'ft_statfun_depsamplesFmultivariate';
cfg.correctm                        = 'cluster';
cfg.clusteralpha                    = 0.05;
cfg.clusterstatistic                = 'maxsum';
cfg.clusterthreshold                = 'nonparametric_common';
cfg.tail                            = 1; % For a F-statistic, it only make sense to calculate the right tail
cfg.clustertail                     = cfg.tail;
cfg.alpha                           = 0.05;
cfg.computeprob                     = 'yes';
cfg.numrandomization                = 1000;
cfg.neighbours                      = neighbours;
cfg.minnbchan                       = 4; % !!
cfg.alpha                           = 0.025;
cfg.numrandomization                = 1000;
cfg.design                          = design;

cfg.latency                         = [-0.2 6];

nbsuj                               = size(alldata,1);

design                              = zeros(2,5*nbsuj);
design(1,1:nbsuj)                   = 1;
design(1,nbsuj+1:2*nbsuj)           = 2;
design(1,nbsuj*2+1:3*nbsuj)         = 3;
design(1,nbsuj*3+1:4*nbsuj)         = 4;
design(1,nbsuj*4+1:5*nbsuj)         = 5;
design(2,:) = repmat(1:nbsuj,1,5);

cfg.design                          = design;
cfg.ivar                            = 1; % condition
cfg.uvar                            = 2; % subject number

for nfreq = 1:size(list_freq,1)
    
    f1                              = list_freq(nfreq,1);
    f2                              = list_freq(nfreq,2);
    list_stat{nfreq}                = ['p' num2str(abs(f1)) 'p' num2str(abs((f2)))];
    
    cfg.frequency                 	= list_freq(nfreq,:);
    cfg.avgoverfreq                 = 'yes';
    stat{nfreq}                     = ft_freqstatistics(cfg, alldata{:,1},alldata{:,2},alldata{:,3},alldata{:,4},alldata{:,5});
    stat{nfreq}                     = rmfield(stat{nfreq},'cfg');
    
end

keep alldata stat list_*

nrow                                = 3;
ncol                                = 3;
i                                   = 0;

for nfreq = 1:length(stat)
    
    stoplot                         = [];
    stoplot.time                    = stat{nfreq}.time;
    stoplot.label                   = stat{nfreq}.label;
    stoplot.dimord                  = 'chan_time';
    stoplot.avg                     = squeeze(stat{nfreq}.stat .* stat{nfreq}.mask);
    
    if length(unique(stoplot.avg)) > 1
        
        i                           = i + 1;
        subplot(nrow,ncol,i)
        
        cfg                         = [];
        cfg.layout                  = 'CTF275_helmet.mat'; %'CTF275.lay';
        cfg.marker                  = 'off';
        cfg.comment                 = 'no';
        cfg.colorbar                = 'no';
        cfg.colormap                = brewermap(256, '*Reds');
        cfg.ylim                    = 'zeromax';
        ft_topoplotER(cfg,stoplot);
        title(list_stat{nfreq});
        
        i = i +1;
        subplot(nrow,ncol,i)
        plot(stoplot.time,nanmean(stoplot.avg,1),'-k','LineWidth',2);
        xticks([0 1.5 3 4.5]);
        xticklabels({'1st cue','1st gab','2nd cue','2nd gab'});
        vline([0 1.5 3 4.5],'--k');
        title(list_stat{nfreq});
        
        i = i +1;
        subplot(nrow,ncol,i)
        
        data_plot                   = [];
        
        for nsuj = 1:size(alldata,1)
            for nbin = 1:size(alldata,2)
                
                cfg                 = [];
                cfg.channel      	= stat{nfreq}.label;
                cfg.latency     	= list_freq(nfreq,:);
                cfg.frequency     	= stat{nfreq}.freq([1 end]);
                cfg.avgovertime     = 'yes';
                tmp                 = ft_selectdata(cfg,alldata{nsuj,nbin});

                tmp                 = tmp.powspctrm .* squeeze(stat{nfreq}.mask);
                tmp(tmp == 0)       = NaN;
                tmp                 = nanmean(nanmean(tmp));
                
                data_plot(nsuj,nbin,:)  = tmp; clear tmp;
                
            end
        end
        
        mean_data               	= nanmean(data_plot,1);
        bounds                   	= nanstd(data_plot, [], 1);
        bounds_sem              	= bounds ./ sqrt(size(data_plot,1));
        
        errorbar(mean_data,bounds_sem,'-ks');
        
        xlim([0 6]);
        %         ylim([0 0.1]);
        xticks([1 2 3 4 5]);
        xticklabels({'Fastest','','Median','','Slowest'});
        
        [h2,p2]                 	= ttest(data_plot(:,1),data_plot(:,2));
        [h3,p3]                     = ttest(data_plot(:,1),data_plot(:,3));
        [h4,p4]                     = ttest(data_plot(:,1),data_plot(:,4));
        [h5,p5]                     = ttest(data_plot(:,1),data_plot(:,5));
        
        [h6,p6]                  	= ttest(data_plot(:,2),data_plot(:,3));
        [h7,p7]                 	= ttest(data_plot(:,2),data_plot(:,4));
        [h8,p8]                     = ttest(data_plot(:,2),data_plot(:,5));
        
        [h9,p9]                     = ttest(data_plot(:,3),data_plot(:,4));
        [h10,p10]               	= ttest(data_plot(:,3),data_plot(:,5));
        
        [h11,p11]                  	= ttest(data_plot(:,4),data_plot(:,5));
        
        list_group                  = {[1 2],[1 3],[1 4],[1 5],[2 3],[2 4],[2 5],[3 4],[3 5],[4 5]};
        list_p                      = [p2 p3 p4 p5 p6 p7 p8 p9 p10 p11];
        
        %         sigstar(list_group,list_p)
        
    end
end
