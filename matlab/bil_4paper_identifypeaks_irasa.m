clear; clc;
close all;

if isunix
    project_dir     	= '/project/3015079.01/data/';
else
    project_dir     	= 'P:/3015079.01/data/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for ns = 1:length(suj_list)
    
    subjectName       	= suj_list{ns};
    
    fname           	= [project_dir subjectName '/preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    fname           	= [project_dir subjectName '/erf/' subjectName '.gratinglock.demean.erfComb.max20chan.p0p200ms.postOnset.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    %% select data
    cfg                 = [];
    cfg.channel         = max_chan;
    cfg.latency         = [-0.9967 0]; %[-0.4967 4.5];
    data_redef          = ft_selectdata(cfg,dataPostICA_clean);
    
    %% compute the fractal and original spectra
    cfg                 = [];
    cfg.foilim          = [1 40];
    cfg.pad             = 'nextpow2';
    cfg.method          = 'irasa';
    cfg.output          = 'fractal';
    fractal             = ft_freqanalysis(cfg, data_redef);
    cfg.output          = 'original';
    original            = ft_freqanalysis(cfg, data_redef);
    
    % subtract the fractal component from the power spectrum
    cfg             	= [];
    cfg.parameter       = 'powspctrm';
    cfg.operation       = 'x2-x1';
    oscillatory         = ft_math(cfg, fractal, original);
    
    %% plot fit and spectrum
    f                   = fit(oscillatory.freq', mean(oscillatory.powspctrm)', 'gauss3');
    
    figure;
    hold on;
    plot(oscillatory.freq, mean(oscillatory.powspctrm),'linewidth', 3, 'color', [.3 .3 .3])
    vline(f.a1,'-r');
    vline(f.a2,'-r');
    vline(f.a3,'-r');
    
    vline(f.b1,'-b');
    vline(f.b2,'-b');
    vline(f.b3,'-b');
    
    vline(f.c1,'-g');
    vline(f.c2,'-g');
    vline(f.c3,'-g');
    
    
end