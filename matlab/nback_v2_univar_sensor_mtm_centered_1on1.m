clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                    = [1:33 35:36 38:44 46:51];
allpeaks                    = [];

for nsuj = 1:length(suj_list)
    load(['J:/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.mat']);
    allpeaks(nsuj,1)        = apeak; clear apeak;
    allpeaks(nsuj,2)        = bpeak; clear bpeak;
end

allpeaks(isnan(allpeaks(:,2)),2)                = nanmean(allpeaks(:,2));

keep suj_list allpeaks

test_band                   = 'beta';

for nsuj = 1:length(suj_list)
    
    subjectName             = ['sub' num2str(suj_list(nsuj))];clc;
    
    for nback = [1 2]
        
        % load data from both sessions
        check_name          = dir(['J:/nback/tf_sens/' subjectName '.sess*.' num2str(nback) 'back.target.stim.1t100Hz.sens.mat']);
        
        for nf = 1:length(check_name)
            
            fname           = [check_name(nf).folder filesep check_name(nf).name];
            fprintf('loading %s\n',fname);
            load(fname);
            
            % baseline-correct
            cfg             = [];
            cfg.baseline    = [-0.4 -0.2];
            cfg.baselinetype= 'relchange';
            freq_comb       = ft_freqbaseline(cfg,freq_comb);
            
            tmp{nf}         = freq_comb; clear freq_comb;
            
        end
        
        % avearge both sessions
        freq                = ft_freqgrandaverage([],tmp{:}); clear tmp nf check_name;
        
        switch test_band
            case 'alpha'
                bnd_width  	= 1;
                apeak       = allpeaks(nsuj,1);
                xi         	= find(round(freq.freq) == round(apeak - bnd_width));
                yi       	= find(round(freq.freq) == round(apeak + bnd_width));
            case 'beta'
                bnd_width  	= 2;
                apeak       = allpeaks(nsuj,2);
                xi         	= find(round(freq.freq) == round(apeak - bnd_width));
                yi         	= find(round(freq.freq) == round(apeak + bnd_width));
        end
        
        avg                 = [];
        avg.avg             = squeeze(mean(freq.powspctrm(:,xi:yi,:),2));
        avg.label         	= freq.label;
        avg.dimord        	= 'chan_time';
        avg.time          	= freq.time; clear freq;
        
        alldata{nsuj,nback} 	= avg; clear avg;
        
    end
end

keep alldata test_band

%% run stat

nb_suj                      = size(alldata,1);
[design,neighbours]         = h_create_design_neighbours(nb_suj,alldata{1,1},'elekta','t');

cfg                         = [];
cfg.latency                 = [-0.1 1];
cfg.statistic               = 'ft_statfun_depsamplesT';
cfg.method                  = 'montecarlo';
cfg.correctm                = 'cluster';
cfg.clusteralpha            = 0.05;
cfg.clusterstatistic        = 'maxsum';
cfg.minnbchan               = 4;
cfg.tail                    = 0;
cfg.clustertail             = 0;
cfg.alpha                   = 0.025;
cfg.numrandomization        = 1000;
cfg.uvar                    = 1;
cfg.ivar                    = 2;
cfg.neighbours              = neighbours;
cfg.design                  = design;

% 1back v 2back
stat                        = ft_timelockstatistics(cfg, alldata{:,1}, alldata{:,2});
[min_p, p_val]              = h_pValSort(stat);

keep alldata test_band stat min_p p_val

%% plot

nrow                        = 2;
ncol                        = 2;

stat.mask                   = stat.prob < 0.1;

statplot                    = [];
statplot.time               = stat.time;
statplot.label              = stat.label;
statplot.dimord             = stat.dimord;
statplot.avg                = stat.mask .* stat.stat;

cfg                       	= [];
cfg.layout               	= 'neuromag306cmb.lay';
cfg.zlim                 	= [-1 1];
cfg.colormap              	= brewermap(256,'*RdBu');
cfg.marker                	= 'off';
cfg.comment                	= 'no';
cfg.colorbar               	= 'yes';
subplot(nrow,ncol,1);
ft_topoplotER(cfg,statplot);

switch test_band
    case 'alpha'
        list_chan           = {'MEG2222+2223', 'MEG2232+2233', 'MEG2312+2313', 'MEG2322+2323','MEG2342+2343', 'MEG2412+2413', 'MEG2442+2443', 'MEG2512+2513'};
    case 'beta'
        list_chan          	= {'MEG0732+0733', 'MEG0742+0743','MEG1822+1823', 'MEG1832+1833', 'MEG1842+1843', 'MEG2212+2213', 'MEG2232+2233', 'MEG2242+2243'};
end

cfg                      	= [];
cfg.channel             	= list_chan;
cfg.time_limit             	= stat.time([1 end]);
cfg.color                  	= {'-g' '-b'};
cfg.z_limit                	= [-0.3 0.3];
cfg.linewidth              	= 10;
subplot(nrow,ncol,3);
h_plotSingleERFstat_selectChannel_nobox(cfg,stat,alldata);
xlim(statplot.time([1 end]));
vline(0,'--k');
hline(0,'--k');
xticks([0 0.2 0.4 0.6 0.8 1]);