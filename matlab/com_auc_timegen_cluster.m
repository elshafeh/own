clear ; close all;

suj_list                                            = [1:4 8:17];

for ns = 1:length(suj_list)
    
    for ndata = 1:2
        
        for nfeat = 1:2
            
            list_data                               = {'meg','eeg'};
            list_feat                               = {'inf.unf','left.right'};
            list_part                               = {{'CnD.com90roi'},{'CnD.com90roi'}}; % {{'pt1.CnD','pt2.CnD','pt3.CnD'},{'CnD'}};
            
            for np = 1:length(list_part{ndata})
                
                fname                               = ['data/timegen/yc' num2str(suj_list(ns)) '.' list_part{ndata}{np} '.' list_data{ndata} '.' list_feat{nfeat} '.timegen.mat'];
                fprintf('loading %s\n',fname);
                load(fname);
                
                for x = 1:size(scores,1)
                    for y = 1:size(scores,2)
                        
                        if x == y
                            scores(x,y)             = NaN;
                        end
                        
                        for n = 1:size(scores,1)
                            if n > x
                                scores(x,n)         = NaN;
                            end
                        end
                        
                    end
                end
                
                p_carr(np,:,:)                      = scores; clear scores;
                
            end
            
            f_carr(nfeat,:,:)                       = squeeze(mean(p_carr,1)); clear p_carr;
            
        end
        
        freq                                        = [];
        freq.time                                   = time_axis;
        freq.freq                                   = time_axis;
        freq.label                                  = {'INF VS UNF','LEFT VS RIGHT'};
        freq.dimord                                 = 'chan_freq_time';
        freq.powspctrm                              = f_carr; clear f_carr;
        
        clear tmp;
        
        alldata{ns,ndata}                           = freq; clear freq;
        
    end
end

keep alldata list_*

nsuj                                            = size(alldata,1);
[design,neighbours]                             = h_create_design_neighbours(nsuj,alldata{1,1},'virt','t'); clc;

cfg                                             = [];
cfg.neighbours                                  = neighbours;
cfg.minnbchan                                   = 0;

cfg.clusterstatistic                            = 'maxsum';
cfg.method                                      = 'montecarlo';
cfg.statistic                                   = 'depsamplesT';

cfg.correctm                                    = 'cluster';

cfg.clusteralpha                                = 0.05;
cfg.alpha                                       = 0.025;

cfg.tail                                        = 0;
cfg.clustertail                                 = 0;
cfg.numrandomization                            = 1000;
cfg.design                                      = design;
cfg.uvar                                        = 1;
cfg.ivar                                        = 2;

stat                                            = ft_freqstatistics(cfg,alldata{:,1},alldata{:,2});

keep alldata roi_label list_* stat

[min_p,p_val]                                   = h_pValSort(stat);

close all;

p_limit                                         = 0.3;
stat.mask                                       = stat.prob < p_limit;

figure;
i                                               = 0;

for nfeat = 1:2
    
    i                                           = i + 1;
    subplot(1,2,i)
    
    cfg                                         = [];
    cfg.colormap                                = brewermap(256, 'Spectral');
    
    cfg.xlim                                    = [0 2];
    cfg.ylim                                    = cfg.xlim;
    
    cfg.channel                                 = nfeat;
    cfg.parameter                               = 'prob';
    cfg.maskparameter                           = 'mask';
    cfg.maskstyle                               = 'outline';
    cfg.zlim                                    = [10e-4 p_limit];
    ft_singleplotTFR(cfg,stat);
    
    title(upper(stat.label{nfeat}));
    set(gca,'FontSize',20,'FontName', 'Calibri');
    
end