clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                                        = [1:33 35:36 38:44 46:51];
allpeaks                                        = [];

for nsuj = 1:length(suj_list)
    load(['J:/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.mat']);
    allpeaks(nsuj,1)                            = apeak; clear apeak;
    allpeaks(nsuj,2)                            = bpeak; clear bpeak;
end

allpeaks(isnan(allpeaks(:,2)),2)                = nanmean(allpeaks(:,2));

keep suj_list allpeaks

for nsuj = 1:length(suj_list)
    
    subjectName                                     = ['sub' num2str(suj_list(nsuj))];clc;
    i                                               = 0;
    
    for nback = [1 2]
        
        % load data from both sessions
        check_name                                  = dir(['J:/nback/tf_sens/' subjectName '.sess*.' num2str(nback) 'back.target.stim.1t100Hz.sens.mat']);

        for nf = 1:length(check_name)
            
            fname                                   = [check_name(nf).folder filesep check_name(nf).name];
            fprintf('loading %s\n',fname);
            load(fname);
            
            % baseline-correct
            cfg                                     = [];
            cfg.baseline                            = [-0.4 -0.2];
            cfg.baselinetype                        = 'relchange';
            freq_comb                               = ft_freqbaseline(cfg,freq_comb);
            
            tmp{nf}                                 = freq_comb; clear freq_comb;
            
        end
        
        % avearge both sessions
        freq                                        = ft_freqgrandaverage([],tmp{:}); clear tmp nf check_name;
        
        for test_band = {'alpha' 'beta'}
            
            switch test_band{:}
                case 'alpha'
                    bnd_width                     	= 1;
                    apeak                           = allpeaks(nsuj,1);
                    xi                             	= find(round(freq.freq) == round(apeak - bnd_width));
                    yi                            	= find(round(freq.freq) == round(apeak + bnd_width));
                case 'beta'
                    bnd_width                      	= 2;
                    apeak                           = allpeaks(nsuj,2);
                    xi                            	= find(round(freq.freq) == round(apeak - bnd_width));
                    yi                             	= find(round(freq.freq) == round(apeak + bnd_width));
            end
            
            avg                                     = [];
            avg.avg                                 = squeeze(mean(freq.powspctrm(:,xi:yi,:),2));
            avg.label                               = freq.label;
            avg.dimord                              = 'chan_time';
            avg.time                                = freq.time;
            
            i                                       = i + 1;
            alldata{nsuj,i}                         = avg; clear avg;            
            
            list_cond{i}                            = [test_band{:} ' B' num2str(nback)]; 
            
        end
    end
        
    newdata{nsuj,1}                                 = alldata{nsuj,1};
    newdata{nsuj,2}                                 = alldata{nsuj,1};
    
    newdata{nsuj,1}.avg                          	= (alldata{nsuj,1}.avg - alldata{nsuj,3}.avg);
    newdata{nsuj,2}.avg                          	= (alldata{nsuj,2}.avg - alldata{nsuj,4}.avg);
    
    keep newdata alldata allpeaks nsuj suj_list
    
end

alldata                                             = newdata;

keep alldata list_cond

%% compute anova

nb_suj                                              = size(alldata,1);
[design,neighbours]                                 = h_create_design_neighbours(nb_suj,alldata{1,1},'elekta','t');

cfg                                                 = [];
cfg.latency                                         = [-0.1 1];
cfg.statistic                                       = 'ft_statfun_depsamplesT';
cfg.method                                          = 'montecarlo';
cfg.correctm                                        = 'cluster';
cfg.clusteralpha                                    = 0.05;
cfg.clusterstatistic                                = 'maxsum';
cfg.minnbchan                                       = 3;
cfg.tail                                            = 0;
cfg.clustertail                                     = 0;
cfg.alpha                                           = 0.025;
cfg.numrandomization                                = 1000;
cfg.uvar                                            = 1;
cfg.ivar                                            = 2;
cfg.neighbours                                      = neighbours;
cfg.design                                          = design;

% alpha v beta
stat                                                = ft_timelockstatistics(cfg, alldata{:,1}, alldata{:,2});

%% plot

[min_p,p_val]            	= h_pValSort(stat);

stat.mask               	= stat.prob < 0.05;
stat2plot                 	= [];
stat2plot.avg             	= stat.mask .* stat.stat;
stat2plot.label          	= stat.label;
stat2plot.dimord         	= stat.dimord;
stat2plot.time              = stat.time;

cfg                         = [];
cfg.layout                  = 'neuromag306cmb.lay';
cfg.zlim                    = [-3 3];
%     cfg.ylim                    = [-0.6 0.35];
cfg.colormap                = brewermap(256,'*RdBu');
cfg.plimit                  = 0.05;
% cfg.vline                   = [0 1.5 3 4.5];
cfg.sign                    = [-1 1];
cfg.maskstyle               = 'highlight'; %'nan';
cfg.title                   = 'alpha v beta';
% cfg.xticks                  = cfg.vline;
% cfg.xticklabels             = {'1st Cue' '1st Gab' '2nd Cue' '2nd Gab'};

h_plotstat_2d(cfg,stat,alldata)