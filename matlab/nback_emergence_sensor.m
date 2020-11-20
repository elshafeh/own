clear ; global ft_default
ft_default.spmversion = 'spm12';

% suj_list                                            = [1:33 35:36 38:44 46:51];
load suj_list_peak.mat

for ns = 1:length(suj_list)
    
    subjectName                                     = ['sub' num2str(suj_list(ns))];clc;
    
    % load data from both sessions
    check_name                                      = dir(['../data/tf/' subjectName '.sess*.allback.1t30Hz.1HzStep.AvgTrials.stk.exl.mat']);
    
    for nf = 1:length(check_name)
        fname                                       = [check_name(nf).folder filesep check_name(nf).name];
        fprintf('loading %s\n',fname);
        load(fname);
        tmp{nf}                                     = freq_comb; clear freq_comb;
    end
    
    % avearge both sessions
    freq                                            = ft_freqgrandaverage([],tmp{:}); clear tmp nf check_name;
    
    % 1 is activity and 2 is baseline
    [temp{1},temp{2}]                               = h_prepareBaseline(freq,[-1 0],[1 30],[0 6],'none');
    
    % load peak
    fname                                           = ['../data/peak/' subjectName '.alphabetapeak.m1000m0ms.mat'];
    load(fname);
    
    fpeak                                           = [apeak bpeak];
    bnwidth                                         = [1 3];
    
    for nfreq = 1:length(fpeak)
        for ntime = 1:2
            
            f1                                      = fpeak(nfreq) - bnwidth(nfreq);
            f2                                      = fpeak(nfreq) + bnwidth(nfreq);
            
            cfg                                     = [];
            cfg.frequency                           = [f1 f2];
            cfg.avgoverfreq                         = 'yes';
            avg                                     = ft_selectdata(cfg,temp{ntime});
            
            avg.avg                                 = squeeze(avg.powspctrm);
            avg.dimord                              = 'chan_time';
            avg                                     = rmfield(avg,'powspctrm');
            avg                                     = rmfield(avg,'freq');
            
            alldata{ns,nfreq,ntime}                 = avg; clear avg;
            
        end
    end
end

keep alldata

nb_suj                                              = size(alldata,1);
[design,neighbours]                                 = h_create_design_neighbours(nb_suj,alldata{1,1},'elekta','t');

cfg                                                 = [];
% cfg.latency                                         = [-0.2 6];
cfg.statistic                                       = 'ft_statfun_depsamplesT';
cfg.method                                          = 'montecarlo';
cfg.correctm                                        = 'cluster';
cfg.clusteralpha                                    = 0.05;
cfg.clusterstatistic                                = 'maxsum';
cfg.minnbchan                                       = 4;
cfg.tail                                            = 0;
cfg.clustertail                                     = 0;
cfg.alpha                                           = 0.025;
cfg.numrandomization                                = 1000;
cfg.uvar                                            = 1;
cfg.ivar                                            = 2;
cfg.neighbours                                      = neighbours;
cfg.design                                          = design;

for nfreq = 1:size(alldata,2)
    stat{nfreq}                                     = ft_timelockstatistics(cfg, alldata{:,nfreq,1}, alldata{:,nfreq,2});
end

for nfreq = 1:length(stat)
    [min_p(nfreq),p_val{nfreq}]                     = h_pValSort(stat{nfreq});
end

i                                                   = 0;

for nfreq = 1:length(stat)
    
    stat{nfreq}.mask                               = stat{nfreq}.prob < 0.05;
    
    stat2plot                                       = [];
    stat2plot.avg                                   = stat{nfreq}.mask .* stat{nfreq}.stat;
    stat2plot.label                                 = stat{nfreq}.label;
    stat2plot.dimord                                = stat{nfreq}.dimord;
    stat2plot.time                                  = stat{nfreq}.time;
    
    time_win                                        = 0.5;
    time_list                                       = [stat2plot.time(1):time_win:stat2plot.time(end)];
    
    for t = 1:length(time_list)
        
        i                                           = i +1;
        
        nrow                                        = length(stat);
        ncol                                        = length(time_list);
        subplot(nrow,ncol,i)
        
        cfg                                         = [];cfg.layout  = 'neuromag306cmb.lay';
        cfg.zlim                                    = 'maxabs';
        cfg.linecolor                               = 'k'; cfg.linewidth = 2;
        
        if t == length(time_list)
            cfg.xlim                                = [time_list(t) stat2plot.time(end)];
        else
            cfg.xlim                                = [time_list(t) time_list(t)+time_win];
        end
        
        cfg.marker                                  = 'off'; cfg.comment  = 'no';
        ft_topoplotER(cfg,stat2plot);
        
        title(num2str(nfreq));
        
    end
end