clear ;

dir_data                                = '../data/sub/preproccesed/';
suj_list                                = dir([dir_data '*_icafree.mat']);
events                                  = [];

for sb = 1:length(suj_list)
    
    suj                                 = strsplit(suj_list(sb).name,'_');
    suj                                 = suj{1};
    
    fname                               = [dir_data suj_list(sb).name];
    fprintf('Loading %s\n',fname);
    tic;load(fname);toc;
    
    cfg                                 = [];
    cfg.bpfilter                        = 'yes';
    cfg.bpfreq                          = [0.2 30];
    dataFilt{sb,1}                      = ft_preprocessing(cfg,downsampled_clean_icafree_data); clear dataPostICA;
    
end

for sb = 1:length(dataFilt)
    
    cfg                                 = [];
    cfg.removemean                      = 'no';
    dataAvg{sb,1}                       = ft_timelockanalysis(cfg,dataFilt{sb,1});
    
end

clearvars -except dataAvg dataFilt

cfg                                     = [];
cfg.parameter                           ='avg';
cfg.layout                              = 'CTF275_helmet.mat';
cfg.xlim                                = [-0.1 :0.05 : 0.5];
cfg.ylim                                = [-1e-13 1e-13];
cfg.marker                              = 'off';
cfg.comment                             = 'no';
% cfg.colormap                            = brewermap(256, '*RdYlBu');
cfg.baseline                            = [-0.2 -0.1];
cfg.colorbar                            = 'no';
% cfg.channel                             = 'M*O*';
clf;
ft_topoplotER(cfg, dataAvg{1})

for nsub = 1:length(dataAvg)
    
    subplot(2,2,nsub)
    ft_topoplotER(cfg, dataAvg{nsub});
    title('');
    clc;
    vline(0,'--k');vline(1.5,'--k');vline(3,'--k');vline(4.5,'--k');
    grid on;
    
end

% time_win                            = 0.1;
% list_time                           = 0:time_win:1;
% ix                                  = 0;
%
% for sb = 1:size(dataAvg,1)
%         for ntime = 1:length(list_time)
%
%             ix                      = ix +1;
%             subplot(size(dataAvg,1)*size(dataAvg,2),length(list_time),ix);
%
%             cfg                     = [];
%             cfg.xlim                = [list_time(ntime) list_time(ntime)+time_win];
%
%             cfg.baseline            = [-0.1 0];
%
%             cfg.layout              = 'CTF275_helmet.mat';
%             cfg.marker              = 'off';
%             cfg.comment             = 'no';
%             cfg.colormap            = brewermap(256, '*RdYlBu');
%             cfg.ylim                = [-1e-13 1e-13];
%
%             ft_topoplotER(cfg,dataAvg{sb,nc});clc;
%
%         end
% end



%     cfg                                 = [];
%     cfg.baseline                        = [-0.1 0];
%     dataAvg{sb,1}                       = ft_timelockbaseline(cfg,dataAvg{sb,1});
%
%     cfg                                 = [];
%     cfg.method                          = 'amplitude';
%     dataAvg{sb,2}                       = ft_globalmeanfield(cfg,dataAvg{sb,1});
