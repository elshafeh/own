clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load suj_list_peak.mat

list_condition                              = {'0v1B','0v2B','1v2B'};

for n_suj = 1:length(suj_list)
    for n_con = 1:length(list_condition)
        
        list_freq                           = {'alpha1Hz.bslcorrected','beta3Hz.bslcorrected'};
        
        for n_freq = 1:length(list_freq)
            fname                           = ['/project/3015039.05/temp/nback/data/decode/new_virt/sub' num2str(suj_list(n_suj)) '.' list_condition{n_con}];
            fname                           = [fname '.brainbroadband.mtmavg.' list_freq{n_freq}];
            fname                           = [fname '.auc.bychan.mat'];
            
            fprintf('loading %s\n',fname);
            load(fname);
            
            load /project/3015039.05/temp/nback/data/template/broadband_chan_name.mat
            
            avg                             = [];
            avg.label                       = data_label;
            avg.dimord                      = 'chan_time';
            avg.time                        = time_axis;
            avg.avg                         = scores;
            
            alldata{n_suj,n_con,n_freq}     = avg; clear avg;
            
        end
    end
end

keep alldata list_condition

nbsuj                                       = size(alldata,1);
[design,neighbours]                         = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg                                         = [];
cfg.latency                                 = [0 5];
cfg.statistic                               = 'ft_statfun_depsamplesT';
cfg.method                                  = 'montecarlo';
cfg.correctm                                = 'cluster';
cfg.clusterstatistic                        = 'maxsum';
cfg.clusteralpha                            = 0.05;
cfg.minnbchan                               = 0;
cfg.tail                                    = 0;
cfg.clustertail                             = 0;
cfg.alpha                                   = 0.025;
cfg.numrandomization                        = 1000;
cfg.uvar                                    = 1;
cfg.ivar                                    = 2;

cfg.neighbours                              = neighbours;
cfg.design                                  = design;

i                                           = 0;

for n_con = 1:size(alldata,2)
    i                                       = i +1;
    stat{i}                                 = ft_timelockstatistics(cfg, alldata{:,n_con,1}, alldata{:,n_con,2});
    [min_p(i),p_val{i}]                     = h_pValSort(stat{i});
end

% for n_con = 1:size(alldata,2)
%     i                                       = i +1;
%     stat{i}                                 = ft_timelockstatistics(cfg, alldata{:,n_con,3}, alldata{:,n_con,4});
%     [min_p(i),p_val{i}]                     = h_pValSort(stat{i});
% end

list_condition                              = {'0v1B.bsl','0v2B.bsl','1v2B.bsl'};%,'0v1B.demean','0v2B.demean','1v2B.demean'};

plimit                                      = 0.2;
nb_plot                                     = h_howmanyplots(stat(1:3),plimit);

i                                           = 0;
nrow                                        = 3;
ncol                                        = 2;
z_limit                                     = [0.48 0.6];

for n_con = [1 2 3]
    
    stat{n_con}.mask                        = stat{n_con}.prob < plimit;
    
    for nchan = 1:length(stat{n_con}.label)
        
        tmp                                 = stat{n_con}.mask(nchan,:,:) .* stat{n_con}.prob(nchan,:,:);
        ix                                  = unique(tmp);
        ix                                  = ix(ix~=0);
        
        if ~isempty(ix)
            
            i                               = i + 1;
            subplot(nrow,ncol,i)
            
            nme                             = strsplit(stat{n_con}.label{nchan},',');
            nme                             = nme{2};
            
            
            cfg                             = [];
            cfg.channel                     = stat{n_con}.label{nchan};
            cfg.p_threshold               	= plimit;
            cfg.time_limit               	= [0 5];%stat{n_con}.time([1 end]);
            cfg.color                      	= 'br';
            cfg.z_limit                     = z_limit;
            
            list_indices                    = [1 1 2; 2 1 2; 3 1 2; 1 3 4; 2 3 4; 3 3 4];
            
            ix1                             = list_indices(n_con,1);
            ix2                             = list_indices(n_con,2);
            ix3                             = list_indices(n_con,3);
            
            h_plotSingleERFstat_selectChannel(cfg,stat{n_con},squeeze(alldata(:,ix1,[ix2 ix3])));
            
            legend({'alpha','','beta',''});
            
            title([upper(nme) ' ' upper(list_condition{n_con}) ' p = ' num2str(round(min(ix),2))]);
            set(gca,'FontSize',8,'FontName', 'Calibri');
            
            hline(0.5,'--k');
            vline(0,'--k');
            vline(2,'--k');
            vline(4,'--k');
            
        end
    end
end