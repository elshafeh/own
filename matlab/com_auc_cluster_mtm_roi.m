clear ; close all;

global ft_default
ft_default.spmversion = 'spm12';

suj_list                                        = [1:4 8:17];

load J:/temp/meeg/data/voxbrain/preproc/yc1.CnD.brain1vox.dwn60.eeg.mat;
roi_label                                       = data.label;

for ns = 1:length(suj_list)
    
    list_data                                   = {'meg','eeg'};
    list_feat                                   = {'left.right','inf.unf'}; %,'left.inf','right.inf'};
    
    for ndata = 1:length(list_data)
        for nfeat = 1:length(list_feat)
            
            tmp                                 = [];
            
            for nfreq = 1:30
                
                fname                           = ['J:/temp/meeg/data/voxbrain/auc/yc' num2str(suj_list(ns)) '.CnD.brain1vox.dwn60.' ...
                    list_data{ndata} '.' list_feat{nfeat} '.' num2str(nfreq) 'Hz.auc.bychan.mat'];
                
                fprintf('loading %s\n',fname);
                load(fname);
                
                tmp(:,nfreq,:)                  = scores; clear scores;
                
            end
            
            time_list                           = -1.5:0.05:2.5;
            freq_list                           = 1:1:30;
            chan_list                           = 1:length(roi_label);
            
            freq                                = [];
            freq.powspctrm                      = tmp; clear tmp;
            freq.dimord                         = 'chan_freq_time';
            freq.time                           = time_list;
            freq.freq                           = freq_list;
            freq.label                          = roi_label(chan_list);
            
            alldata{ns,ndata,nfeat}             = freq; clear freq;
            
        end
    end
    
    % change names 
    % to make it nicer for plots :)
    for nfeat = 1:length(list_feat)
        tmp                                     = strsplit(list_feat{nfeat},'.');
        list_feat{nfeat}                        = [tmp{1} ' v ' tmp{2}]; clear tmp;
    end
    
end

keep alldata roi_label list_*

nsuj                                            = size(alldata,1);
[design,neighbours]                             = h_create_design_neighbours(nsuj,alldata{1,1},'virt','t'); clc;

cfg                                             = [];
cfg.latency                                     = [-0.2 2];
% cfg.frequency                                   = [1 20];
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

for nfeat = 1:size(alldata,3)
    stat{nfeat}                                  = ft_freqstatistics(cfg,alldata{:,1,nfeat},alldata{:,2,nfeat});
end

keep alldata roi_label list_* stat

for nfeat = 1:length(stat)
    [min_p(nfeat),p_val{nfeat}]                 = h_pValSort(stat{nfeat});
    stat{nfeat}                                 = rmfield(stat{nfeat},'posdistribution');
    stat{nfeat}                                 = rmfield(stat{nfeat},'negdistribution');
end

close all;

figure;
i                                               = 0;
nrow                                            = 2;
ncol                                            = 1;
plimit                                          = 0.1;

for nfeat = 1:length(stat)
    
    
    stat{nfeat}.mask                            = stat{nfeat}.prob < plimit;
    
    for nchan = 1:length(stat{nfeat}.label)
        
        tmp                                     = stat{nfeat}.mask(nchan,:,:) .* stat{nfeat}.prob(nchan,:,:);
        ix                                      = unique(tmp);
        ix                                      = ix(ix~=0);
        ix                                      = ix(~isnan(ix));
        
        if ~isempty(ix)
            
            i                                   = i + 1;
            subplot(nrow,ncol,i)
            
            cfg                                 = [];
            cfg.colormap                        = brewermap(256, '*RdBu');
            cfg.channel                         = nchan;
            cfg.parameter                       = 'stat';
            cfg.maskparameter                   = 'mask';
            cfg.maskstyle                       = 'outline';
            cfg.zlim                            = [-3 3]; %min(min_p) plimit];
            ft_singleplotTFR(cfg,stat{nfeat});
            
            title([upper(stat{nfeat}.label{nchan}) ' ' upper(list_feat{nfeat}) ' p= ' num2str(round(min(min(ix)),3))]);
            set(gca,'FontSize',10,'FontName', 'Calibri');
            
            vline(0,'--k');
            vline(1.2,'--k');
            
        end
    end
end