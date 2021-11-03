clear;clc;

allbehav                            = [];

for nsuj = [1:33 35:36 38:44 46:51]
    
    dir_data                        = '~/Dropbox/project_me/data/nback/trialinfo/';
    fname                           = [dir_data 'sub' num2str(nsuj) '.trialinfo.mat'];
    load(fname);
    
    flg_nback_stim                  = find(trialinfo(:,2) == 2);
    sub_info                        = trialinfo(flg_nback_stim,[4 5 6]);
    
    sub_info_correct                = sub_info(sub_info(:,1) == 1 | sub_info(:,1) == 3,:); % remove incorrect trials for RT analyses
    sub_info_correct                = sub_info_correct(sub_info_correct(:,2) ~= 0,:); % remove zeros
    
    median_rt                       = median(sub_info_correct(:,2));
    perc_correct                    = length(sub_info_correct) ./ length(sub_info);

    
    allbehav                        = [allbehav;median_rt perc_correct];
    
    
end

%%

keep allbehav ext_decode

suj_list                            = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    list_cond                       = {'first.pre' 'first.post' 'target.pre' 'target.post'};
    
    for ncond = 1:length(list_cond)
        
        dir_data                    = '~/Dropbox/project_me/data/nback/corr/fft/';
        fname_in                    = [dir_data 'sub' num2str(suj_list(nsuj)) '.allback.allbehav.' list_cond{ncond} '.fft.mat'];
        
        fprintf('loading %s\n',fname_in);
        load(fname_in);
        
        avg                         = [];
        avg.label                   = freq_comb.label;
        avg.time                    = freq_comb.freq;
        avg.avg                     = freq_comb.powspctrm;
        avg.dimord                  = 'chan_time';
        
        alldata{nsuj,ncond}         = avg; clear avg freq_comb;
        
    end
end

%%

keep alldata allbehav list_cond

nbsuj                               = size(alldata,1);
[~,neighbours]                      = h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

cfg                                 = [];
cfg.method                          = 'montecarlo';
cfg.latency                         = [1 35];
cfg.statistic                       = 'ft_statfun_correlationT';
cfg.type                            = 'Spearman';
cfg.clusterstatistics               = 'maxsum';
cfg.correctm                        = 'cluster';
cfg.clusteralpha                    = 0.05;
cfg.tail                            = 0;
cfg.clustertail                     = 0;
cfg.alpha                           = 0.025;
cfg.numrandomization                = 1000;
cfg.minnbchan                       = 3;
cfg.neighbours                      = neighbours;
cfg.ivar                            = 1;

for nbehav = 1:size(allbehav,2)
    for ncond = 1:size(alldata,2)
        
        cfg.design(1,1:nbsuj)       = [allbehav(:,nbehav)];
        stat{nbehav,ncond}       	= ft_timelockstatistics(cfg, alldata{:,ncond});
        [min_p(nbehav,ncond),p_val{nbehav,ncond}]	= h_pValSort(stat{nbehav,ncond});
        
    end
end

%%

keep alldata allbehav stat min_p p_val list_cond

plimit                              = 0.15;
nrow                                = 3;
ncol                                = 2;
i                                   = 0;

list_behav                          = {'rt' 'accuracy'};

for nbehav = 1:size(stat,1)
    for ncond = 1:size(stat,2)
        
        if min_p(nbehav,ncond) < plimit
            
            nw_data                 = squeeze(alldata(:,ncond));
            nw_stat                 = stat{nbehav,ncond};
            nw_stat.mask            = nw_stat.prob < plimit;
            
            statplot                = [];
            statplot.avg            = nw_stat.mask .* nw_stat.rho;
            statplot.label          = nw_stat.label;
            statplot.dimord         = nw_stat.dimord;
            statplot.time           = nw_stat.time;
            
            find_sig_time           = mean(statplot.avg,1);
            find_sig_time           = find(find_sig_time ~= 0);
            list_time               = [min(statplot.time(find_sig_time)) max(statplot.time(find_sig_time))];
            
            cfg                     = [];
            cfg.layout              = 'neuromag306cmb.lay';
            cfg.xlim                = list_time;
            cfg.zlim                = [-0.2 0.2];
            cfg.colormap            = brewermap(256,'*RdBu');
            cfg.marker              = 'off';
            cfg.comment             = 'no';
            cfg.colorbar            = 'no';
            
            i = i + 1;
            subplot(nrow,ncol,i)
            ft_topoplotER(cfg,statplot);
            title({[list_behav{nbehav} ' with ' list_cond{ncond} ' fft'], ...
                ['p = ' num2str(round(min_p(nbehav,ncond),3))]});
            
            set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
            
            find_sig_chan           = mean(statplot.avg,2);
            find_sig_chan           = find(find_sig_chan ~= 0);
            list_chan               = nw_stat.label(find_sig_chan);
            
            cfg                     = [];
            cfg.channel             = list_chan;
            cfg.time_limit          = nw_stat.time([1 end]);
            cfg.color               = [0 0 0];
            cfg.lineshape           = '-k';
            cfg.linewidth           = 10;
            cfg.z_limit             = [0 1e-23];
            i = i + 1;
            subplot(nrow,ncol,i)
            h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,nw_data);
            
            hline(0,'-k');
            vline(0,'-k');
            set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
            
        end
    end
end