clear ; close all;

global ft_default
ft_default.spmversion = 'spm12';

suj_list                                        = [1:4 8:17];

for ns = 1:length(suj_list)
    
    list_data                                   = {'meg','eeg'};
    
    for ndata = 1:length(list_data)
        
        list_feat                               = {'inf.unf','left.right','left.inf','right.inf'};
        
        for nfeat = 1:length(list_feat)
            
            
            for nfreq = 1:19
                
                if strcmp(list_data{ndata},'eeg')
                    
                    fname                       = ['../data/mtm/yc' num2str(suj_list(ns)) '/yc' num2str(suj_list(ns)) '.CnD.' list_data{ndata} '.' list_feat{nfeat} '.' num2str(nfreq) 'Hz.auc.mat'];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    
                    tmp(nfeat,nfreq,:)          = scores; clear scores;
                    
                else
                    
                    for np = 1:3
                        fname                   = ['../data/mtm/yc' num2str(suj_list(ns)) '/yc' num2str(suj_list(ns)) '.pt' num2str(np) '.CnD.' list_data{ndata} '.' list_feat{nfeat} '.' num2str(nfreq) 'Hz.auc.mat'];
                        fprintf('loading %s\n',fname);
                        load(fname);
                        sc_carr(np,:,:)         = scores ; clear scores;
                    end
                    
                    tmp(nfeat,nfreq,:)          = mean(sc_carr,1); clear sc_carr;
                    
                end
                
            end
            
        end
        
        time_width                              = 0.03;
        freq_width                              = 1;
        
        time_list                               = -1:time_width:2.5;
        freq_list                               = 1:freq_width:nfreq;
        
        freq                                    = [];
        freq.time                               = time_list;
        freq.freq                               = freq_list;
        freq.label                              = {'INF VS UNF','LEFT VS RIGHT','LEFT VS UNF','RIGHT VS UNF'};
        freq.dimord                             = 'chan_freq_time';
        freq.powspctrm                          = tmp;
        
        clear tmp;
        
        alldata{ns,ndata}                       = freq; clear freq;
        
    end
end

keep alldata list_data

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

[min_p,p_val]                                   = h_pValSort(stat);

stat.mask                                       = stat.prob < 0.2;

figure;
i                                               = 0;

for nchan = 1:length(stat.label)
    
    tmp                                     = stat.mask(nchan,:,:) .* stat.prob(nchan,:,:);
    ix                                      = unique(tmp);
    ix                                      = ix(ix~=0);
    
    if ~isempty(ix)
        
        i                                   = i + 1;
        subplot(2,2,i)
        
        cfg                                 = [];
        cfg.colormap                        = brewermap(256, '*Spectral');
        cfg.channel                         = nchan;
        cfg.parameter                       = 'prob';
        cfg.maskparameter                   = 'mask';
        cfg.maskstyle                       = 'outline';
        cfg.zlim                            = [min_p 1];
        ft_singleplotTFR(cfg,stat);
        
        title(stat.label{nchan});
        set(gca,'FontSize',20,'FontName', 'Calibri');
        
        vline(0,'--k');
        vline(1.2,'--k');
        
    end
end