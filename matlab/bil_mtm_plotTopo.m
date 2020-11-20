clear ; close all;

suj_list                                = dir('../data/sub*/tf/*mtmconvol.comb.mat');
% suj_list                                = dir('../data/sub*/tf/*mtmconvol.mat');

for ns = 1:length(suj_list)
    
    fname                               = [suj_list(ns).folder '/' suj_list(ns).name];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    % this finds the freq structure loaded
    find_var                            = whos;
    find_var                            = {find_var.name};
    find_var                            = find(strcmp(find_var,'freq_axial'));
    
    cfg                                 = [];
    cfg.baseline                        = [-0.4 -0.2];
    cfg.baselinetype                    = 'relchange';
    
    if isempty(find_var)
        freq                            = ft_freqbaseline(cfg,freq_comb);
    else
        freq                            = ft_freqbaseline(cfg,freq_axial);
    end
    
    alldata{ns,1}                       = freq; clear freq;
    
end

keep alldata; clc;

gavg                                    = ft_freqgrandaverage([],alldata{:,1});

list_freq                               = [3 6; 8 11; 12 14; 17 30];
list_width                              = 0.3;
list_time                               = 0:list_width:7;

i                                       = 0;
ncol                                    = length(list_time)-1;
nrow                                    = length(list_freq);

for nf = 1:length(list_freq)
    for nt = 1:length(list_time)-1
        
        cfg                             = [];
        cfg.layout                      = 'CTF275_helmet.mat';
        cfg.marker                      = 'off';
        cfg.comment                     = 'no';
        cfg.colormap                    = brewermap(256, '*RdBu');
        cfg.zlim                        = 'maxabs';
        
        cfg.xlim                        = [list_time(nt) list_time(nt)+list_width];
        cfg.ylim                        = [list_freq(nf,1) list_freq(nf,2)];
        
        lgnd_freq                       = [num2str(cfg.ylim(1)) '-' num2str(cfg.ylim(2)) 'Hz'];
        lgnd_time                       = [num2str(cfg.xlim(1)) '-' num2str(cfg.xlim(2)) 's'];
        
        i                               = i +1;
        subplot(nrow,ncol,i);
        ft_topoplotER(cfg, gavg);
        title([lgnd_freq ' ' lgnd_time]);
        
    end
end

keep alldata; clc;