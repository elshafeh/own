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
        
    fname_in                    	= ['~/Dropbox/project_me/data/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.0back.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    allbetapeaks(nsuj,1)            = bpeak;
    
end

mean_beta_peak                      = round(nanmedian(allbetapeaks));
allbetapeaks(isnan(allbetapeaks))   = mean_beta_peak;

%%

for nsuj = 1:length(suj_list)
    
    dir_data                        = '~/Dropbox/project_me/data/nback/corr/mtm/';
    fname_in                        = [dir_data 'sub' num2str(suj_list(nsuj)) '.allback.allbehav.target.mtm.mat'];
    
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    list_band                       = {'slow' 'alpha' 'beta'};
    
    for nband = 1:length(list_band)
        
        test_band                   = list_band{nband};
        
        switch test_band
            case 'slow'
                f_focus             = 3;
                f_width             = 2;
            case 'alpha'
                f_focus             = apeak;
                f_width             = 1;
            case 'beta'
                f_focus             = allbetapeaks(nsuj);
                f_width             = 2;
            case 'high-beta'
                f_focus             = 25;
                f_width             = 5;
            case 'gamma'
                f_focus             = 50;
                f_width             = 10;
        end
        
        f1                          = find(round(freq_comb.freq) == round(f_focus-f_width));
        f2                          = find(round(freq_comb.freq) == round(f_focus+f_width));
        pow                         = squeeze(nanmean(freq_comb.powspctrm(:,f1:f2,:),2));
        
        avg                         = [];
        avg.time                    = freq_comb.time;
        avg.label                   = freq_comb.label;
        avg.dimord                  = 'chan_time';
        avg.avg                     = pow;
        
        alldata{nsuj,nband}         = avg; clear avg;
        
    end
    
    clear freq_comb
    
end

%%

keep alldata allbehav list_*

nbsuj                               = size(alldata,1);
[~,neighbours]                      = h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

cfg                                 = [];
cfg.method                          = 'montecarlo';
cfg.latency                         = [-0.5 0.5];
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
    for nband = 1:size(alldata,2)
        
        cfg.design(1,1:nbsuj)       = [allbehav(:,nbehav)];
        stat{nbehav,nband}       	= ft_timelockstatistics(cfg, alldata{:,nband});
        [min_p(nbehav,nband),p_val{nbehav,nband}]	= h_pValSort(stat{nbehav,nband});
        
    end
end

%%

keep alldata allbehav stat min_p p_val list_*

plimit                              = 0.15;
nrow                                = 3;
ncol                                = 2;
i                                   = 0;

list_behav                          = {'rt' 'accuracy'};

for nbehav = 1:size(stat,1)
    for nband = 1:size(stat,2)
        
        if min_p(nbehav,nband) < plimit
            
            nw_data                 = squeeze(alldata(:,nband));
            nw_stat                 = stat{nbehav,nband};
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
            title({[list_behav{nbehav} ' with ' list_band{nband}], ...
                ['p = ' num2str(round(min_p(nbehav,nband),3))]});
            
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
            
            test_band             	= list_band{nband};
            
            if strcmp(test_band,'slow')
                cfg.z_limit       	= [0 3e-23];
            elseif strcmp(test_band,'alpha')
                cfg.z_limit       	= [0 2e-23];
            elseif strcmp(test_band,'beta')
                cfg.z_limit       	= [0 0.5e-23];
            elseif strcmp(test_band,'high-beta')
                cfg.z_limit      	= [0 0.3e-23];
            elseif strcmp(test_band,'gamma')
                cfg.z_limit      	= [0.2e-24 0.9e-24];
            end
            
            i = i + 1;
            subplot(nrow,ncol,i)
            h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,nw_data);
            
            hline(0,'-k');
            vline(0,'-k');
            set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
            
        end
    end
end