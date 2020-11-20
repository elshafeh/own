clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                         	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    subjectName                  	= ['sub' num2str(suj_list(nsuj))];clc;
    
    list_nback                   	= [0 1 2];
    list_cond                       = {'0back','1back','2Back'};
    
    list_cond                       = list_cond(list_nback+1);
    list_freq                       = 1:30;
    
    for nback = 1:length(list_nback)
        
        check_name                              = dir(['J:/temp/nback/data/tf_sens/' subjectName '.sess*.' num2str(nback-1) 'back.target.stim.1t100Hz.sens.mat']);
        
        for nf = 1:length(check_name)
            fname                               = [check_name(nf).folder filesep check_name(nf).name];
            fprintf('loading %s\n',fname);
            load(fname);
            
            
            % baseline-correct
            cfg                                 = [];
            cfg.baseline                        = [-0.4 -0.2];
            cfg.baselinetype                    = 'relchange';
            freq_comb                           = ft_freqbaseline(cfg,freq_comb);
            tmp{nf}                             = freq_comb; clear freq_comb;
            
        end
        
        % avearge both sessions
        alldata{nsuj,nback}               	= ft_freqgrandaverage([],tmp{:}); clear tmp nf check_name;
        
    end
end

keep alldata

nbsuj                       = size(alldata,1);
[~,neighbours]              = h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

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
cfg.latency                 = [0 2];
cfg.frequency               = [3 100];

design                      = zeros(2,3*nbsuj);
design(1,1:nbsuj)           = 1;
design(1,nbsuj+1:2*nbsuj)   = 2;
design(1,nbsuj*2+1:3*nbsuj) = 3;
design(2,:) = repmat(1:nbsuj,1,3);
cfg.design                  = design;
cfg.ivar                    = 1; % condition
cfg.uvar                    = 2; % subject number

stat                        = ft_freqstatistics(cfg, alldata{:,1}, alldata{:,2}, alldata{:,3});

for nsuj = 1:size(alldata,1)
    for ncond = 1:size(alldata,2)
        cfg                      	= [];
        cfg.channel              	= stat.label;
        cfg.latency                 = stat.time([1 end]);
        newalldata{nsuj,ncond}     	= ft_selectdata(cfg,alldata{nsuj,ncond});
    end
    clc;
end

nrow                                = 4;
ncol                            	= 4;
i                                   = 0;

for ncluster = 1:2
    
    tmp_mat                      	= stat.posclusterslabelmat;
    tmp_mat(tmp_mat~= ncluster)  	= 0;
    
    stoplot                      	= [];
    stoplot.time                 	= stat.time;
    stoplot.freq                 	= stat.freq;
    stoplot.label               	= stat.label;
    stoplot.dimord                	= 'chan_freq_time';
    stoplot.powspctrm           	= squeeze(stat.stat .* stat.mask .* tmp_mat);
    
    i                              	= i + 1;
    subplot(nrow,ncol,i)
    
    cfg                           	= [];
    cfg.layout                  	= 'neuromag306cmb.lay';
    cfg.marker                      = 'off';
    cfg.comment                  	= 'no';
    cfg.colorbar                	= 'no';
    cfg.colormap                    = brewermap(256, '*Reds');
    ft_topoplotTFR(cfg,stoplot);
    
    i = i +1;
    subplot(nrow,ncol,i)
    cfg                         = [];
    ft_singleplotTFR(cfg,stoplot);
    title('');
    
end