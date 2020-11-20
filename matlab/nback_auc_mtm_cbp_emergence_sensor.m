clear ;

global ft_default
ft_default.spmversion = 'spm12';

load ../data/suj_list_peak.mat
i = 0;

for n_suj = [1:length(suj_list)-2 length(suj_list)]
    
    i                                           = i+1;
    
    load ~/Dropbox/project_nback/data/grad1forstats.mat
    list_chan                                   = grad.label; clear grad;
    
    list_condition                              = {'0v1B','0v2B','1v2B'};
    list_freq                                   = 5:30;
    
    pow                                         = [];
    
    for n_con = 1:length(list_condition)
        
        for n_freq = 1:length(list_freq)
            
            fname                               = '/Volumes/h128ssd/auc_freq_break/';
            fname                               = [fname 'sub' num2str(suj_list(n_suj)) '.' list_condition{n_con} '.' num2str(list_freq(n_freq)) '.auc.bychan.mat'];
            fprintf('loading %s\n',fname);
            load(fname);
            
            pow(:,n_freq,:)                     = scores; clear scores;
            
        end
        
        freq                                    = [];
        freq.time                               = -1.5:0.05:6;
        freq.label                              = list_chan;
        freq.freq                               = list_freq;
        freq.powspctrm                          = pow;
        freq.dimord                             = 'chan_freq_time';
        
        alldata{i,n_con}                        = freq; clear freq;
        
    end
    
    alldata{i,4}                                = alldata{i,1};
    alldata{i,4}.powspctrm(:)                   = 0.5;
    
end

keep alldata list_*;

nb_suj                                          = size(alldata,1);
[design,neighbours]                             = h_create_design_neighbours(nb_suj,alldata{1,1},'elekta','t');

cfg                                             = [];
cfg.latency                                     = [-0.2 5];
cfg.statistic                                   = 'ft_statfun_depsamplesT';
cfg.method                                      = 'montecarlo';
cfg.correctm                                    = 'cluster';
cfg.clusteralpha                                = 0.05;
cfg.clusterstatistic                            = 'maxsum';
cfg.minnbchan                                   = 2;
cfg.tail                                        = 0;
cfg.clustertail                                 = 0;
cfg.alpha                                       = 0.025;
cfg.numrandomization                            = 1000;
cfg.uvar                                        = 1;
cfg.ivar                                        = 2;
cfg.neighbours                                  = neighbours;
cfg.design                                      = design;

for nt = 1:3
    stat{nt}                                    = ft_freqstatistics(cfg, alldata{:,nt}, alldata{:,4});
end

for nt = 1:length(stat)
    [min_p(nt),p_val{nt}]                       = h_pValSort(stat{nt});
end

keep alldata list_* stat min_p p_val;

for nt = 1:length(stat)
    
    subplot(2,2,nt)
    
    plimit                                      = 0.2;
    statplot                                    = h_plotStat(stat{nt},10e-13,plimit,'stat');
    
    cfg                                         = [];
    cfg.layout                              	= 'neuromag306cmb.lay';
    cfg.zlim                                    = [-3 3];
    cfg.marker                                  = 'off';
    ft_topoplotTFR(cfg,statplot);
    title('');
    
end