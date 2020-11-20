clear ;

suj_list                                = dir('../data/*/tf/*.mtm.auc.combined.mat');

for ns = 1:length(suj_list)
    
    suj                                 = suj_list(ns).name(1:6);
    
    list_feat                           = {'pre_retro','pre_task','retro_task'};
    
    %     tmp                                 = [];
    %
    %     for nfeat = 1:length(list_feat)
    %         for nfreq = 1:50
    %
    %             fname                       = ['/Volumes/heshamshung/bil_py_data/' suj '_AUC_mtm_' num2str(nfreq) '_' list_feat{nfeat} '.mat'];
    %             fprintf('Loading %s\n',fname);
    %             load(fname);
    %
    %             tmp(nfeat,nfreq,:)          = scores; clear scores;
    %
    %         end
    %     end
    %
    %     for nchan = 1:length(list_feat)
    %         ix                              = strfind(list_feat{nchan},'_');
    %         list_feat{nchan}(ix)            = ' ';
    %         list_feat{nchan}                = upper(list_feat{nchan});
    %     end
    %
    %     time_width                          = 0.02;
    %     freq_width                          = 1;
    %
    %     time_list                           = -1:time_width:6;
    %     freq_list                           = 1:freq_width:50;
    %
    %     freq                                = [];
    %     freq.dimord                         = 'chan_freq_time';
    %     freq.label                          = list_feat;
    %     freq.freq                           = freq_list;
    %     freq.time                           = time_list;
    %     freq.powspctrm                      = tmp ; clear tmp;
    
    fname_out                           = ['../data/' suj '/tf/' suj '.mtm.auc.combined.mat'];
    fprintf('loading %s\n',fname_out);
    load(fname_out);
    
    alldata{ns,1}                       = freq; clear freq;
    
    fprintf('\n');
    
end

keep alldata

gavg                                    = ft_freqgrandaverage([],alldata{:,1});

i                                       = 0;

for nchan = 1:length(gavg.label)
    
    nrow                                = 2;
    ncol                                = 2;
    
    i                                   = i + 1;
    subplot(nrow,ncol,i)
    
    cfg                                 = [];
    cfg.channel                         = gavg.label{nchan};
    cfg.marker                          = 'off';
    cfg.comment                         = 'no';
    cfg.colormap                        = brewermap(256, '*RdBu');
    cfg.colorbar                        = 'yes';
    
    cfg.xlim                            = [0 6];
    cfg.zlim                            = [1 35];
    cfg.zlim                            = [0.5 0.6]; % [0.5 max(max(max(gavg.powspctrm(nchan,:,:))))];
    
    ft_singleplotTFR(cfg, gavg);
    
    for nv = [1.5 3 4.5 5.5]
        vline(nv,'--g');
    end
    
    %     i                                   = i + 1;
    %     subplot(nrow,ncol,i)
    %
    %     nw_data                             = squeeze(mean(squeeze(gavg.powspctrm(nchan,:,:)),1));
    %     plot(gavg.time,nw_data);
    %
    %     xlim([-0.1 5]);
    %     ylim([0.5 0.55]);
    %
    %     for nv = [1.5 3 4.5 5.5]
    %         vline(nv,'--k');
    %     end
    
end