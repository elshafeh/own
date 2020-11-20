clear ; close all;

if isunix
    project_dir = '/project/3015079.01/';
else
    project_dir = 'P:/3015079.01/';
end

suj_list                    = dir([project_dir 'data/sub*/tf/*cuelock.itc.comb.5binned.allchan.mat']);

% exclude bad subjects
excl_list                   = {'sub007'};
new_suj_list            	= [];
for ns = 1:length(suj_list)
    if ~ismember(suj_list(ns).name(1:6),excl_list)
        i = i+1;
        new_suj_list        = [new_suj_list;suj_list(ns)];
    end
end

suj_list                    = new_suj_list; clear new_suj_list ns excl_list;

for ns = 1:length(suj_list)
    
    sujName                = suj_list(ns).name(1:6);
    
    fname                  = [suj_list(ns).folder filesep suj_list(ns).name];
    fprintf('loading %s\n',fname);
    load(fname);
    
    list_legend            = {};
    
    for nb = 1:length(phase_lock)
        
        freq                = phase_lock{nb};
        freq                = rmfield(freq,'rayleigh');
        freq                = rmfield(freq,'p');
        freq                = rmfield(freq,'sig');
        freq                = rmfield(freq,'mask');
        freq                = rmfield(freq,'mean_rt');
        freq                = rmfield(freq,'med_rt');
        freq                = rmfield(freq,'index');
        
        alldata{ns,nb}      = freq; clear freq;
        
        alldata_beh{ns,nb}  = nb;%phase_lock{nb}.med_rt;
        
    end
end

clearvars -except alldata*

nsuj                        = size(alldata,1);
[~,neighbours]              = h_create_design_neighbours(nsuj,alldata{1,1},'meg','t'); clc;

design_1                	= [];

for nsuj = 1:size(alldata,1)
    tmp                     = [[alldata_beh{nsuj,:}]; 1:size(alldata,2)];
    design_1            	= [design_1 tmp]; clear tmp;
end

design_2                	= [];

for nsuj = 1:size(alldata,1)
    tmp                     = [[alldata_beh{nsuj,:}]; repmat(nsuj,1,size(alldata,2))];
    design_2                = [design_2 tmp]; clear tmp;
end

cfg                         = [];
cfg.method                  = 'ft_statistics_montecarlo';
cfg.statistic               = 'ft_statfun_indepsamplesregrT';
cfg.correctm                = 'cluster';
cfg.clusteralpha            = 0.05;
cfg.clusterstatistic        = 'maxsum';
cfg.tail                     = 0; 
cfg.clustertail             = cfg.tail;
cfg.alpha                   = 0.05;
cfg.computeprob             = 'yes';
cfg.numrandomization        = 1000;
cfg.neighbours              = neighbours;
% cfg.latency                 = [0 5];
% cfg.frequency               = [1 10];
cfg.minnbchan               = 4; % !!
cfg.clustercritval          = 0.05;

cfg.alpha                   = 0.025;
cfg.numrandomization        = 1000;


cfg.ivar                    = 1; % row number of the design that contains the independent variable
% cfg.uvar                    = 2; % row number of the design that contains the independent variable

cfg.design                  = design_1;
stat{1}                   	= ft_freqstatistics(cfg, alldata{:,1},alldata{:,2},alldata{:,3},alldata{:,4},alldata{:,5});

cfg.design                  = design_2;
stat{2}                   	= ft_freqstatistics(cfg, alldata{:,1},alldata{:,2},alldata{:,3},alldata{:,4},alldata{:,5});

for nt = 1:length(stat)
   
    stat{nt}.mask               = stat{nt}.prob < 0.2;
    
    stoplot                     = [];
    stoplot.freq                = stat{nt}.freq;
    stoplot.time                = stat{nt}.time;
    stoplot.label            	= stat{nt}.label;
    stoplot.dimord            	= stat{nt}.dimord;
    stoplot.powspctrm        	= stat{nt}.stat .* stat{nt}.mask;
    
    subplot(2,1,nt)
    
    cfg                         = [];
    cfg.layout                  = 'CTF275.lay';
    cfg.marker                  = 'off';
    cfg.comment                 = 'no';
    cfg.colorbar                = 'no';
    cfg.colormap                = brewermap(256, '*RdBu');
    cfg.zlim                    = 'maxabs';
    ft_topoplotTFR(cfg,stoplot);
    
end