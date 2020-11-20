clear ; close all;

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName             = suj_list{nsuj};
    
    fname                   =  ['P:/3015039.06/bil/tf/' subjectName '.obob.itc.correct.5binned.withevoked.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    for nbin = 1:length(phase_lock)
        
        freq                = phase_lock{nbin};
        freq                = rmfield(freq,'rayleigh');
        freq                = rmfield(freq,'p');
        freq                = rmfield(freq,'sig');
        freq                = rmfield(freq,'mask');
        freq                = rmfield(freq,'mean_rt');
        freq                = rmfield(freq,'med_rt');
        freq                = rmfield(freq,'index');
        
        alldata{nsuj,nbin}	= freq; clear freq;
        
    end
    
end

keep alldata

tot_nb_suj                	= size(alldata,1);
[design,~]                  = h_create_design_neighbours(tot_nb_suj,alldata{1,1},'meg','t'); clc;

load('../data/stock/obob_parcellation_grid_5mm.mat');

cfg                         = [];
cfg.method                  = 'triangulation';
cfg.layout                  = parcellation.layout;
neighbours                  = ft_prepare_neighbours(cfg);

keep alldata neighbours design

list_test                       = [1 5];
list_name                       = {};
i                               = 0;

for ntest = 1:size(list_test,1)
    
    cfg                         = [];
    cfg.clusterstatistic        = 'maxsum';cfg.method = 'montecarlo';
    cfg.correctm                = 'cluster';cfg.statistic = 'depsamplesT';
    cfg.uvar                    = 1;cfg.ivar = 2;
    cfg.tail                    = 0;cfg.clustertail  = 0;
    cfg.neighbours              = neighbours;
    
    
    cfg.clusteralpha            = 0.05; % !!
    cfg.minnbchan               = 3; % !!
    
    cfg.alpha                   = 0.025;
    
    cfg.numrandomization        = 1000;
    cfg.design                  = design;
    
    list_time                   = [0 6];
    
    for ntime = 1:size(list_time,1)
        
        i                       = i +1;
        
        ix1                     = list_test(ntest,1);
        ix2                     = list_test(ntest,2);
        
        cfg.latency             = list_time(ntime,:);
        
        list_name{i}            = ['RT bin' num2str(ix1) ' versus RT bin' num2str(ix2) ' window' num2str(ntime)];
        stat{i}                 = ft_freqstatistics(cfg, alldata{:,ix1},alldata{:,ix2});
        
    end
    
end

keep stat alldata list_name

for ntest = 1:length(stat)
    [min_p(ntest), p_val{ntest}]   = h_pValSort(stat{ntest});
end

keep stat alldata list_name min_p

load('../data/stock/obob_parcellation_grid_5mm.mat');

p_limit                 = 0.05;

nrow                    = 1;
ncol                    = 1;
i                       = 0;
z_limit                 = [0 1];

for ntest = 1:length(stat)
    if min_p(ntest) < p_limit
        
        stoplot         = h_plotStat(stat{ntest},10e-26,p_limit,'stat');
        
        cfg             = [];
        cfg.layout      = parcellation.layout;
        cfg.marker      = 'off';
        cfg.comment     = 'no';
        cfg.colorbar    = 'no';
        cfg.colormap    = brewermap(256, '*RdBu');
        cfg.zlim        = 'maxabs';
        
        i               = i + 1;
        subplot(nrow,ncol,i)
        ft_topoplotTFR(cfg,stoplot);
        title(list_name{ntest});
        
    end
end