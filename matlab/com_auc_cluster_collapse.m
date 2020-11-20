clear ; close all;

global ft_default
ft_default.spmversion = 'spm12';


suj_list                            = [1:4 8:17];

for ns = 1:length(suj_list)
    for ndata = 1:2
        
        for nfeat = 1:2
            
            list_data               = {'meg','eeg'};
            list_orig               = {'pt1.CnD.meg','CnD.eeg'};
            list_feat               = {'inf','lr'}; % {'inf.unf','left.right'}; %
            
            if strcmp(list_data{ndata},'eeg')
                
                fname               = ['../decode/yc' num2str(suj_list(ns)) '.CnD.' list_data{ndata} '.' list_feat{nfeat} '.minus.evoked.auc.mat'];
                fprintf('loading %s\n',fname);
                load(fname);
                
                tmp(nfeat,:)        = scores; clear scores;
                
            else
                
                for np = 1:3
                    fname           = ['../decode/yc' num2str(suj_list(ns)) '.pt' num2str(np) '.CnD.' list_data{ndata} '.' list_feat{nfeat} '.minus.evoked.auc.mat'];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    sc_carr(np,:)   = scores ; clear scores;
                end
                
                tmp(nfeat,:)        = mean(sc_carr,1); clear sc_carr;
                
            end
            
        end
        
        list_feat                   = {'INF VS UNF','LEFT VS RIGHT'};
        scores                      = tmp; clear tmp;
        
        %         if ndata == 1 && ns == 1
        %             fname                   = ['../data/preproc_data/yc' num2str(suj_list(ns)) '.' list_orig{ndata} '.sngl.dwn100.mat'];
        %             fprintf('loading %s\n',fname);
        %             load(fname);
        %             lm1                     = find(round(data.time{1},2) == round(-0.1,2));
        %             lm2                     = find(round(data.time{1},2) == round(2,2));
        %             time_axis               = data.time{1}(lm1:lm2-1);
        %         end
        
        avg                         = [];
        avg.label                   = list_feat;
        avg.dimord                  = 'chan_time';
        avg.time                    = time_axis;
        avg.avg                     = scores;
        
        alldata{ns,ndata}           = avg;
        
        keep alldata ns suj_list list_* time_axis;
        
        fprintf('\n');
        
    end
end

keep alldata list_*

nbsuj                           = size(alldata,1);
[design,neighbours]             = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg                             = [];
% cfg.latency                     = [0.5 1.2];
cfg.statistic                   = 'ft_statfun_depsamplesT';
cfg.method                      = 'montecarlo';
cfg.correctm                    = 'cluster';
cfg.clusteralpha                = 0.05;
cfg.clusterstatistic            = 'maxsum';
cfg.minnbchan                   = 0;
cfg.tail                        = 0;
cfg.clustertail                 = 0;
cfg.alpha                       = 0.025;
cfg.numrandomization            = 1000;
cfg.uvar                        = 1;
cfg.ivar                        = 2;

cfg.neighbours                  = neighbours;
cfg.design                      = design;

stat                            = ft_timelockstatistics(cfg, alldata{:,1}, alldata{:,2});
[min_p,p_val]                   = h_pValSort(stat);

stat.mask                       = stat.prob < 0.05;

figure;
hold on

for nchan = 1:2
    plot(stat.time, stat.mask(nchan,:) .* stat.stat(nchan,:),'LineWidth',3);
    xticks([0:0.1:2]);
end

legend(list_feat);