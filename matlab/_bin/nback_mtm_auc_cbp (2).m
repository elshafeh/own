clear ;

global ft_default
ft_default.spmversion = 'spm12';

i                                               = 0;

for ns = [1:33 35:36 38:44 46:51]
    
    fname                                       = ['../data/decode_data/auc/data' num2str(ns) '.3stacked.dwsmple.freqbreak.auc.mat'];
    fprintf('Loading %s\n',fname);
    load(fname);
    time_width                                  = 0.02;
    freq_width                                  = 1;
    
    time_list                                   = -1:time_width:6;
    freq_list                                   = 1:freq_width:50;
    
    freq                                        = [];
    freq.dimord                                 = 'chan_freq_time';
    freq.label                                  = {'0v1','0v2','1v2'};
    freq.freq                                   = freq_list;
    freq.time                                   = time_list;
    freq.powspctrm                              = scores ; clear scores;
    
    i                                           = i + 1;
    alldata{i,1}                                = freq; clear freq;
    
    alldata{i,2}                                = alldata{i,1};
    alldata{i,2}.powspctrm(:)                   = 0.5;
    
end

cfg                                             = [];

cfg.channel                                     = [2 3];

cfg.statistic                                   = 'ft_statfun_depsamplesT';
cfg.method                                      = 'montecarlo';
cfg.correctm                                    = 'cluster';
cfg.clusteralpha                                = 0.0001;

cfg.clusterstatistic                            = 'maxsum';
cfg.minnbchan                                   = 0;
cfg.tail                                        = 0;
cfg.clustertail                                 = 0;
cfg.alpha                                       = 0.025;
cfg.numrandomization                            = 1000;
cfg.uvar                                        = 1;
cfg.ivar                                        = 2;

cfg.latency                                     = [0 5];
cfg.frequency                                   = [2 50];

nbsuj                                           = size(alldata,1);
[design,neighbours]                             = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg.design                                      = design;
cfg.neighbours                                  = neighbours;
    
stat                                            = ft_freqstatistics(cfg, alldata{:,1}, alldata{:,2});

[min_p,p_val]                                   = h_pValSort(stat) ;

for np = 1:size(p_val,2)
    
    fc_p                                        = p_val(1,np);
    
    if fc_p < 0.05
        
        
        lm1                                     = p_val(1,np) - 0.0000001;
        lm2                                     = p_val(1,np) + 0.0000001;
        
        statplot                                = h_plotStat(stat,lm1,lm2);
        figure;
        
        for nchan = 1:length(stat.label)
            
            subplot(2,1,nchan)
            
            cfg                                 = [];
            cfg.channel                         = statplot.label{nchan};
            cfg.marker                          = 'off';
            cfg.comment                         = 'no';
            cfg.colormap                        = brewermap(256, '*RdBu');
            cfg.colorbar                        = 'yes';
            
            cfg.zlim                            = 'maxmin';
            
            ft_singleplotTFR(cfg, statplot);
            
            for nv = [2 4]
                vline(nv,'--k');
            end
            
        end
    end
end