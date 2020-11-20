clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load suj_list_peak.mat

list_freq                                   = {'alpha1Hz.bslcorrected','beta2Hz.bslcorrected','beta3Hz.bslcorrected'};
list_condition                              = {'0v1B','0v2B','1v2B'};

for n_suj = 1:length(suj_list)
    for n_freq = 1:length(list_freq)
        for n_con = 1:length(list_condition)
            
            fname                           = ['../../data/decode/new_virt/sub' num2str(suj_list(n_suj)) '.' list_condition{n_con} '.brainbroadband.mtmavg.' list_freq{n_freq}];
            fname                           = [fname '.auc.bychan.mat'];
            
            fprintf('loading %s\n',fname);
            load(fname);
            
            load ../../data/template/broadband_chan_name.mat
            
            avg                             = [];
            avg.label                       = data_label;
            avg.dimord                      = 'chan_time';
            avg.time                        = time_axis;
            avg.avg                         = scores;
            
            list_unique                     = h_grouplabel(avg,'yes');
            new_avg                         = h_transform_avg(avg,list_unique(:,2),list_unique(:,1));
            
            alldata{n_suj,n_con,n_freq}     = avg; clear avg new_avg;
            
        end
    end
end

keep alldata list_*

nbsuj                                       = size(alldata,1);
[design,neighbours]                         = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg                                         = [];
cfg.latency                                 = [-0.2 6];
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
new_list_condition                          = {};

for nfreq = [2 3]
    for n_con = 1:size(alldata,2)
        i                                   = i +1;
        stat{i}                             = ft_timelockstatistics(cfg, alldata{:,n_con,1}, alldata{:,n_con,nfreq});
        [min_p(i),p_val{i}]                 = h_pValSort(stat{i});
        new_list_condition{i}               = [list_condition{n_con} ' ' list_freq{nfreq}(1:7)];
    end
end

list_condition                              = new_list_condition;
i                                           = 0;

for n_con = 1:length(stat)
    
    plimit                                  = 0.05;
    stat{n_con}.mask                        = stat{n_con}.prob < plimit;
    stat2plot                               = h_plotStat(stat{n_con},10e-13,plimit,'stat');
    
    for nchan = 1:length(stat{n_con}.label)
        
        tmp                                 = stat{n_con}.mask(nchan,:,:) .* stat{n_con}.prob(nchan,:,:);
        ix                                  = unique(tmp);
        ix                                  = ix(ix~=0);
        
        if ~isempty(ix)
            
            tmp(tmp==0)                     = [];
            
            i                               = i + 1;
            subplot(3,2,i)
            
            if length(stat2plot.label) < 40
                nme                         = stat2plot.label{nchan};
            else
                nme                         = strsplit(stat2plot.label{nchan},',');
                nme                     	= nme{2};
            end
            
            cfg                             = [];
            cfg.linewidth                   = 2;
            cfg.linecolor                   = 'k';
            cfg.channel                     = nchan;
            ft_singleplotER(cfg,stat2plot)
            
            title([upper(nme) ' ' upper(list_condition{n_con}) ' p = ' num2str(min(unique(tmp)))]);
            
            
            vline(0,'--k');
            vline(2,'--k');
            vline(4,'--k');
            
        end
    end
end