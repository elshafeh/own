clear ; close all;

suj_list                   = dir('../data/sub*/tf/*cuelock.itc.comb.5binned.mat');

for ns = 1:length(suj_list)
    
    sujName                = suj_list(ns).name(1:6);
    
    fname                  = [suj_list(ns).folder '/' suj_list(ns).name];
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
        
        cfg                 = [];
        cfg.avgoverchan     = 'yes';
        freq                = ft_selectdata(cfg,freq);
        freq.label          = {'itc_avg'};
        
        alldata{ns,nb}      = freq; clear freq;
        
    end
    
end

keep alldata

list_test                   = [1 5; 1 4; 1 3; 1 2; 2 3; 2 4; 2 5; 3 4; 3 5; 4 5];

nsuj                        = size(alldata,1);
[design,neighbours]         = h_create_design_neighbours(nsuj,alldata{1,1},'virt','t'); clc;

cfg                         = [];
cfg.clusterstatistic        = 'maxsum';cfg.method = 'montecarlo';
cfg.correctm                = 'cluster';cfg.statistic = 'depsamplesT';
cfg.uvar                    = 1;cfg.ivar = 2;
cfg.tail                    = 0;cfg.clustertail  = 0;
cfg.neighbours              = neighbours;

cfg.clusteralpha            = 0.05; % !!
cfg.minnbchan               = 0; % !!

cfg.alpha                   = 0.025;

cfg.numrandomization        = 1000;
cfg.design                  = design;

list_name                   = {};

for nt = 1:size(list_test,1)
    
    ix1                     = list_test(nt,1);
    ix2                     = list_test(nt,2);
    
    list_name{nt}           = ['RT' num2str(ix1) ' versus RT' num2str(ix2)];
    
    stat{nt}                = ft_freqstatistics(cfg, alldata{:,ix1},alldata{:,ix2});
    stat{nt}                = rmfield(stat{nt},'cfg');
    
end

keep stat alldata list_name

for nt = 1:length(stat)
    
    [min_p(nt), p_val{nt}]   = h_pValSort(stat{nt});
    
end

p_limit                     = 0.05/length(stat);

nrow                        = 3;%length(find(min_p < p_limit));
ncol                        = 3; %length(find(min_p < p_limit));
i                           = 0;

for nt = 1:length(stat)
    if min_p(nt) < p_limit
        
        stoplot             = stat{nt};
        stoplot.mask        = stoplot.prob < p_limit;
        
        cfg                 = [];
        cfg.parameter       = 'stat';
        cfg.maskparameter   = 'mask';
        cfg.maskstyle       = 'opacity'; %'outline'; % 'opacity';
        cfg.maskalpha       = 0.2; % 0 (transparent) and 1 (opaque)
        cfg.colormap        = brewermap(256, '*RdBu');
        cfg.zlim            = 'maxabs';
        
        i                   = i + 1;
        subplot(nrow,ncol,i)
        ft_singleplotTFR(cfg,stoplot);
        title(list_name{nt});
        
        list_lines          = {'cue1','grat1','cue2','grat2'};
        
        vline([0 1.5 3 4.5],{'--k','--k','--k','--k'},list_lines);
        
    end
end