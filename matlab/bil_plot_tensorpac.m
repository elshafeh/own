clear;

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName           	= suj_list{nsuj};
    fname_out            	= ['F:/bil/pac/' subjectName '.KLD.ShuAmp.SubDivMean.100perm.pac.maxchan.mat'];
    fprintf('loading %s\n',fname_out);
    load(fname_out);
    
    freq                    = [];
    freq.powspctrm(1,:,:)   = mean(py_pac.xpac,3);
    freq.time               = py_pac.vec_pha;
    freq.freq               = py_pac.vec_amp;
    freq.label              = {'pac'};
    freq.dimord             = 'chan_freq_time';
    
    alldata{nsuj,1}         = freq; clear freq;
    
end

keep alldata 

cfg                                 = [];
cfg.marker                          = 'off';
cfg.comment                         = 'no';
cfg.colormap                        = brewermap(256, '*RdBu');
cfg.colorbar                        = 'no';
cfg.zlim                            = [0 0.01];
ft_singleplotTFR(cfg, ft_freqgrandaverage([],alldata{:}));