clear ;

global ft_default
ft_default.spmversion = 'spm12';

suj_list                                        = [1:33 35:36 38:44 46:51];

for ns = 1:length(suj_list)
    
    subjectName                                 = ['sub' num2str(suj_list(ns))];clc;
    
    for nback = [0 1 2]
        
        % load data from both sessions
        check_name                              = dir(['/Volumes/heshamshung/nback/tf/' subjectName '.sess*.' num2str(nback) 'back.1t20Hz*.stakcombined.mat']);
        
        for nf = 1:length(check_name)
            
            fname                               = [check_name(nf).folder filesep check_name(nf).name];
            fprintf('loading %s\n',fname);
            load(fname);
            
            % baseline-correct
            cfg                                 = [];
            cfg.baseline                        = [-0.6 -0.2];
            cfg.baselinetype                    = 'relchange';
            freq_comb                           = ft_freqbaseline(cfg,freq_comb);
            
            tmp{nf}                             = freq_comb; clear freq_comb;
            
        end
        
        % avearge both sessions
        freq                                    = ft_freqgrandaverage([],tmp{:}); clear tmp nf check_name;
        
        
        % load peak
        fname                                   = ['/Volumes/heshamshung/nback/peak/' subjectName '.alphapeak.m500m0ms.mat'];
        fprintf('loading %s\n\n',fname);
        load(fname);
        
        bnd_width                               = 1;
        xi                                      = find(round(freq.freq) == round(apeak - bnd_width));
        yi                                      = find(round(freq.freq) == round(apeak + bnd_width));
        
        avg                                     = [];
        avg.avg                                 = squeeze(mean(freq.powspctrm(:,xi:yi,:),2));
        avg.label                               = freq.label;
        avg.dimord                              = 'chan_time';
        avg.time                                = freq.time; clear freq;
        
        alldata{ns,nback+1}                     = avg; clear avg;
        
    end
end

keep alldata

nb_suj                                          = size(alldata,1);
[design,neighbours]                             = h_create_design_neighbours(nb_suj,alldata{1,1},'elekta','t');

cfg                                             = [];
cfg.latency                                     = [-0.2 6];
cfg.statistic                                   = 'ft_statfun_depsamplesT';
cfg.method                                      = 'montecarlo';
cfg.correctm                                    = 'cluster';
cfg.clusteralpha                                = 0.05;
cfg.clusterstatistic                            = 'maxsum';
cfg.minnbchan                                   = 4;
cfg.tail                                        = 0;
cfg.clustertail                                 = 0;
cfg.alpha                                       = 0.025;
cfg.numrandomization                            = 1000;
cfg.uvar                                        = 1;
cfg.ivar                                        = 2;
cfg.neighbours                                  = neighbours;
cfg.design                                      = design;

stat{1}                                         = ft_timelockstatistics(cfg, alldata{:,1}, alldata{:,2});
stat{2}                                         = ft_timelockstatistics(cfg, alldata{:,1}, alldata{:,3});
stat{3}                                         = ft_timelockstatistics(cfg, alldata{:,2}, alldata{:,3});

for nt = 1:length(stat)
    [min_p(nt),p_val{nt}]                       = h_pValSort(stat{nt});
end

keep stat alldata min_p p_val

for nt = 1:length(stat)
    
    stat{nt}.mask                                   = stat{nt}.prob < (0.05/length(stat));
    
    stat2plot{nt}                                   = [];
    stat2plot{nt}.avg                               = stat{nt}.mask .* stat{nt}.stat;
    stat2plot{nt}.label                             = stat{nt}.label;
    stat2plot{nt}.dimord                            = stat{nt}.dimord;
    stat2plot{nt}.time                              = stat{nt}.time;
    
end

keep stat alldata min_p p_val stat2plot


for nt = 1:length(stat)
    
    figure;
    
    time_win                                    = 0.4;
    time_list                                   = [stat2plot.time(1):time_win:stat2plot.time(end)];
    
    for t = 1:length(time_list)-1
        subplot(4,4,t)
        cfg                                     = [];
        cfg.layout                              = 'neuromag306cmb.lay';
        cfg.zlim                                = 'maxabs';
        
        if t == length(time_list)
            cfg.xlim                            = [time_list(t) stat2plot.time(end)];
        else
            cfg.xlim                            = [time_list(t) time_list(t)+time_win];
        end
        
        cfg.marker                              = 'off';
        cfg.comment                             = 'no';
        ft_topoplotER(cfg,stat2plot);
    end
    
end