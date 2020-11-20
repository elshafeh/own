clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load suj_list_peak.mat

list_freq                                   = {'alpha1Hz.virt.demean','beta3Hz.virt.demean'};
list_condition                              = {'0Ball','1Ball','2Ball'};

for n_suj = 1:length(suj_list)
    for n_freq = 1:length(list_freq)
        for n_con = 1:length(list_condition)
            
            fname                           = ['../../data/decode/virt/sub' num2str(suj_list(n_suj)) '.' list_condition{n_con} '.' list_freq{n_freq}];
            fname                           = [fname '.auc.bychan.mat'];
            
            fprintf('loading %s\n',fname);
            load(fname);
            
            load roi1cm_actual_labels.mat
            
            chan_keep                       = [1:100 118:159 185:206];
            
            avg                             = [];
            avg.label                       = data_name(chan_keep);
            avg.dimord                      = 'chan_time';
            avg.time                        = time_axis;
            avg.avg                         = scores(chan_keep,:); clear scores;
            
            alldata{n_suj,n_con,n_freq,1}   = avg;
            
            avg.avg(:)                      = 0.5;
            alldata{n_suj,n_con,n_freq,2}   = avg; clear avg;
            
        end
    end
end

keep alldata list_*

nbsuj                                       = size(alldata,1);
[design,neighbours]                         = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg                                         = [];
cfg.latency                                 = [-0.1 5];
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

for n_con = 1:size(alldata,2)
    for n_freq = 1:size(alldata,3)
        stat{n_con,n_freq}                  = ft_timelockstatistics(cfg, alldata{:,n_con,n_freq,1}, alldata{:,n_con,n_freq,2});
        [min_p(n_con,n_freq),p_val{n_con,n_freq}]             = h_pValSort(stat{n_con,n_freq});
    end
end


plimit                                          = 0.05;

for n_con = 1:size(stat,1)
    for n_freq = 1:size(stat,2)
        
        if min_p(n_con,n_freq) < plimit
            
            figure;
            i                                       = 0;
            stat{n_con,n_freq}.mask                 = stat{n_con,n_freq}.prob < plimit;
            stat2plot                               = h_plotStat(stat{n_con,n_freq},10e-13,plimit,'stat');
            
            for nchan = 1:length(stat2plot.label)
                
                tmp                                 = stat{n_con,n_freq}.mask(nchan,:,:) .* stat{n_con,n_freq}.prob(nchan,:,:);
                ix                                  = unique(tmp);
                ix                                  = ix(ix~=0);
                
                if ~isempty(ix)
                    
                    i                               = i + 1;
                    subplot(2,2,i)
                    
                    nme                             = strsplit(stat2plot.label{nchan},',');
                    nme                             = nme{2};
                    
                    cfg                             = [];
                    cfg.linewidth                   = 2;
                    cfg.linecolor                   = 'k';
                    cfg.channel                     = nchan;
                    ft_singleplotER(cfg,stat2plot)
                    
                    title([upper(nme) ' ' upper(list_condition{n_con}) ' ' upper(list_freq{n_freq})]);
                    set(gca,'FontSize',10,'FontName', 'Calibri');
                    
                    vline(0,'--k');
                    vline(2,'--k');
                    vline(4,'--k');
                    
                end
            end
        end
    end
end
