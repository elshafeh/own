clear;

list_suj                                    = {};
for j = 1:9
    list_suj{j,1}                           = ['sub00', num2str(j)];
end
for k = [10:12,17,18,20:22,24:30]
    j                                       = j+1;
    list_suj{j,1}                           = ['sub0', num2str(k)];
end

list_name                                   = {'open.both','closed.both'};
alldata                                     = {};

for n_suj = 1:24
    for n_eyes = 1:2
        
        subjectName                         = list_suj{n_suj};
        ext_name                            = ['stimloc.fft.comb.' list_name{n_eyes}];
        dir_data                            = ['P:/3015039.05/data/' subjectName '/tf/'];
        
        fname                               = [dir_data subjectName '_' ext_name '.mat'];
        fprintf('Loading %s\n',fname);
        load(fname);
        
        freq                                = ft_freqdescriptives([],freq_comb);
        
        alldata{n_suj,n_eyes}               = freq; clear freq
        
    end
end

keep alldata

load P:/3015039.05/data/all_sub/fft_stat_open_vs_closed.mat

cfg                         = [];
cfg.plimit                  = 0.05;
cfg.legend                  = {'open' ' closed'};
cfg.layout                  = 'CTF275_helmet.mat';
cfg.colormap                = brewermap(256,'*RdBu');
cfg.maskstyle               = 'highlight';
h_plotstat_2d(cfg,stat,alldata);