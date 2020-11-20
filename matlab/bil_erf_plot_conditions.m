clear ;

list_name                               = {'targetlock','probelock'};

for nc = 1:2
    
    ext_name                            = [list_name{nc} '.erfComb'];
    suj_list                            = dir(['../data/sub*/erf/*' ext_name '*']);
    
    for ns = 1:length(suj_list)
        
        subjectName                     = suj_list(ns).name;
        
        fname                           = [suj_list(ns).folder '/' suj_list(ns).name];
        fprintf('Loading %s\n',fname);
        load(fname);
        
        alldata{ns,nc}                  = avg_comb; clear avg_comb;
        
    end
    
end

clearvars -except alldata;

for nc = 1:size(alldata,2)
    gavg{nc}                                    = ft_timelockgrandaverage([],alldata{:,nc});
end


cfg                                 = [];
cfg.layout                          = 'CTF275_helmet.mat';
cfg.ylim                            = 'maxabs';
cfg.marker                          = 'off';
cfg.comment                         = 'no';
cfg.colormap                        = brewermap(256,'Reds');
cfg.colorbar                        = 'no';

%     ax1                                 = list_time(nt)+0.08;
%     ax2                                 = list_time(nt)+0.2;

cfg.xlim                            = [0 0.5];

%     i                                   = i +1;
%     subplot(2,4,i)
%     rect_ax                             = [rect_ax;cfg.xlim];

ft_topoplotER(cfg, gavg{:});


% cfg                                     = [];
% cfg.label                               = 'M*O*';
% %cfg.label                               ={'MLO11', 'MLO12', 'MLO21', 'MLO22', 'MLO31', 'MLO32', ... 
% %    'MRO11', 'MRO12', 'MRO21', 'MRO22', 'MRO23', 'MZO01'};
% cfg.xlim                                = [-0.2 6];
% cfg.vline                               = [1.5 3 4.5];
% cfg.rect_ax                             = rect_ax;
% cfg.plot_single                         = 'no';
% 
% i                                       = i +1;
% subplot(2,4,i:i+3);
% h_plot_erf(cfg,alldata)