clear;

ext_name                                        = 'gratinglock.erfComb';
suj_list                                        = dir(['../data/*/erf/*' ext_name '.mat']);

nrow                                            = 4;
ncol                                            = 3;
i                                               = 0;

for ns = 1:length(suj_list)
    
    subjectName                                 = suj_list(ns).name(1:6);
    
    fname                                       = [suj_list(ns).folder '/' suj_list(ns).name];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    fname                                       = [suj_list(ns).folder '/' subjectName '.gratinglock.erfComb.max20chan.p0p200ms.postOnset.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    cfg                                         = [];
    cfg.layout                                  = 'CTF275.lay';
    cfg.marker                                  = 'off';
    cfg.comment                                 = 'no';
    cfg.colormap                                = brewermap(256, '*RdBu');
    cfg.zlim                                    = 'maxabs';
    cfg.xlim                                    = [0 0.2];
    cfg.ylim                                    = 'maxabs';
    
    cfg.highlight                               = 'on';
    cfg.highlightchannel                        =  max_chan;
    cfg.highlightsymbol                         = '.';
    cfg.highlightcolor                          = [0 0 0];
    cfg.highlightsize                           = 10;
    
    i                                           = i + 1;
    subplot(nrow,ncol,i);
    ft_topoplotER(cfg, avg_comb);
    title(subjectName);
    
end
