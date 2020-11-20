clear ; clc;

if isunix
    project_dir     = '/project/3015079.01/';
else
    project_dir     = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                                     = suj_list{nsuj};
    
    fname                                           = [project_dir 'data/' subjectName '/tf/' subjectName '.firstcuelock.freqComb.alphaPeak.' ...
        'm1000m0ms.gratinglock.demean.erfComb.max20chan.p0p200ms.5Bins.1Hz.window.preCue1.all.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    fname                                           = [project_dir 'data/' subjectName '/preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    % -- planar
    data_planar                                     = h_ax2plan(dataPostICA_clean);  
    
    % - - low pass filtering
    %     cfg                                             = [];
    %     cfg.detrend                                     = 'no';
    %     cfg.demean                                      = 'yes';
    %     cfg.baselinewindow                              = [-0.1 0];
    %     cfg.resamplefs                                  = 40;
    %     data_axial                                      = ft_resampledata(cfg,dataPostICA_clean); clear dataPostICA_clean;
    
    for nbin = 1:size(bin_summary.bins,2)
        
        %         % - - computing average
        %         cfg                                         = [];
        %         cfg.trials                                  = bin_summary.bins(:,nbin);
        %         avg                                         = ft_timelockanalysis(cfg,data_axial);
        %
        %         % - - combine planar
        %         cfg                                         = [];
        %         cfg.feedback                                = 'yes';
        %         cfg.method                                  = 'template';
        %         cfg.neighbours                              = ft_prepare_neighbours(cfg, avg); close all;
        %         cfg.planarmethod                            = 'sincos';
        %         avg_planar                                  = ft_megplanar(cfg, avg);
        %         avg_comb                                    = ft_combineplanar([],avg_planar);
        %
        %         avg_comb                                    = rmfield(avg_comb,'cfg');
        %
        %         fname                                       = ['J:\temp\bil\erf\' subjectName '.cuelock.alphabin' num2str(nbin) '.erf.comb.mat'];
        %         fprintf('\nSaving %s\n',fname);
        %         tic;save(fname,'avg_comb','-v7.3');toc; clear avg*
        
        cfg                                         = [];
        cfg.output                                  = 'pow';
        cfg.method                                  = 'mtmconvol';
        cfg.taper                                   = 'hanning';
        cfg.trials                                  = bin_summary.bins(:,nbin);
        cfg.foi                                     = 50:5:100;
        cfg.toi                                     = -0.5:0.05:6;
        cfg.t_ftimwin                               = ones(length(cfg.foi),1).*0.5;   % 5 cycles
        cfg.keeptrials                              = 'no';
        freq_planar                                 = ft_freqanalysis(cfg,data_planar);
        
        cfg                                         = []; cfg.method = 'sum';
        freq_comb                                   = ft_combineplanar(cfg,freq_planar);
        freq_comb                                   = rmfield(freq_comb,'cfg');
        %         avg                                         = [];
        %         avg.time                                    = freq_comb.time;
        %         avg.label                                   = freq_comb.label;
        %         avg.avg                                     = squeeze(mean(freq_comb.powspctrm,2));
        %         avg.dimord                                  = 'chan_time';
        
        fname                                       = ['J:\temp\bil\tf\' subjectName '.cuelock.alphabin' num2str(nbin) '.50t100Hz.comb.mat'];
        fprintf('\nSaving %s\n',fname);
        tic;save(fname,'freq_comb','-v7.3');toc; clear avg*
        
    end
end