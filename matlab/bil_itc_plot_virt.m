clear ; close all;

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName             = suj_list{nsuj};
    fname                   = ['P:/3015039.06/bil/tf/' subjectName '.obob.itc.correct.withevoked.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    freq                    = phase_lock;
    freq                    = rmfield(freq,'rayleigh');
    freq                    = rmfield(freq,'p');
    freq                    = rmfield(freq,'sig');
    freq                    = rmfield(freq,'mask');
    
    alldata{nsuj,1}         = freq; clear freq;
        
end

keep alldata

vct_vis             = [];

for nchan = 1:length(alldata{1}.label)
   
    tmplte          = alldata{1}.label{nchan};
    fnd             = strfind(tmplte,'Vis');
    if ~isempty(fnd)
        vct_vis     = [vct_vis;nchan];
    end
    
end

keep alldata vct_vis

load('../data/stock/obob_parcellation_grid_5mm.mat');

cfg                     = [];
cfg.zlim                = 'zeromax';
cfg.ylim                = [1 8];
cfg.layout              = parcellation.layout;
cfg.colormap            = brewermap(256, '*Reds');
cfg.marker              = 'off';
cfg.highlight           = 'on';
cfg.highlightchannel    =  vct_vis;
cfg.highlightsymbol     = '.';
cfg.highlightsize       = 10;
ft_topoplotTFR(cfg,ft_freqgrandaverage([],alldata{:,1}));